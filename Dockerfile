FROM kptainflintt/gvm-core
FROM debian:bullseye

ENV GVM_LIBS_VERSION='v22.4.0' \
    GVMD_VERSION='v22.4.0' \
    OPENVAS_VERSION='v22.4.0' \
    OPENVAS_SMB_VERSION='v22.4.0' \
    OSPD_OPENVAS_VERSION='v22.4.2' \
    SRC_PATH='/src' \
    DEBIAN_FRONTEND=noninteractive \
    TERM=dumb

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils build-essential && \
    apt-get update && apt-get install gcc g++ make bison flex libksba-dev \
    curl redis libpcap-dev cmake git pkg-config libglib2.0-dev libgpgme-dev \
    nmap libgnutls28-dev uuid-dev libssh-gcrypt-dev libldap2-dev gnutls-bin \
    libmicrohttpd-dev libhiredis-dev zlib1g-dev libxml2-dev libnet-dev libradcli-dev \
    clang-format libldap2-dev doxygen gcc-mingw-w64 xml-twig-tools libical-dev perl-base \
    heimdal-dev libpopt-dev libunistring-dev graphviz libsnmp-dev python3-setuptools \
    python3-paramiko python3-lxml python3-defusedxml python3-dev gettext python3-polib \
    xmltoman python3-pip texlive-fonts-recommended \
    texlive-latex-extra --no-install-recommends xsltproc sudo vim rsync -y && \
    rm -rf /var/lib/apt/lists/*
	
RUN echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" >     /etc/apt/sources.list.d/pgdg.list && \
    curl -sL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc > /dev/null && \
    apt update && apt install postgresql-11 postgresql-contrib-11 postgresql-server-dev-11 -y

RUN pip3 install \
        lxml \
		python-gvm \
        gvm-tools \
        paramiko \
        defusedxml \
        redis \
        psutil \
		packaging \
		paho-mqtt \
		python-gnupg \
		wheel
		

RUN mkdir ${SRC_PATH} -p && \
    cd ${SRC_PATH} && \
    curl -o gvm-libs.tar.gz -sL https://github.com/greenbone/gvm-libs/archive/${GVM_LIBS_VERSION}.tar.gz && \
    curl -o openvas.tar.gz -sL https://github.com/greenbone/openvas/archive/${OPENVAS_VERSION}.tar.gz && \
    curl -o gvmd.tar.gz -sL https://github.com/greenbone/gvmd/archive/${GVMD_VERSION}.tar.gz && \
    curl -o openvas-smb.tar.gz -sL https://github.com/greenbone/openvas-smb/archive/${OPENVAS_SMB_VERSION}.tar.gz && \
    curl -o ospd-openvas.tar.gz -sL https://github.com/greenbone/ospd-openvas/archive/${OSPD_OPENVAS_VERSION}.tar.gz && \
    curl -o ospd.tar.gz -sL https://github.com/greenbone/ospd/archive/${OSPD_VERSION}.tar.gz && \
    find . -name \*.gz -exec tar zxvfp {} \;

RUN pip3 install --upgrade psutil==5.5.1 && \
    cd ${SRC_PATH}/ospd* && \
    pip3 install .

RUN cd ${SRC_PATH}/ospd-openvas* && \
    python3 -m pip install . && \
    rm -rf ${SRC_PATH}/ospd*

RUN cd ${SRC_PATH}/gvm-libs* && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm -rf ${SRC_PATH}/gvm-libs*

RUN cd ${SRC_PATH}/openvas-smb* && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm -rf ${SRC_PATH}/openvas-smb*

RUN cd ${SRC_PATH}/openvas* && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm -rf ${SRC_PATH}/openvas*

COPY --from=0 /var/lib/openvas/plugins /var/lib/openvas/plugins
COPY configs/redis.conf /etc/redis/redis.conf
COPY scripts/sync-nvts /usr/local/bin/sync-nvts
COPY scripts/greenbone-nvt-sync /usr/local/bin/greenbone-nvt-sync

RUN adduser service --gecos "service,service,service,service" --disabled-password && \
    echo "service:service" | chpasswd
	
COPY scripts/sync-nvts /usr/local/bin/sync-nvts

RUN redis-server /etc/redis/redis.conf && \
    chmod +x /usr/local/bin/greenbone-nvt-sync && \
    chmod +x /usr/local/bin/sync-nvts && \
    ldconfig && \
    sleep 10 && \
    bash /usr/local/bin/sync-nvts

RUN cd ${SRC_PATH}/gvmd-* && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm -rf ${SRC_PATH}/gvmd-*

COPY --from=0 /var/lib/gvm/scap-data /var/lib/gvm/scap-data
COPY --from=0 /var/lib/gvm/cert-data /var/lib/gvm/cert-data
COPY --from=0 /var/lib/gvm/data-objects /var/lib/gvm/data-objects
COPY scripts/sync-scap /usr/local/bin/sync-scap
COPY scripts/sync-certs /usr/local/bin/sync-certs
COPY scripts/sync-data /usr/local/bin/sync-data
COPY scripts/greenbone-certdata-sync /usr/local/sbin/greenbone-certdata-sync
COPY scripts/greenbone-scapdata-sync /usr/local/sbin/greenbone-scapdata-sync
COPY scripts/greenbone-feed-sync /usr/local/sbin/greenbone-feed-sync

RUN chmod +x /usr/local/sbin/greenbone-certdata-sync && \
    chmod +x /usr/local/sbin/greenbone-scapdata-sync && \
    chmod +x /usr/local/sbin/greenbone-feed-sync && \
    chmod +x /usr/local/bin/sync-scap && \
    chmod +x /usr/local/bin/sync-certs && \
    chmod +x /usr/local/bin/sync-data && \
    ldconfig && \
    sleep 10 && \
    sync-data && \
    sleep 10 && \
    sync-certs && \
    sleep 10 && \
    sync-scap

RUN git clone https://github.com/SecureAuthCorp/impacket.git && \
    cd impacket/ && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh && chmod +x rustup.sh && ./rustup.sh -y &&\
	export PATH="$HOME/.cargo/bin:$PATH" && \
    pip3 install . && \
    cd ../ && \
    rm -rf impacket

COPY scripts/start-services /usr/local/bin/start-services
COPY scripts/start-openvas /usr/local/bin/start-openvas
COPY scripts/start-scanner /usr/local/bin/start-scanner
COPY scripts/update-scanner /usr/local/bin/update-scanner
COPY scripts/configure-scanner /configure-scanner
COPY scripts/scan.py /scan.py
COPY configs/openvas.conf /etc/openvas/openvas.conf

RUN mkdir reports && \
    chmod 777 reports && \
    mkdir /var/run/ospd && \
    chmod 777 /var/run/ospd && \
    chmod +x /usr/local/bin/start-services && \
    chmod +x /usr/local/bin/start-openvas && \
    chmod +x /usr/local/bin/start-scanner && \
    chmod +x /usr/local/bin/update-scanner && \
    chmod +x /configure-scanner && \
    chmod +x /scan.py && \
    echo "net.core.somaxconn = 1024"  >> /etc/sysctl.conf && \
    echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
	

RUN bash /configure-scanner && \
    rm -f /configure-scanner && \
    rm -rf /usr/local/var/log/gvm/*.log && \
    rm -rf  /usr/local/var/run/feed-update.lock && \
    /etc/init.d/postgresql stop && \
    /etc/init.d/redis-server stop && \
    chmod 777 /var/lib/gvm/gvmd/report_formats
