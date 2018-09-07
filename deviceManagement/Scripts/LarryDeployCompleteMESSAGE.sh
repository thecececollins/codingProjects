#!/bin/bash


jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
LOGO_PNG="/private/var/tmp/logo-rings.png"
LOGO_ICNS="/private/var/tmp/logo-rings.icns"
PROMPT_HEADING="Alert!"
PROMPT_MESSAGE=" Admin rights have been removed on this computer"

"$jamfHelper" -windowType hud -windowPosition ur -lockHUD -icon "$LOGO_PNG" -heading "$PROMPT_HEADING" -description "$PROMPT_MESSAGE" -button1 "I understand!" -defaultButton 1
