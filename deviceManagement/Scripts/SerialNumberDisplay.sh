#!/bin/sh
#Display serial number of the computer

serial=`ioreg -l | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }'`

if [ "$serial" != "" ]; then

echo "$serial" | pbcopy

title="Computer serial number"

button1="OK"

description="$serial has been copied to
your clipboard
use the Command + V keys to paste"

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

"$jamfHelper" -windowPosition center -windowType hud -heading "$heading" -title "$title" -description "$description" -button1 "$button1" &

fi
