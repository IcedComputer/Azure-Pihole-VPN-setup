#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##  This script is for the OpenVPN server
##	Created by: Iced Computer
##  18.04
##  Last Modified 13 June 2019
##
##
##

## VARS

TEMP=/scripts/temp
FINISHED=/scripts/Finished
OVPN=/etc/openvpn


function Install()
{
	apt-get update && apt-get dist-upgrade -y
	apt-get install openvpn -y
	wait
	
	
	# Back up Documents
	sudo mkdir $OVPN/Documentation
	sudo cp -r  /usr/share/doc/openvpn/ $OVPN/Documentation


 cd ~
 wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.6/EasyRSA-unix-v3.0.6.tgz
 wait
 tar xvf EasyRSA-unix-v3.0.6.tgz
 wait
 
}

function VFile()
{
## improvements here to download a pre-established file
 cd ~/EasyRSA-v3.0.6/
 cp vars.example vars
}

function Cleanup()
{
rm -f ~/EasyRSA-unix-v3.0.6.tgz
}

function CA()
{
 Install
 VFile
./easyrsa init-pki
./easyrsa build-ca
}

function OVPN()
{
 Install
 ~/EasyRSA-v3.0.6
 ./easyrsa gen-req <name> nopass
 wait
 cp ~/EasyRSA-v3.0.6/pki/private/<name>.key $OVPN
 
 scp ~/EasyRSA-v3.0.6/pki/reqs/<>.req <to CA>

}

function Sign()
{
 cd ~/EasyRSA-v3.0.6
 ./easyrsa import-req /tmp/<name>.req <Common Name>
 ./easyrsa sign-req server <Common Name>
 scp pki/issued/<name>.crt <OVPN server>
 scp pki/ca.crt <OVPN server>
}

function uploadOVPN()
{
 mv /tmp/*.crt $OVPN
 cd ~/EasyRSA-v3.0.6
 ./easyrsa gen-dh
 wait
 openvpn --genkey --secret ta.key
 wait
 
 cp ~/EasyRSA-v3.0.6/ta.key $OVPN
 cp ~/EasyRSA-v3.0.6/pki/dh.pem $OVPN
 mkdir -p ~/client-configs/keys
 chmod -R 700 ~/client-configs
}

function OVPNserverConfig()
{
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
sudo gzip -d /etc/openvpn/server.conf.gz

# configure file may download fixed file
}
#Program Execution
CA
OVPN
Cleanup
