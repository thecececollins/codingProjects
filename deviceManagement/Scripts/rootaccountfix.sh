#!/bin/bash

ERROR=0

# Set root password to random long password

rootpassword=$(openssl rand -base64 32)

/usr/bin/dscl . -passwd /Users/root "$rootpassword"

# Disable root login by setting root's shell to /usr/bin/false.
# The original UserShell value is as follows:
#
# /bin/sh
#
# To revert it back to /bin/sh, run the following command:
# /usr/bin/dscl . -change /Users/root UserShell /usr/bin/false /bin/sh

rootshell=$(/usr/bin/dscl . -read /Users/root UserShell | awk '{print $2}')

if [[ -z "$rootshell" ]]; then
   echo "Setting blank root shell to /usr/bin/false"
   /usr/bin/dscl . -create /Users/root UserShell /usr/bin/false
else
   echo "Changing root shell from $rootshell to /usr/bin/false"
   /usr/bin/dscl . -change /Users/root UserShell "$rootshell" /usr/bin/false
fi

exit "$ERROR"
