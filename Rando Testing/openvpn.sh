#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##  This script is for the OpenVPN server
##	Created by: Iced Computer
##  16
##  Last Modified 31 May 2019
##
##
##

## VARS

TEMP=/scripts/temp
FINISHED=/scripts/Finished


function Install()
{
	apt-get update
	apt-get install openvpn easy-rsa -y

}

function CA()
{
 make-cadir ~/openvpn-ca
 cp /usr/share/easy-rsa/vars ~/openvpn-ca/vars
 
 cd ~/openvpn-ca
 source ./vars
 ./clean-all
 wait
 ./build-ca
 wait
 ./build-key-server <server name>
 wait
 ./build-dh
 wait
 openvpn --genkey --secret keys/ta.key
 wait
 
 
 cd ~/openvpn-ca/keys
 sudo cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn
 wait
 gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf
 
 
}



#Program Execution
Install
