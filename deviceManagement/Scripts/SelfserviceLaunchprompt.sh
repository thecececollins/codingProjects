#!/bin/sh
# Script to prompt to open self service

jhPath="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

Title="$4"
Heading="$5"
Desc1="$6"
Desc2="$7"
Icon="$8"

Msg="$Desc1
$Desc2"

SelfServ=`"$jhPath" -windowType hud -title "$Title" -heading "$Heading" -description "$Msg" -button1 "Install" -button2 "Cancel" -defaultButton 1 -cancelButton 2 -icon "$Icon"`

if [ $SelfServ == 0 ]; then
    osascript -e 'tell application "Self Service"' -e "activate" -e 'end tell'
fi
