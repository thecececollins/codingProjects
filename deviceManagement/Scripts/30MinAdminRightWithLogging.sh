#!/bin/sh

##############
# This script will give a user 30 minutes of Admin level access, from Jamf's self service.
# At the end of the 30 minutes it will then call a jamf policy with a manual trigger. 
# Remove the users admin rights and disable the plist file this creates and activites.
# The removal script is 30minAdminjssRemoved.sh
##############




U=`who |grep console| awk '{print $1}'`


# Message to user they have admin rights for 30 min. 

osascript -e 'set T to text returned of (display dialog "Please log the reason for requesting admin rights.
After submitting your reason and clicking OK you will have 30 minutes of admin rights!" buttons {"Cancel", "OK"} default button "OK" default answer "")'
		

# Check status of osascript
if [ "$?" != "0" ] ; then
   echo "User aborted. Exiting..."
   exit 0
fi


# Place launchD plist to call JSS policy to remove admin rights.
#####
echo "<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> 
<plist version="1.0"> 
<dict>
	<key>Disabled</key>
	<true/>
	<key>Label</key> 
	<string>simple.jamf.adminremove</string> 
	<key>ProgramArguments</key> 
	<array> 
		<string>/usr/local/bin/jamf</string>
		<string>policy</string>
		<string>-trigger</string>
		<string>adminremove</string>
	</array>
	<key>StartInterval</key>
	<integer>1800</integer> 
</dict> 
</plist>" > /Library/LaunchDaemons/simple.jamf.adminremove.plist
#####

#set the permission on the file just made.
chown root:wheel /Library/LaunchDaemons/simple.jamf.adminremove.plist
chmod 644 /Library/LaunchDaemons/simple.jamf.adminremove.plist
defaults write /Library/LaunchDaemons/simple.jamf.adminremove.plist disabled -bool false

# load the removal plist timer. 
launchctl load -w /Library/LaunchDaemons/simple.jamf.adminremove.plist

# build log files in var/simpleit
mkdir /var/simpleit
TIME=`date "+Date:%m-%d-%Y TIME:%H:%M:%S"`
echo $TIME " by " $U >> /var/simpleit/30minAdmin.txt

echo $U >> /var/simpleit/userToRemove

# give current logged user admin rights
/usr/sbin/dseditgroup -o edit -a $U -t user admin



exit 0
