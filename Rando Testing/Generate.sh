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

function Generate()
{
cd ~/EasyRSA-v3.0.6
./easyrsa gen-req <name>
cp pki/private/<name>.key ~/client-configs/keys/
scp pki/reqs/<name>.req sammy@your_CA_ip:/tmp
}

function CASign()
{
cd ~/EasyRSA-v3.0.6
./easyrsa import-req /tmp/<name>.req <common name>
./easyrsa sign-req client <Common name>
scp pki/issued/<name>.crt sammy@your_server_ip:/tmp
}
function move()
{
 mv /tmp/*.crt ~/client-configs/keys/
 
 #one time?
 cp ~/EasyRSA-3.0.4/ta.key ~/client-configs/keys/
sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/
}