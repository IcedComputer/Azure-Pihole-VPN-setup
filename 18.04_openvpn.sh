#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##  This script is for the OpenVPN server
##	Created by: Iced Computer
##  18
##  Last Modified 13 June 2019
##
##
##

## VARS

TEMP=/scripts/temp
FINISHED=/scripts/Finished


function Install()
{
	apt-get update
	apt-get install openvpn -y

}

function CA()
{
 cd ~
 wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
 wait
 tar xvf EasyRSA-3.0.4.tgz
 cd ~/EasyRSA-3.0.4/
 wait
 ./easyrsa init-pki
 wait
 ./easyrsa build-ca
 wait
}



#Program Execution
Install
