FROM debian:stable-slim

ENV GVM_VERSION=22.4.0 \
    GVM_LIBS_VERSION=22.4.2 \
    GVMD_VERSION=22.4.2 \
    PG_GVM_VERSION=22.4.0 \
    OPENVAS_SMB_VERSION=22.4.0 \
    OPENVAS_SCANNER_VERSION=22.4.1 \
    OSPD_OPENVAS_VERSION=22.4.5 \
    NOTUS_VERSION=22.4.2 \
    SRC_PATH='/src' \
    PATH="${PATH}:/usr/local/sbin" \
    INSTALL_PREFIX=/usr/local \
    DEBIAN_FRONTEND=noninteractive \
    TERM=dumb

RUN   apt-get update && apt-get install --no-install-recommends --assume-yes \
  build-essential \
  curl \
  cmake \
  pkg-config \
  python3 \
  python3-pip \
  gnupg \
  libglib2.0-dev \
  libgpgme-dev \
  libgnutls28-dev \
  uuid-dev \
  libssh-gcrypt-dev \
  libhiredis-dev \
  libxml2-dev \
  libpcap-dev \
  libnet1-dev \
  libpaho-mqtt-dev  \
  libldap2-dev \
  libradcli-dev \
  libpq-dev \
  postgresql-server-dev-13 \
  postgresql-13 \
  postgresql-contrib-13 \
  libical-dev \
  xsltproc \
  rsync \
  libbsd-dev \
  texlive-latex-extra \
  texlive-fonts-recommended \
  xmlstarlet \
  zip \
  rpm \
  fakeroot \
  dpkg \
  nsis \
  gpgsm \
  wget \
  sshpass \
  openssh-client \
  socat \
  snmp \
  smbclient \
  python3-lxml \
  gnutls-bin \
  xml-twig-tools \
  gcc-mingw-w64 \
  libpopt-dev \
  libunistring-dev \
  heimdal-dev \
  perl-base \
  bison \
  libgcrypt20-dev \
  libksba-dev \
  nmap \
  libjson-glib-dev \
  python3-impacket \
  libsnmp-dev \
  python3-setuptools \
  python3-packaging \
  python3-wrapt \
  python3-cffi \
  python3-psutil \
  python3-defusedxml \
  python3-paramiko \
  python3-redis \
  python3-paho-mqtt \
  python3-setuptools \
  python3-paho-mqtt \
  python3-psutil \
  python3-gnupg \
  python3-setuptools \
  python3-packaging \
  python3-defusedxml \
  redis-server \
  sudo  \
  mosquitto && \
  rm -rf /var/lib/apt/lists/*

RUN pip3 install \
    python-gvm \
    gvm-tools 

RUN mkdir ${SRC_PATH} -p && \
    cd ${SRC_PATH} && \
    curl -o gvm-libs.tar.gz -sL https://github.com/greenbone/gvm-libs/archive/refs/tags/v${GVM_LIBS_VERSION}.tar.gz && \
    curl -o openvas.tar.gz -sL https://github.com/greenbone/openvas/archive/v${OPENVAS_SCANNER_VERSION}.tar.gz && \
    curl -o gvmd.tar.gz -sL https://github.com/greenbone/gvmd/archive/v${GVMD_VERSION}.tar.gz && \
    curl -o openvas-smb.tar.gz -sL https://github.com/greenbone/openvas-smb/archive/v${OPENVAS_SMB_VERSION}.tar.gz && \
    curl -o ospd-openvas.tar.gz -sL https://github.com/greenbone/ospd-openvas/archive/v${OSPD_OPENVAS_VERSION}.tar.gz && \
    curl -o pg-gvm.tar.gz -sL https://github.com/greenbone/pg-gvm/archive/refs/tags/v${PG_GVM_VERSION}.tar.gz && \
    curl -o notus.tar.gz -sL https://github.com/greenbone/notus-scanner/archive/refs/tags/v{$NOTUS_VERSION}.tar.gz && \
    find . -name \*.gz -exec tar zxvfp {} \;


RUN cd ${SRC_PATH}/ospd-openvas* && \
    python3 -m pip install . --prefix=$INSTALL_PREFIX --no-warn-script-location && \
    rm -rf ${SRC_PATH}/ospd*
	
RUN cd ${SRC_PATH}/notus* && \
    python3 -m pip install . --prefix=$INSTALL_PREFIX --no-warn-script-location && \
    rm -rf ${SRC_PATH}/notus*
	
RUN cd ${SRC_PATH}/gvm-libs* && \
    mkdir build && \
    cd build && \
    cmake ..	\
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var && \
    make && \
    make install && \
    rm -rf ${SRC_PATH}/gvm-libs*

RUN cd ${SRC_PATH}/openvas-smb* && \
    mkdir build && \
    cd build && \
    cmake ..  \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install && \
    rm -rf ${SRC_PATH}/openvas-smb*

RUN cd ${SRC_PATH}/openvas* && \
    mkdir build && \
    cd build && \
    cmake .. \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DSYSCONFDIR=/etc \
    -DLOCALSTATEDIR=/var \
    -DOPENVAS_FEED_LOCK_PATH=/var/lib/openvas/feed-update.lock \
    -DOPENVAS_RUN_DIR=/run/ospd && \
    make -j$(nproc) && \
    make install && \
    rm -rf ${SRC_PATH}/openvas*

COPY configs/redis-openvas.conf /etc/redis/redis.conf
COPY configs/openvas.conf /etc/openvas/openvas.conf
COPY configs/mosquitto.conf /etc/mosquitto/mosquitto.conf
COPY scripts/sync-nvts /usr/local/bin/sync-nvts
COPY scripts/greenbone-nvt-sync /usr/local/bin/greenbone-nvt-sync

RUN adduser service --gecos "service,service,service,service" --disabled-password && \
    echo "service:service" | chpasswd
	
COPY scripts/sync-nvts /usr/local/bin/sync-nvts

RUN mkdir /run/redis-openvas && \
    chown redis:redis /run/redis-openvas && \
    chown redis:redis /etc/redis/redis.conf &&\
    redis-server /etc/redis/redis.conf && \
    chmod +x /usr/local/bin/greenbone-nvt-sync && \
    chmod +x /usr/local/bin/sync-nvts && \
    ldconfig && \
    sleep 10 && \
    bash /usr/local/bin/sync-nvts

RUN cd ${SRC_PATH}/gvmd-* && \
    mkdir build && \
    cd build && \
    cmake ..  \ 
    -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DLOCALSTATEDIR=/var \
    -DSYSCONFDIR=/etc \
    -DGVM_DATA_DIR=/var \
    -DGVMD_RUN_DIR=/run/gvmd \
    -DOPENVAS_DEFAULT_SOCKET=/run/ospd/ospd-openvas.sock \
    -DGVM_FEED_LOCK_PATH=/var/lib/gvm/feed-update.lock \
    -DSYSTEMD_SERVICE_DIR=/lib/systemd/system \
    -DLOGROTATE_DIR=/etc/logrotate.d && \
    make -j$(nproc) && \
    make install && \
    rm -rf ${SRC_PATH}/gvmd-*
	
RUN cd ${SRC_PATH}/pg-gvm* && \
    mkdir build && \
    cd build && \
    cmake ..  \
    -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install && \
    rm -rf ${SRC_PATH}/pg-gvm*

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


COPY scripts/start-services /usr/local/bin/start-services
COPY scripts/start-openvas /usr/local/bin/start-openvas
COPY scripts/start-scanner /usr/local/bin/start-scanner
COPY scripts/start-gse /usr/local/bin/start-gse
COPY scripts/update-scanner /usr/local/bin/update-scanner
COPY scripts/configure-scanner /configure-scanner
COPY scripts/scan.py /scan.py


RUN mkdir reports && \
    chmod 777 reports && \
    mkdir /var/run/ospd && \
    chmod 777 /var/run/ospd && \
    chmod +x /usr/local/bin/start-services && \
    chmod +x /usr/local/bin/start-openvas && \
    chmod +x /usr/local/bin/start-scanner && \
    chmod +x /usr/local/bin/update-scanner && \
    chmod +x /configure-scanner && \
    chmod +x /usr/local/bin/start-gse && \
    chmod +x /scan.py && \
    echo "net.core.somaxconn = 1024"  >> /etc/sysctl.conf && \
    echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf

RUN mkdir /run/mosquitto && \
    chown mosquitto:mosquitto /run/mosquitto && \
    mkdir /run/gvmd && \
    mkdir /run/notus-scanner && \
    mkdir /var/run/openvas/ && \
    mkdir /var/run/openvas/plugins && \
    mkdir /var/run/openvas/plugins/notus && \
    mkdir /var/run/openvas/plugins/notus/products

	
RUN bash /configure-scanner && \
    rm -f /configure-scanner && \
    rm -rf /var/log/gvm/*.log && \
    rm -rf  /var/run/feed-update.lock && \
    rm -rf /src/* && \
    /etc/init.d/postgresql stop && \
    /etc/init.d/redis-server stop && \ 
    chmod 777 /var/lib/gvm/gvmd/report_formats
