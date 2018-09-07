#!/bin/bash
##############
# This script will give a user 30 minutes of Admin level access, from Jamf's self service.
# At the end of the 30 minutes it will then call a jamf policy with a manual trigger. 
# Remove the users admin rights and disable the plist file this creates and activites.
# The removal script is 30minAdminjssRemoved.sh
##############

# HARDCODED VALUES SET HERE
apiUser=""
apiPass=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "apiUser"
if [ "$4" != "" ] && [ "$apiUser" == "" ];then
apiUser=$4
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "apiPass"
if [ "$5" != "" ] && [ "$apiPass" == "" ];then
apiPass=$5
fi

apiURL="https://simple.jamfcloud.com"
U=`who |grep console| awk '{print $1}'`

# Message to user they have admin rights for 30 min. 
/usr/bin/osascript <<-EOF
			    tell application "System Events"
			        activate
			        display dialog "You now have admin rights to this machine for 30 minutes" buttons {"Ok!"} default button 1
			    end tell
			EOF

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

#Remove User from policy
serialNumber=`ioreg -l | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }'`

apiData="<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?><computer_group><computer_deletions><computer><serial_number>$serialNumber</serial_number></computer></computer_deletions></computer_group>"

/usr/bin/curl -s -u ${apiUser}:${apiPass} -X PUT -H "Content-Type: application/xml" -d "${apiData}" "$apiURL/JSSResource/computergroups/id/312"


exit 0
