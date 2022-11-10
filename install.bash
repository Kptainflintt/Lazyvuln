#!/bin/bash

#Updating system
apt-get update && apt-get upgrade -y

#Installing required components
apt-get install docker.io git nmap net-tools -y

#Installing Docker-compose
wget https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-linux-x86_64
mv docker-compose-linux-x86_64 docker-compose
cp docker-compose /bin/
chmod +x /bin/docker-compose

#Pulling and compose required containers 
docker pull kptainflintt/lazyvuln
wget https://raw.githubusercontent.com/infobyte/faraday/master/docker-compose.yaml
echo "Building Faraday Stack (it can take some time...)"
docker-compose up &> faraday.txt &
sleep 20
echo "Done..."
docker kill $(docker ps -q)
docker container prune -f

#Cleaning 
rm docker-compose
echo "Done, you can run scans!"

