#!/bin/bash
##############
# This is the removal script for the 30minAdminJss.sh script. 
# This will run two times. The first time it will remove the user from
# the admin group. The second time it will disable the plist that calls
# this script. The reason for the two runs is in testing I found it would
# not finish the policy trigger and never report back to JSS that it completed. 
# You will get a report back on the first run and then it will fail to report 
# back on the second run it will then disable itself. 
##############

if [[ -f /var/simpleit/userToRemove ]]; then
	U=`cat /var/simpleit/userToRemove`
	echo "removing" $U "from admin group"
	#dscl . -delete /Groups/admin GroupMembership $U
	/usr/sbin/dseditgroup -o edit -d $U -t user admin
	echo $U "has been removed from admin group"
	rm -f /var/simpleit/userToRemove
else
	defaults write /Library/LaunchDaemons/simple.jamf.adminremove.plist disabled -bool true
	echo "going to unload"
	launchctl unload -w /Library/LaunchDaemons/simple.jamf.adminremove.plist
	echo "Completed"
	rm -f /Library/LaunchDaemons/simple.jamf.adminremove.plist
fi

exit 0
