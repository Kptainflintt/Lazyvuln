

## Automated scan engine with Greenbone (formerly OpenVAS), Faraday and docker.

Components : 

- Faraday-server : Faraday is a wonderful IPE (Integrated Penetration-Test Environnement) wich can parse and visaulize Grennbone's results in a beautiful dashboard.
- faraday-cli : Faraday's command-line interface
- docker image of GVM core (with no webUI) : build from source, pulled from Docker hub
- bash script 

Fully fonctionnal on a Debian host, feel free to tell if it's not working on other distrib.

I've created nothing, just compiling, all credits are listed at the end of this readme.

## How does it work?

This tool get your ip address from NIC and do a nmap ARP scan to get alive hosts on network.
The scan results are pulled in a text file, this file is given to Greenbone container in order to run a vulnerability scan only on alive hosts.
Then, theXML file is generated and send to Faraday, thanks to faraday-cli.

When finished, the results of the scan are visible on the Faraday web page http://<ip>:5985

## Steps to run automatic scans

### 1. Install all components :

First install cURL, then

```
curl -L https://raw.githubusercontent.com/Kptainflintt/Lazyvuln/master/install.bash | bash

```

When installing, script will ask you for scheduled scan if you want. It's just a cron job, executed daily, weekly or monthly. You can also create your own cron job later (for help, you can use https://crontab.guru/)
This will use my script to launch scan and pull XML results in faraday, with naming it with date (like scan_11-10-2022.xml)

This script is not mandatory, but can automate scan with upload to Faraday-server.You also can run it manually when you want

ATTENTION : please take care of faraday's password given at the end of the script!!!!

If you want to be notified when scan finished, you can use ssmtp and mailutils, just :

```
apt install ssmtp mailutils -y
```

Copy ssmtp.conf in this repo and change values to your own, copy it to /etc/ssmtp and add to /usr/bin/start-scan, at the end :

```
echo "The scan ended successfully, you should be able to see results on your faraday webui" | mail -s "Scan ended" *your_email_here*
```

### 2. Wait for cron job, or run it manually !

If you want to run a scan, just launch

```
start-scan
```
And wait for it to finish. Duration depends of : 

- Number of targets
- CPU
- RAM

So it can take 10 mn or even 10 hours, be patient!

For each scan, the script will create a new panel in Faraday, so you can navigate between your scans.


## Usage of docker image to run manual one-shot scan (Thanks to thedoctor0, copied from his repo)

### Scan and save report:

```
docker run --rm -v $(pwd):/reports/:rw kptainflintt/lazyvuln python3 -u scan.py <target> [options]
```

This will start up the container (optionnaly pull it) and update the NVTs cache - it can take some time, so be patient.

After that, the scan script will run and the progress will be displayed in the console.

### Customizations

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

### Send to Faraday container

First, if you not use install script, you have to compose faraday's container

```
wget https://raw.githubusercontent.com/infobyte/faraday/master/docker-compose.yaml
docker-compose up
```
Credentials will be in screen output, take care of it!

Then, install faraday-cli :

```
pip install faraday-cli
```

You can now open a session in faraday 

```
faraday-cli auth -f http://localhost:5985 -u faraday -p *your password*
```
Create a workspace : 
```
faraday-cli workspace create *name of your workspace*
```

And, finally, send XML to it:
```
faraday-cli tool report *path-to-your-scan-result*
```
More informations : https://docs.faraday-cli.faradaysec.com/

## Credits
- Mike Splain for creating the original OpenVAS docker image
- ICTU team for creating the base automation script for OpenVAS
- Eugene Merlinsky for adjusting the project to work with Greenbone 20.8.0
- thedoctor0 for his great job
- lukewegryn fir the automation script
- Faraday's team
- Greenbone's team

