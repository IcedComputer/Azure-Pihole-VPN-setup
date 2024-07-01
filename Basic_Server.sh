#!/bin/bash

## Basic Setup for Servers
## Created by: Iced Computer
## Version 1.0
## Last Modified 2024-07-01


## Fixed VARS
TEMP=/scripts/temp
FINISHED=/scripts/Finished
CONFIG=/scripts/Finished/CONFIG

function Baseline()
{
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
}

function Secure()
{
	#download MFA
	curl --tlsv1.2 -o $FINISHED/MFA.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/MFA.sh'
	
	## Unattended Upgrades just to be safe
	apt-get --yes --quiet --no-install-recommends install unattended-upgrades
}

function f2b()
{
	#Install Fail to Ban
	apt-get install fail2ban -y
	wait

	#Establish a Permaban list
	curl --tlsv1.2 -o /etc/fail2ban/action.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/action.d_permaban.conf'
	curl --tlsv1.2 -o /etc/fail2ban/filter.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/filter.d_permaban.conf'
	curl --tlsv1.2 -o $TEMP/permaban.temp 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/jail.local'
	wait

	mv $TEMP/permaban.temp /etc/fail2ban/jail.local
	curl --tlsv1.2 -o $TEMP/additional.config 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/sshd_config'
}

function GPG()
{
	gpg --full-generate-key
	wait
	echo "sudo gpg --output <KEY>.gpg --armor --export <KEY>"
}

### Run the Program

Baseline
Secure
f2b
GPG
