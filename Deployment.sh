#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##	Created by: Iced Computer
##  Last Modified 31 May 2019
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
	
	wget -O $TEMP/whitelist.download 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.txt'
	
}

function f2b()
{

	apt-get install fail2ban
	wait


	wget -O /etc/fail2ban/action.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/action.d_permaban.conf'
	wget -O /etc/fail2ban/filter.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/filter.d_permaban.conf'
	wget -O $TEMP/permaban.temp 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/jail.local'
	wait

	mv $TEMP/permaban.temp /etc/fail2ban/jail.local
	wget -O $TEMP/additional.config 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/sshd_config'
}

function piholeInstall()
{
	curl -sSL https://install.pi-hole.net | bash
	wait
}

function piholeUpdate()
{
	cat $TEMP/whitelist.download etc/pihole/whitelist.txt | sort | uniq > $TEMP/whitelist.txt
	mv $TEMP/whitelist.txt /etc/pihole/whitelist.txt

	
	wget -O $FINISHED/updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/updates.sh'
	wait
	wget -O $FINISHED/ListUpdater.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ListUpdater.sh'
	wait
	
	
	bash $FINISHED/updates.sh
	wait
}

function CloudflaredInstall()
{

	wget -O $TEMP/Cloudflared.deb  'https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb'
	wait
	apt-get install $TEMP/Cloudflared.deb
	wait
	cloudflared -v

}

function CloudflaredConfig()
{
	wget -O /etc/default/cloudflared 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/CFconfig'
	wget -O /lib/systemd/system/cloudflared.service 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/CFService'
	wait
	systemctl enable cloudflared
	systemctl start cloudflared

	
	wget -O /etc/dnsmasq.d/50-cloudflared.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/50-cloudflared.conf'
	wait
	
	crontab crontab -l | { cat; echo "*/5 * * * * /bin/systemctl restart cloudflared"; } | crontab -
}

function piVpn()
{
	curl -L https://install.pivpn.io | bash
	wget -O /etc/dnsmasq.d/02-ovpn.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/02-ovpn.conf'

}


function Cleanup()
{
 echo go to /etc/ssh/sshd_config and fix the file!
 wget -O /etc/ssh/sshd_config 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/sshd_config.txt'
 echo go to /etc/ssh/sshd_config and fix the file!
  
 rm -f $TEMP/whitelist.download
 rm -f $TEMP/Cloudflared.deb
}

#Main Program
Initial
f2b
piholeInstall
piholeUpdate
CloudflaredInstall
CloudflaredConfig
#piVpn
Cleanup