#!/bin/bash

##  Installer Script for Pihole  with Various Options
##	Created by: Iced Computer
##  Last Modified 2024-09-05
## Version 1.0


## Set your options
TEST="no"
#TEST="yes"
TYPE="full"
#TYPE="security"
#DNSTYPE="cloudflared"
DNSTYPE="unbound"
VPN="yes_vpn"
#VPN="no"
PI="no"
#PI="yes"
## Is this a pihole version 5 or greater
VER="5"
#VER="4"
BLANK=" "

## Fixed VARS
TEMP=/scripts/temp
FINISHED=/scripts/Finished
PIHOLE=/etc/pihole
CONFIG=/scripts/Finished/CONFIG

## /VARS



function Basics()
{
 	
	# update the box and setup directories
	apt-get update && apt-get dist-upgrade -y
	wait
	apt autoremove -y
	wait
	mkdir /scripts
	mkdir $TEMP
	mkdir $FINISHED
	mkdir $CONFIG
	chmod 777 $FINISHED
	chmod 777 $TEMP
	chmod 777 $CONFIG
	
	apt-get install sqlite3 -y
	apt-get install vim -y
	
	## Unattended Upgrades just to be safe
	apt-get --yes --quiet --no-install-recommends install unattended-upgrades
	
	#download MFA
	curl --tlsv1.3 -o $FINISHED/MFA.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/MFA.sh'
 }

 
 function Config_setup()
{
	echo $TEST > $CONFIG/test.conf
	echo $TYPE > $CONFIG/type.conf
	echo $DNSTYPE > $CONFIG/dns_type.conf
	echo $VPN > $CONFIG/vpn.conf
	echo $PI > $CONFIG/pi.conf
	echo $VER > $CONFIG/ver.conf
	echo $BLANK > $CONFIG/perm_allow.conf
		
}


function f2b()
{
	#Install Fail to Ban
	apt-get install fail2ban -y
	wait
	curl --tlsv1.3 -o $TEMP/jail.local.temp 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/jail.local'
	wait
	mv $TEMP/jail.local.temp /etc/fail2ban/jail.local
	
}

function GPG()
{
gpg --full-generate-key
wait
bash -c 'echo -e "\033[0;31m gpg --output <KEY>.gpg --armor --export <KEY> \x1b[39m"'
}


#Main Program
Basics
Config_setup
f2b
GPG
