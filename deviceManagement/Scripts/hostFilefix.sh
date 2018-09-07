#!/bin/bash
HOSTSFILE='/private/etc/hosts'

#Check host file for fiserv1.prod.banksimple.com
if grep -q fiserv1.prod $HOSTSFILE ; then
	echo 'Found an entry'
else
	echo '127.0.0.1       fiserv1.prod.banksimple.com' >> $HOSTSFILE
fi

if grep -q fdwc1.part $HOSTSFILE ; then
	echo 'Found an entry'
else
	echo '127.0.0.1       fdwc1.part.banksimple.com' >> $HOSTSFILE
fi
