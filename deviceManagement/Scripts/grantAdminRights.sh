#!/bin/bash
#Give the user back their admin rights!

#Grabs the current logged in user.
U=`who |grep console| awk '{print $1}'`

#Gives the Current user admin rights
/usr/sbin/dseditgroup -o edit -a $U -t user admin

exit 0
