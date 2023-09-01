#!/bin/bash
## Deploys MFA to server
## Updated 7/27/2020
## MFA.sh


function MFA()
{
# Get MFA
apt install libpam-google-authenticator
wait
}

function config()
{
# Get MFA
bash -c 'echo "auth required pam_google_authenticator.so" >> /etc/pam.d/common-session'
wait
sed -i "s/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart ssh
# for a Pi
service ssh restart

echo "RUN google-authenticator as the user before you logout!"
}

MFA
config