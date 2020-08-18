#!/bin/bash

#Vars

TEMPDIR=/scripts/temp


function swc()
{
        wget -O $TEMPDIR/someone.download 'http://someonewhocares.org/hosts/hosts'
        cat $TEMPDIR/someone.download | grep -v "ɢ" > $TEMPDIR/someone.download.fixed
        mv  $TEMPDIR/someone.download.fixed /var/www/html/alist.txt
        rm -f $TEMPDIR/someone.download
}

swc

              
