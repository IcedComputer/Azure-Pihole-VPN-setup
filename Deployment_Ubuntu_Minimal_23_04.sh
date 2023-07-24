#!/bin/bash

##  Deployment Script for Azure Pihole using Cloudflare as DNS service + VPN service
## 	Developed for Ubuntu Minimal 23.04 x64 on Azure
##	Created by: Iced Computer
##  Created on: 2023-07-24
##  Last Modified 2023-07-24
## Version 1.0
## Some info taken from Pivpn & Pihole (launchers)
##


## Set your options
TEST="no"
#TEST="yes"
TYPE="full"
#TYPE="security"
DNSTYPE="cloudflared"
#DNSTYPE="unbound"
VPN="yes_vpn"
#VPN="no"
PI="no"
#PI="yes"
## Is this a pihole version 5 or greater
VER="yes"
#VER="no"
BLANK=" "

## Fixed VARS
TEMP=/scripts/temp
FINISHED=/scripts/Finished
PIHOLE=/etc/pihole
CONFIG=/scripts/Finished/CONFIG

##Screen Size

# Find the rows and columns. Will default to 80x24 if it can not be detected.
screen_size=$(stty size 2>/dev/null || echo 24 80)
rows=$(echo $screen_size | awk '{print $1}')
columns=$(echo $screen_size | awk '{print $2}')
# Divide by two so the dialogs take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

# Find IP used to route to outside world
IPv4dev=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++)if($i~/dev/)print $(i+1)}')
IPv4addr=$(ip route get 8.8.8.8| awk '{print $7}')
IPv4gw=$(ip route get 8.8.8.8 | awk '{print $3}')

## /VARS

###


function Welcome()
{
 # Display the welcome dialog
    whiptail --msgbox --backtitle "Welcome" --title "Azure VPN & Pihole" "This installer will transform your Azure Umbuntu Instance into a Pihole that leverages Cloud Flare DNS (https) w/ a VPN functionality!" ${r} ${c}

	
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
	
	# get a allowlist just in case!
	curl --tlsv1.2 -o $TEMP/basic.allow 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Allow%20Lists/basic.allow'
	
	## Unattended Upgrades just to be safe
	apt-get --yes --quiet --no-install-recommends install unattended-upgrades
	
	#download MFA
	curl --tlsv1.2 -o $FINISHED/MFA.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/MFA.sh'
	
	apt install sqlite3

 }