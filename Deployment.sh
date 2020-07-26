#!/bin/bash

##  Deployment Script for Azure Pihole using Cloudflare as DNS service + VPN service
##	Created by: Iced Computer
##  Last Modified 17 June 2020
## Version 2.1
## Some info taken from Pivpn & Pihole (launchers)
##

## VARS
TEMP=/scripts/temp
FINISHED=/scripts/Finished
PIHOLE=/etc/pihole
USR=/etc/pivpn/INSTALL_USER

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
	apt-get update && apt-get dist-upgrade -y
	wait
	mkdir /scripts
	mkdir $TEMP
	mkdir $FINISHED
	chmod 777 $FINISHED
	chmod 777 $TEMP
	
	# get a allowlist just in case!
	curl -o $TEMP/basic.allow 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Allow%20Lists/basic.allow'

		
}

function f2b()
{
	#Install Fail to Ban
	apt-get install fail2ban -y
	wait

	#Establish a Permaban list
	curl -o /etc/fail2ban/action.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/action.d_permaban.conf'
	curl -o /etc/fail2ban/filter.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/filter.d_permaban.conf'
	curl -o $TEMP/permaban.temp 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/jail.local'
	wait

	mv $TEMP/permaban.temp /etc/fail2ban/jail.local
	curl -o $TEMP/additional.config 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/sshd_config'
}

function piholeInstall()
{
	#Install Pihole
	
	curl -sSL https://install.pi-hole.net | bash
	wait
	cd /etc/.pihole
	sudo git fetch --tags
	wait
	sudo git checkout v4.4
	wait
	cd /var/www/html/admin
	sudo git fetch --tags
	wait
	sudo git checkout v4.3.3
	wait
	pihole -r
	wait
	pihole checkout ftl v4.3.1
	wait
}

function piholeUpdate()
{
	#Update whitelist
	cat $TEMP/basic.allow $PIHOLE/whitelist.txt | sort | uniq > $TEMP/whitelist.txt
	mv $TEMP/whitelist.txt $PIHOLE/whitelist.txt
	
		
	#download a new refresh.sh and run it to get updater
	curl -o $TEMPDIR/refresh.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/refresh.sh'
	wait
	bash $TEMPDIR/refresh.sh
	wait
	curl -o $FINISHED/ListUpdater.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ListUpdater.sh'
	wait
	# run updater
	bash $FINISHED/updates.sh
	wait
		
}

function CloudflaredInstall()
{
	#Install Cloudflared
	curl -o $TEMP/Cloudflared.deb  'https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.deb'
	wait
	apt-get install $TEMP/Cloudflared.deb
	wait
	cloudflared -v

}

function CloudflaredConfig()
{
	curl -o $FINISHED/cloudflared 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFconfig'
	curl -o /lib/systemd/system/cloudflared.service 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFService'
	wait
	systemctl enable cloudflared
	systemctl start cloudflared

	
	curl -o /etc/dnsmasq.d/50-cloudflared.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/50-cloudflared.conf'
	wait
	
	crontab -l | { cat; echo "*/5 * * * * /bin/systemctl restart cloudflared"; } | crontab -
	
	#fix some config issues with Pihole post Cloudflared
	sed -i "s/PIHOLE_DNS/#PIHOLE_DNS/g" /etc/pihole/setupVars.conf
	sed -i "s/server=8.8/#server=8.8/g" /etc/dnsmasq.d/01-pihole.conf

}

function piVpn()
{
	
	curl -L https://install.pivpn.io | bash
	wait
	
	## OpenVPN items
		#curl -o /etc/dnsmasq.d/02-ovpn.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/02-ovpn.conf'
		#get some files to make it easy
		#curl -o $FINISHED/ovpen12.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ovpn12.sh'
		#$SUDO mkdir /etc/openvpn/ccd
		#$SUDO sed -i "s/\#\ Generated\ for\ use\ by\ PiVPN\.io/client-config-dir\ \/etc\/openvpn\/ccd/g" /etc/openvpn/server.conf
		#$SUDO sed -i "s/client-to-client/#client-to-client/g" /etc/openvpn/server.conf

}

function Hygene()
{
apt-get --yes --quiet --no-install-recommends install unattended-upgrades
}

function Cleanup()
{
 
 curl -o /etc/ssh/sshd_config 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/sshd_config.txt'
 sudo iptables -A FORWARD -i tun0 -o tun0 -j DROP
 
 #Reminder to add your username into the sshd-config AllowedUsers section
 whiptail --msgbox --backtitle "WARNING" --title "Update SSHD_Config" "Hey idiot, remember to update your sshd_config file to add your AllowedUsers" ${r} ${c}
 sed -i "s/#edit/AllowUsers ${USR}/g" /etc/ssh/sshd_config
 
 #echo "********************************************"
 #echo "********************************************"
 #echo go to /etc/ssh/sshd_config and fix the file!
 #echo go to /etc/ssh/sshd_config and fix the file!
 #echo go to /etc/ssh/sshd_config and fix the file!
 #echo go to /etc/ssh/sshd_config and fix the file!
 #echo run command sed -i "s/#edit/AllowUsers USERNAME/g" /etc/ssh/sshd_config
 #echo "********************************************"
 #echo "********************************************"
 
 #cleanup of temp files
 rm -f $TEMP/basic.allow
 rm -f $TEMP/Cloudflared.deb
 
 apt autoremove -y
 
 crontab -l | { cat; echo "15 11 * * * /sbin/shutdown -r +5"; } | crontab -
 crontab -l | { cat; echo "10 9 * * * bash /scripts/Finished/updates.sh"; } | crontab -
 crontab -l | { cat; echo "5 8 * * * bash /scripts/Finished/refresh.sh"; } | crontab -
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
