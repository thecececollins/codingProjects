#!/bin/bash
## No COMMENTS 
##BEN MARTEL DON'T STEAL
localUsers=$(dscl . list /Users UniqueID | awk '$2 > 500 && $2 < 1000 {print $1}' | grep -v simpleit)
MODEL=$(sysctl -n hw.model | tr -d '[:digit:][:punct:]'  | sed 's/Pro/ Pro/' | sed 's/mini/ mini/' | sed 's/Air/ Air/')

for u in ${localUsers} ; do
    realname=$( dscl . read /Users/${u} RealName | grep -v RealName | sed -e 's/^ //' )
[[ -n $realname ]] ; 

scutil --set ComputerName "${realname}'s ${MODEL}"
scutil --set HostName "${realname}'s ${MODEL}"
jamf recon
done
