#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##  This script is for the OpenVPN server
##	Created by: Iced Computer
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
 <<download var file into location>>
 
 cd ~/openvpn-ca
 source vars
 ./clean-all
 wait
 ./build-ca
 wait
 ./build-key-server <server name>
 wait
 ./build-dh
 wait
 openvpn --genkey --secret keys/ta.key
}



#Program Execution
Install
