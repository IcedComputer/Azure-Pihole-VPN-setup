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
	apt-get install openvpn easy-rsa

}

function CA()
{
 

}



#Program Execution
Install