Work in progress, will be published soon
<!-- # Greenbone GVM core 

Automated scan engine with Greenbone (formerly OpenVAS), Faraday and docker.

Components for working : 

- Faraday-server
- faraday-cli
- docker image of GVM core (with no webUI)
- bash script 

## Steps

### 1. Install Faraday

Faraday is a wonderful IPE (Integrated Penetration-Test Environnement) wich can parse and visaulize Grennbone's results in a beautiful dashboard.
Let's install it following infobytes's steps on [Infobyte repository](https://github.com/infobyte/faraday)
Don't forget to install [farady-cli](https://github.com/infobyte/faraday-cli)

### 2. Pull image:

```
docker pull kptainflintt/gvm-core
```

### 3. Download script

This script is not mandatory, but can automate scan with upload to Faraday-server.


## Usage of docker image to run one-shot scan (Thanks to thedoctor0, copied from his repo)

### Scan and save report:

```
docker run --rm -v $(pwd):/reports/:rw kptainflintt/gvm-core python3 -u scan.py <target> [options]
```

This will start up the container and update the NVTs cache - it can take some time, so be patient.

After that, the scan script will run and the progress will be displayed in the console.


#### Target

Target can be a single IP or CIDR or a comma separated list of IP addresses or CIDRs.

#### Output

It is possible to specify output filename with **-o** or **--output** argument.

By default report is saved as *openvas.report*.

#### Formats

1. Anonymous XML
2. CSV Results
3. ITG
4. PDF
5. TXT
6. XML

You can select what report format will be used with **-f** or **--format** argument with one of the available profiles.

By default *XML* format is used to generate the report.

#### Profiles

1. Base
2. Discovery
3. Empty
4. Full and fast
5. Host Discovery
6. System Discovery
7. GaussDB 100 V300R001C00 Security Hardening Guide (Standalone)
8. EulerOS Linux Security Configuration
9. Huawei Datacom Product Security Configuration Audit Guide
10. IT-Grundschutz

You can select scan profile by adding **-p** or **--profile** argument with one of the available profiles.

By default *Full and fast* profile is used.

#### Alive Tests

1. Scan Config Default
2. ICMP, TCP-ACK Service & ARP Ping
3. TCP-ACK Service & ARP Ping
4. ICMP & ARP Ping
5. ICMP & TCP-ACK Service Ping
6. ARP Ping
7. TCP-ACK Service Ping
8. TCP-SYN Service Ping
9. ICMP Ping
10. Consider Alive

You can select scan alive tests by adding **-t** or **--tests** argument with one of the available tests.

By default *ICMP, TCP-ACK Service & ARP Ping* alive tests are used.

#### Port Lists

1. All IANA Assigned TCP
2. All IANA Assigned TCP and UDP
3. All TCP and Nmap top 100 UDP

You can select scan alive tests by adding **-P** or **--ports** argument with one of the available tests.

By default *All TCP and Nmap top 100 UDP* port list is used.
Note that using *All TCP and Nmap top 100 UDP* will significantly increase the scan time.

#### Exclude Hosts

You can exclude hosts from specified target by adding **-e** or **--exclude** argument with list of IPs.

By default list of excluded hosts is empty.

#### Max Hosts

It is possible to override *max_hosts* variable in OpenVAS config which specify maximum number of simultaneous hosts tested.
Just add **-m** or **--max** argument with wanted numeric value.

By default **10** is used as *max_hosts* variable value.

#### Max Checks

It is possible to override *max_checks* variable in OpenVAS config which specify maximum number of simultaneous checks against each host tested.
Just add **-c** or **--checks** argument with wanted numeric value.

By default **3** is used as *max_checks* variable value.

#### Debug

You can enable printing command responses by adding **--debug** argument.

#### Update

You can also add **--update** argument to force update.

This will synchronize OpenVAS feeds before making the scan.

Feeds update is quite slow, so it will take significantly more time.

## Credits
- Mike Splain for creating the original OpenVAS docker image
- ICTU team for creating the base automation script for OpenVAS
- Eugene Merlinsky for adjusting the project to work with Greenbone 20.8.0
--!>
