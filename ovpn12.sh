#!/bin/bash

##  Deployment Script for Azure Pihole + VPN service using Cloudflare as DNS service
##	Created by: Iced Computer
##  Last Modified 14 June 2019
## Some info taken from Pivpn & Pihole (launchers)
##

#What account?
read -p 'Which Client? ' USER

## VARS
HOME=~/ovpns
CLIENTDIR=$HOME/$USER
CCERT=$CLIENTDIR/${USER}.crt
CA=/etc/openvpn/easy-rsa/pki/ca.crt
CKEY=/etc/openvpn/easy-rsa/pki/${USER}.key
OVPNS=$HOME/${USER}.ovpn
OVPNF=$CLIENTDIR/${USER}.ovpn




## Setup
mkdir $CLIENTDIR
mv $OVPNS $CLIENTDIR/
cd $CLIENTDIR

#split OVPN file into components needed
cat $OVPNF|awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".temp"}'

sed '1,2d' $CLIENTDIR/cert1.temp > $CCERT

#clean up
rm $CLIENTDIR/cert.temp
rm $CLIENTDIR/cert1.temp
rm $CLIENTDIR/cert2.temp

openssl pkcs12 -export -in $CCERT -inkey $CKEY -certfile $CA -name $USER -out /$CLIENTDIR/${USER}.ovpn12

echo "#ifconfig-push 10.8.0.12 255.255.255.0" > /etc/openvpn/ccd/$USER
echo "CHECK YOUR CCD FOR IP ADDRESSES /etc/openvpn/ccd/{$USER}"

