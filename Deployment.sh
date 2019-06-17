#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##	Created by: Iced Computer
##  Last Modified 14 June 2019
## Some info taken from Pivpn & Pihole (launchers)
##

## VARS

TEMP=/scripts/temp
FINISHED=/scripts/Finished
PIHOLE=/etc/pihole
USR=whoami

##Screen Size

# Find the rows andmk columns. Will default to 80x24 if it can not be detected.
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

 }


function Initial()
{
	# update the service and setup directories
	apt-get update && apt-get upgrade -y
	wait
	mkdir /scripts
	mkdir $TEMP
	mkdir $FINISHED
	
	# get a whitelist just in case!
	wget -O $TEMP/whitelist.download 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/whitelist.txt'
	
	
}

function f2b()
{
	#Install Fail to Ban
	apt-get install fail2ban -y
	wait

	#Establish a Permaban list
	wget -O /etc/fail2ban/action.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/action.d_permaban.conf'
	wget -O /etc/fail2ban/filter.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/filter.d_permaban.conf'
	wget -O $TEMP/permaban.temp 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/jail.local'
	wait

	mv $TEMP/permaban.temp /etc/fail2ban/jail.local
	wget -O $TEMP/additional.config 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/sshd_config'
}

function piholeInstall()
{
	#Install Pihole
	curl -sSL https://install.pi-hole.net | bash
	wait
}

function piholeUpdate()
{
	#Update whitelist
	cat $TEMP/whitelist.download $PIHOLE/whitelist.txt | sort | uniq > $TEMP/whitelist.txt
	mv $TEMP/whitelist.txt $PIHOLE/whitelist.txt
	
	
	#New Regex lists & blocking lists
	wget -O $FINISHED/updates.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/updates.sh'
	wait
	wget -O $FINISHED/ListUpdater.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ListUpdater.sh'
	wait
	bash $FINISHED/updates.sh
	wait
}

function CloudflaredInstall()
{
	#Install Cloudflared
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
	
	#fix some config issues with Pihole post Cloudflared
	sed -i "s/PIHOLE_DNS/#PIHOLE_DNS/g" /etc/pihole/setupVars.conf

}

function piVpn()
{
	##curl -L https://install.pivpn.io | bash
	curl -L https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/testing.sh | bash
	wait
	wget -O /etc/dnsmasq.d/02-ovpn.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/02-ovpn.conf'
	#get some files to make it easy
	wget -O $FINISHED/ovpen12.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ovpn12.sh'

}

function Hygene()
{
apt-get --yes --quiet --no-install-recommends install unattended-upgrades
}

function Cleanup()
{
 
 wget -O /etc/ssh/sshd_config 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/sshd_config.txt'
 
 
 #Reminder to add your username into the sshd-config AllowedUsers section
 whiptail --msgbox --backtitle "WARNING" --title "Update SSHD_Config" "Hey idiot, remember to update your sshd_config file to add your AllowedUsers" ${r} ${c}
 #sed -i "s/#edit/AllowedUsers ${USR}/g" /scripts/temp/sshd_config
 echo "********************************************"
 echo "********************************************"
 echo go to /etc/ssh/sshd_config and fix the file!
 echo go to /etc/ssh/sshd_config and fix the file!
 echo go to /etc/ssh/sshd_config and fix the file!
 echo go to /etc/ssh/sshd_config and fix the file!
 echo run command sed -i "s/#edit/AllowUsers USERNAME/g" /etc/ssh/sshd_config
 echo "********************************************"
 echo "********************************************"
 
  #cleanup of temp files
 rm -f $TEMP/whitelist.download
 rm -f $TEMP/Cloudflared.deb
}

#Main Program
Welcome
Initial
f2b
piholeInstall
piholeUpdate
CloudflaredInstall
CloudflaredConfig
piVpn
Hygene
Cleanup