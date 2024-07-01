#!/bin/bash

##  Deployment Script for Azure Pihole using Cloudflare as DNS service + VPN service
##	Created by: Iced Computer
##  Last Modified 2024-07-01
## Version 2.4
## Some info taken from Pivpn & Pihole (launchers)
##

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
	apt-get install vim -y

 }

 
 function config_setup()
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

	#Establish a Permaban list
	curl --tlsv1.2 -o /etc/fail2ban/action.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/action.d_permaban.conf'
	curl --tlsv1.2 -o /etc/fail2ban/filter.d/permaban.conf 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/filter.d_permaban.conf'
	curl --tlsv1.2 -o $TEMP/permaban.temp 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/jail.local'
	wait

	mv $TEMP/permaban.temp /etc/fail2ban/jail.local
	curl --tlsv1.2 -o $TEMP/additional.config 'https://raw.githubusercontent.com/IcedComputer/F2B-Configs/master/sshd_config'
}

function piholeInstall()
{
	#Install Pihole
	
	curl -sSL https://install.pi-hole.net | bash
	wait
	
	## if you want version 4
	#cd /etc/.pihole
	#sudo git fetch --tags
	#wait
	#sudo git checkout v4.4
	#wait
	#cd /var/www/html/admin
	#sudo git fetch --tags
	#wait
	#sudo git checkout v4.3.3
	#wait
	#pihole -r
	#wait
	#pihole checkout ftl v4.3.1
	#wait
}

function piholeUpdate()
{

	#download a new refresh.sh and run it to get updater, then run updates
	curl --tlsv1.2 -o $TEMPDIR/refresh.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/refresh.sh'
	wait
	bash $TEMPDIR/refresh.sh
	wait
	# run updater
	bash $FINISHED/updates.sh
	wait
	pihole restartdns
		
}

function CloudflaredInstall()
{
	#Install Cloudflared
	mkdir -p --mode=0755 /usr/share/keyrings
	curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
	echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
	wait
	apt-get update && apt-get install cloudflared
	wait
	cloudflared -v

}

function PiCloudflaredInstall()
{
	mkdir -p --mode=0755 /usr/share/keyrings
	curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
	echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bullseye main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
	wait
	apt-get update && apt-get install cloudflared
	wait
	cloudflared -v
}

function CloudflaredConfig()
{
	curl --tlsv1.2 -o $FINISHED/cloudflared 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFconfig'
	curl --tlsv1.2 -o /lib/systemd/system/cloudflared.service 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/CFService'
	wait
	systemctl enable cloudflared
	systemctl start cloudflared

	
	curl --tlsv1.2 -o /etc/dnsmasq.d/50-cloudflared.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/50-cloudflared.conf'
	wait
	
	crontab -l | { cat; echo "*/5 * * * * /bin/systemctl restart cloudflared"; } | crontab -
	
	#fix some config issues with Pihole post Cloudflared
	sed -i "s/PIHOLE_DNS/#PIHOLE_DNS/g" /etc/pihole/setupVars.conf
	sed -i "s/server=8.8/#server=8.8/g" /etc/dnsmasq.d/01-pihole.conf

}

function UnboundInstall()
{

	apt install unbound -y
	wait
	curl --tlsv1.2 -o $FINISHED/unbound_updates.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Scripts/unbound_updates.sh'
	wait
	bash $FINISHED/unbound_updates.sh
	wait
	curl --tlsv1.2 -o /etc/unbound/unbound.conf.d/pi-hole.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/pi-hole.conf'
	wait
	curl --tlsv1.2 -o /etc/dnsmasq.d/51-unbound.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/51-unbound.conf'
	wait


	systemctl disable --now unbound-resolvconf.service
	wait
	sed -Ei 's/^unbound_conf=/#unbound_conf=/' /etc/resolvconf.conf
	wait
	rm /etc/unbound/unbound.conf.d/resolvconf_resolvers.conf
	wait
	service unbound restart
	
	#sudo systemctl stop unbound-resolvconf.service
	#wait
	#sed -i "s/servers=8.8.8.8 8.8.4.4/servers=127.0.0.1/g" /etc/dhcpcd.conf
	#wait
	#systemctl restart dhcpcd
	#wait
	#service unbound restart
	#systemctl start unbound
	#systemctl enable unbound
	crontab -l | { cat; echo "7 0 4,22 */4 * bash /scripts/Finished/unbound_updates.sh"; } | crontab -

}

function piVpn()
{
	
	curl --tlsv1.2 -L https://install.pivpn.io | bash
	wait
	
	## OpenVPN items
		#curl --tlsv1.2 -o /etc/dnsmasq.d/02-ovpn.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/02-ovpn.conf'
		#get some files to make it easy
		#curl --tlsv1.2 -o $FINISHED/ovpen12.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/ovpn12.sh'
		#$SUDO mkdir /etc/openvpn/ccd
		#$SUDO sed -i "s/\#\ Generated\ for\ use\ by\ PiVPN\.io/client-config-dir\ \/etc\/openvpn\/ccd/g" /etc/openvpn/server.conf
		#$SUDO sed -i "s/client-to-client/#client-to-client/g" /etc/openvpn/server.conf

}


function Cleanup()
{
 
 curl --tlsv1.2 -o /etc/ssh/sshd_config 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/sshd_config.txt'
 sudo iptables -A FORWARD -i tun0 -o tun0 -j DROP
 
 #Reminder to add your username into the sshd-config AllowedUsers section
 whiptail --msgbox --backtitle "WARNING" --title "Update SSHD_Config" "Hey idiot, remember to update your sshd_config file to add your AllowedUsers" ${r} ${c}
 #sed -i "s/#edit/AllowUsers {USR}g" /etc/ssh/sshd_config
 
 echo "********************************************"
 echo "********************************************"
 echo go to /etc/ssh/sshd_config and fix the file!
 echo go to /etc/ssh/sshd_config and fix the file!
 echo go to /etc/ssh/sshd_config and fix the file!
 echo go to /etc/ssh/sshd_config and fix the file!
 echo run command "echo AllowUsers USERNAME > /etc/ssh/sshd_config"
 echo "********************************************"
 echo "********************************************"
 
 #cleanup of temp files
 rm -f $TEMP/basic.allow
 rm -f $TEMP/*.temp
 
 apt autoremove -y
 
 crontab -l | { cat; echo "15 11 * * * /sbin/shutdown -r +5"; } | crontab -
 crontab -l | { cat; echo "10 9 * * 0-1,3-4,6 bash /scripts/Finished/updates.sh"; } | crontab -
 crontab -l | { cat; echo "10 9 * * 2,5 bash /scripts/Finished/purge.sh"; } | crontab -
 crontab -l | { cat; echo "5 8 * * * bash /scripts/Finished/refresh.sh"; } | crontab -
}

function GPG()
{
gpg --full-generate-key
wait
echo "gpg --output <KEY>.gpg --armor --export <KEY>"
}


function SelfUse()
{
## ensure the server uses itself for DNS lookup
## test
unlink /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved.service
sed -i "s/nameserver/#nameserver/g" /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
}

#Main Program
Welcome
config_setup

dns_type=$(<"$CONFIG/dns_type.conf") 
vpn_box=$(<"$CONFIG/vpn.conf")
pi_box=$(<"$CONFIG/pi.conf")

f2b
piholeInstall


# Install Cloudflared
if [ $dns_type = "cloudflared" ]
	then if [ $pi_box = "no" ]
			then
				CloudflaredInstall
				CloudflaredConfig
			else
				PiCloudflaredInstall
		fi
	else if [ $dns_type = "unbound" ]
			then
				UnboundInstall
		fi
fi


## Check if we want a VPN Installed
if [ $vpn_box = "yes_vpn" ]
	then
		piVpn
	
fi

SelfUse
piholeUpdate

Cleanup
GPG
