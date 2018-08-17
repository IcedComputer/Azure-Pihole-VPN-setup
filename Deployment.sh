#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##	Created by: Iced
##  Last Modified 17 August 2018
##
##
##

## VARS

TEMP=/scripts/temp
FINISHED=/scripts/Finished


###


function Initial()
{
	apt-get update && apt-get upgrade -y
	wait
	mkdir /scripts
	mkdir /scripts/temp
	mkdir /scripts/Finished
	
	wget -O $FINISHED/updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/updates.sh'
}

function f2b()
{

	apt-get install fail2ban
	wait


	wget -O /etc/fail2ban/action.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/action.d_permaban.conf'
	wget -O /etc/fail2ban/filter.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/filter.d_permaban.conf'
	wget -O $TEMP/permaban.temp 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/jail.local'
	wait

	chmod 777 /etc/fail2ban/jail.local
	cat $TEMP/permaban.temp >> /etc/fail2ban/jail.local
	chmod 644 /etc/fail2ban/jail.local
}

function pihole()
{
	curl -sSL https://install.pi-hole.net | bash

}


#Main Program
Initial
f2b
pihole