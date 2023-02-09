#!/bin/bash

#Updating system
apt-get update && apt-get upgrade -y

#Installing required components
apt-get install docker.io git nmap net-tools python3-pip -y
pip install faraday-cli

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
faraday_pass=$(cat faraday.txt | grep "Admin user" | cut -d " " -f 13)
docker container prune -f

#downloading scan script
wget https://raw.githubusercontent.com/Kptainflintt/Lazyvuln/master/start-scan
chmod +x start-scan
cp start-scan /usr/bin

#Select right interface
echo -e " 1.eno, enp \n 2. eth \n 3. wl"

read -p "What type of interface should I look for ?" inet

if [ $inet = "2" ]
	then
		sed -i s/en/eth/g /usr/binstart-scan
elif [ $inet = "3" ]
	then 
		sed -i s/en/wl/g /usr/bin/start-scan
fi  


#Cleaning 
rm docker-compose*
rm start-scan
echo "Done, you can run scans! Just execute "start-scan" "

#Personalize
read -p "Would you like to perform scheduled scans? (y/n) " schedule

if [ "$schedule" = "y"]
	then
		echo "How often?"
		echo "1. Every day"
		echo "2. Every week"
		echo "3. Every month"
		read cron
		
		if [ "$cron" = 1 ]
			then
				cp /usr/bin/start-scan /etc/cron.daily/start-scan
		elif [ "$cron"= 2 ]
			then 
				cp /usr/bin/start-scan /etc/cron.weekly/start-scan
		elif [ "$cron"= 3 ]
			then 
				cp /usr/bin/start-scan /etc/cron.monthly/start-scan
		fi
fi
cat faraday.txt | grep --color=always "Admin user"
echo "You're done, have nice scans ;) "
