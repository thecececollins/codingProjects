#!/bin/bash


STATUSCHECK=$(fdesetup status)


while [[ $STATUSCHECK == *"Encryption in progress"* ]]; do 
   sleep 1
   STATUSCHECK=$(fdesetup status)
done
if [[ $STATUSCHECK == "FileVault is On." ]]; then
    jamf policy -event CreateAdminUser
fi
