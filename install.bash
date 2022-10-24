#!/bin/bash

#Updating system
apt-get update && apt-get upgrade -y

#Installing required components
apt-get docker.io git nmap net-tools -y

#Installing Docker-compose
wget https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64
cp docker-compose-linux-x86_64 /bin/bash/docker-compose
chmod +x /bin/bash/docker-compose

#Pulling and compose required containers 
docker pull kptainflintt/lazyvuln
wget https://raw.githubusercontent.com/infobyte/faraday/master/docker-compose.yaml
docker kill $(docker ps -q)
docker container prune -f

#Cleaning 
rm docker-compose-linux-x86_64
echo "Done, you can run scans!"

