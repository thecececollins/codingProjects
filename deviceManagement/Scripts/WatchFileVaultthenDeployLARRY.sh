#!/bin/bash

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

if ! [ -f "/usr/local/outset/outset" ]; then
    jamf policy -trigger "install-outset2"
fi

LARRY_DEPLOY=$(cat <<'EOF'
#!/bin/bash
#sets the path for the jamf binary
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
STATUSCHECK=$(fdesetup status)
#installs the icons for the jamfhelper screen.
#jamf policy -event install-simpleicons
#runs a full screen jamfHelper window while encryting
#"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType fs -heading "Intial Setup in Progress" -alignHeading center -description "This machine will return to the login window when the setup is completed" -alignDescription center -icon /private/var/tmp/logo-rings.png &
#jamfHelperPID=$!
while [[ $STATUSCHECK == *"Encryption in progress"* ]]; do 
   sleep 1
   STATUSCHECK=$(fdesetup status)
done
if [[ $STATUSCHECK == "FileVault is On." ]]; then
  echo "Encryption complete"
  
  #Calls the create admin user policy workflow to remove ladmin
  jamf policy -event CreateAdminUser
 
  #Close the jamfHelper fullscreen
  #kill $jamfHelperPID
  #Return to the login window when process is completed. 
  kill -9 `pgrep loginwindow`
fi
rm /usr/local/outset/login-privileged-once/larry_deploy.sh
EOF
)

LARRY_DEPLOY_SCRIPT="/usr/local/outset/login-privileged-once/larry_deploy.sh"

printf "$LARRY_DEPLOY" > $LARRY_DEPLOY_SCRIPT
chown root:wheel $LARRY_DEPLOY_SCRIPT
chmod 755 $LARRY_DEPLOY_SCRIPT
