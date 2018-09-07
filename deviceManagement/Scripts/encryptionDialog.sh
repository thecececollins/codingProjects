#! /bin/bash

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

if ! [ -f "/usr/local/outset/outset" ]; then
    jamf policy -trigger "install-outset"
fi

ENCRYPTION_CHECK=$(cat <<'EOF'
#!/bin/bash
STATUSCHECK=$(fdesetup status)
while [[ $STATUSCHECK == *"Encryption in progress"* ]]; do 
   sleep 1
   STATUSCHECK=$(fdesetup status)
done
if [[ $STATUSCHECK == "FileVault is On." ]]; then
   osascript -e 'display dialog "Filevault has finished encrypting your computer. It is now safe to use."'
fi
rm /usr/local/outset/login-once/encryption_check.sh
EOF
)

ENCRYPTION_CHECK_SCRIPT="/usr/local/outset/login-once/encryption_check.sh"

printf "$ENCRYPTION_CHECK" > $ENCRYPTION_CHECK_SCRIPT
chown root:wheel $ENCRYPTION_CHECK_SCRIPT
chmod 755 $ENCRYPTION_CHECK_SCRIPT
