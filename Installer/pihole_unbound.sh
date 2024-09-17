#!/bin/bash

##  Installer Script for Pihole  with Various Options
##	Created by: Iced Computer
##  Last Modified 2024-09-05
## Version 1.0

## Fixed VARS
TEMP=/scripts/temp
FINISHED=/scripts/Finished
PIHOLE=/etc/pihole
CONFIG=/scripts/Finished/CONFIG

## /VARS


function piholeInstall()
{
	#Install Pihole
	
		if [ $pi_box = "no" ]
			then
				curl -sSL https://install.pi-hole.net | bash
				wait
			else
				curl -sSL https://install.pi-hole.net | sudo PIHOLE_SKIP_OS_CHECK=true bash

		fi
		
}

function piholeUpdate()
{

	#download a new refresh.sh and run it to get updater, then run updates
	curl --tlsv1.3 -o $TEMPDIR/refresh.sh 'https://raw.githubusercontent.com/IcedComputer/Personal-Pi-Hole-configs/master/Updates/refresh.sh'
	wait
	bash $TEMPDIR/refresh.sh
	wait
	# run updater
	bash $FINISHED/updates.sh
	wait
	pihole restartdns
		
}

function UnboundInstall()
{

	apt-get install unbound -y
	wait
	curl --tlsv1.3 -o $FINISHED/unbound_updates.sh 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Scripts/unbound_updates.sh'
	wait
	bash $FINISHED/unbound_updates.sh
	wait
	curl --tlsv1.3 -o /etc/unbound/unbound.conf.d/pi-hole.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/pi-hole.conf'
	wait
	curl --tlsv1.3 -o /etc/dnsmasq.d/51-unbound.conf 'https://raw.githubusercontent.com/IcedComputer/Azure-Pihole-VPN-setup/master/Configuration%20Files/51-unbound.conf'
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
## Main Program

piholeInstall
piholeUpdate
UnboundInstall