#!/bin/sh

# Set CocoaDialog Location
CD="/Applications/Utilities/CocoaDialog.app/Contents/MacOS/CocoaDialog"
SERIAL="$(ioreg -l | grep IOPlatformSerialNumber | sed -e 's/.*\"\(.*\)\"/\1/')"
MODEL=`ioreg -c IOPlatformExpertDevice | grep MacBook | awk -F"= " '/model/{ print $2 }' | sed -e 's/^..//;s/..$//;s/[0,-9]*//g'`


# Dialog to enter the computer name and the create $COMPUTERNAME variable
rv=($($CD standard-inputbox --title "User Name" --no-newline --informative-text "Please enter the primary username for this Mac."))
USERNAME=${rv[1]}


# Set Hostname using variable created above
scutil --set HostName "$USERNAME-$MODEL-$SERIAL"
scutil --set LocalHostName "$USERNAME-$MODEL-$SERIAL"
scutil --set ComputerName "$USERNAME-$MODEL-$SERIAL"

# Dialog to confirm that the hostname was changed and what it was changed to.
tb=`$CD ok-msgbox --text "Names Changed!" \
--informative-text "The computer name has been changed to $USERNAME-$MODEL-$SERIAL" \
--no-newline --float`
#if [ "$tb" == "1" ]; then
#echo "User said OK"
#jamf policy -trigger ADBind
#elif [ "$tb" == "2" ]; then
#echo "Canceling"
exit
