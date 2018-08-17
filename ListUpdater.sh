#!/bin/bash

#Vars

TEMPDIR=/scripts/temp

function malcode()
{
        wget -O $TEMPDIR/Bootlist 'https://malc0de.com/bl/BOOT'
        cat $TEMPDIR/Bootlist | grep -v // | cut -d" " -f 2 > $TEMPDIR/checklist.txt
        mv $TEMPDIR/checklist.txt /var/www/html/bootlist.txt
        rm -f $TEMPDIR/Bootlist
}

function openfish()
{
        wget -O $TEMPDIR/openfish.download 'https://openphish.com/feed.txt'
        cat $TEMPDIR/openfish.download | cut -d "/" -f 3 | grep -vE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -xvf /scripts/Archive/Filters/safesites.txt | sort | uniq > $TEMPDIR/openphish_feed.txt
        mv $TEMPDIR/openphish_feed.txt  /var/www/html/openphish_feed.txt
        rm -f $TEMPDIR/openfish.download
}

function phishtank()
{
        wget -O  $TEMPDIR/phishtank.download 'https://data.phishtank.com/data/online-valid.csv'
        cat $TEMPDIR/phishtank.download | cut -d ',' -f 2 | cut -d "/" -f 3  | grep -vE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -xvf /scripts/Archive/Filters/safesites.txt | grep -v ? | sort | uniq > $TEMPDIR/phishtank_feed.txt
        mv $TEMPDIR/phishtank_feed.txt /var/www/html/phishtank_feed.txt
        rm -f $TEMPDIR/phishtank.download
}

function swc()
{
        wget -O $TEMPDIR/someone.download 'http://someonewhocares.org/hosts/hosts'
        cat $TEMPDIR/someone.download | grep -v "ɢ" > $TEMPDIR/someone.download.fixed
        mv  $TEMPDIR/someone.download.fixed /var/www/html/alist.txt
        rm -f $TEMPDIR/someone.download
}

function ezlist()
{

        wget -O $TEMPDIR/ezlist.download 'https://easylist-downloads.adblockplus.org/easylist.txt'
        cat $TEMPDIR/ezlist.download | grep  '||' | grep -v @ | cut -d "/" -f 1 | cut -d "^" -f 1 | cut -d "|" -f 3 | grep -vxf /etc/pihole/whitelist.txt |  grep -vE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -xvf /scripts/Archive/Filters/safesites.txt | sort | uniq > $TEMPDIR/ezlist.txt
        mv $TEMPDIR/ezlist.txt /var/www/html/ezlist.txt
        rm -f $TEMPDIR/ezlist.download
}
malcode
openfish
phishtank
swc
#ezlist
              
