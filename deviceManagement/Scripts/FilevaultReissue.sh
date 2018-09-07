#!/bin/bash

###
#
#            Name:  reissue_filevault_recovery_key.sh
#     Description:  This script is intended to run on Macs which no longer have
#                   a valid recovery key in the JSS. It prompts users to enter
#                   their Mac password, and uses this password to generate a
#                   new FileVault key and escrow with the JSS. The "redirect
#                   FileVault keys to JSS" configuration profile must already
#                   be deployed in order for this script to work correctly.
#          Author:  Elliot Jordan <elliot@elliotjordan.com>
#         Created:  2015-01-05
#      Modified by:  Chris Hewinson
#   Last Modified:  2017-09-27
#         Version:  1.8.1
#
###


################################## VARIABLES ##################################

# Your company's logo, in PNG format. (For use in jamfHelper messages.)
LOGO_PNG="/private/var/tmp/logo-rings.png"

# Your company's logo, in ICNS format. (For use in AppleScript messages.)
LOGO_ICNS="/private/var/tmp/logo-rings.icns"

# The title of the message that will be displayed to the user.
# Not too long, or it'll get clipped.
PROMPT_TITLE="Encryption Key Escrow"

# The body of the message that will be displayed before prompting the user for
# their password. All message strings below can be multiple lines.
PROMPT_MESSAGE="Your Mac's FileVault encryption key needs to be regenerated in order for Simple IT to be able to recover your hard drive in case of emergency.
Click the Next button below, then enter your Mac's password when prompted. If you have questions feel free to contact us on Slack in #ithelp."

# The body of the message that will be displayed after 5 incorrect passwords.
FORGOT_PW_MESSAGE="You made five incorrect password attempts.
Please contact IT on Slack in the #ithelp channel for help with your Mac password."

# The body of the message that will be displayed after successful completion.
SUCCESS_MESSAGE="Your key has been repaired and successfully escrowed to Simple. If you have questions feel free to contact us on Slack in #ithelp."

# The body of the message that will be displayed if a failure occurs.
FAIL_MESSAGE="Sorry, an error occurred while escrowing your FileVault key. Please contact IT on Slack in the #ithelp channel"

# Optional but recommended: The profile identifier of the FileVault Key
# Redirection profile (e.g. ABCDEF12-3456-7890-ABCD-EF1234567890).
PROFILE_IDENTIFIER="F91E4DF1-B36B-4F26-920A-5CCA2664ED47"


###############################################################################
######################### DO NOT EDIT BELOW THIS LINE #########################
###############################################################################


######################## VALIDATION AND ERROR CHECKING ########################

# Suppress errors for the duration of this script. (This prevents JAMF Pro from
# marking a policy as "failed" if the words "fail" or "error" inadvertently
# appear in the script output.)
exec 2>/dev/null

BAILOUT=false

# Make sure we have root privileges (for fdesetup).
if [[ $EUID -ne 0 ]]; then
    REASON="This script must run as root."
    BAILOUT=true
fi

# Check for remote users.
REMOTE_USERS=$(/usr/bin/who | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | wc -l)
if [[ $REMOTE_USERS -gt 0 ]]; then
    REASON="Remote users are logged in."
    BAILOUT=true
fi

# Make sure the custom logo file is present.
if [[ ! -f "$LOGO" ]]; then
    REASON="Custom logo not present: $LOGO"
    BAILOUT=true
fi

# Convert POSIX path of logo icon to Mac path for AppleScript
LOGO_POSIX="$(/usr/bin/osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO"'" as text')"

# Bail out if jamfHelper doesn't exist.
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
if [[ ! -x "$jamfHelper" ]]; then
    REASON="jamfHelper not found."
    BAILOUT=true
fi

# Most of the code below is based on the JAMF reissueKey.sh script:
# https://github.com/JAMFSupport/FileVault2_Scripts/blob/master/reissueKey.sh

# Check the OS version.
OS_MAJOR=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}')
OS_MINOR=$(/usr/bin/sw_vers -productVersion | awk -F . '{print $2}')
if [[ "$OS_MAJOR" -ne 10 || "$OS_MINOR" -lt 9 ]]; then
    REASON="OS version not 10.9+ or OS version unrecognized."
    sw_vers -productVersion
    BAILOUT=true
elif [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -ge 13 ]]; then
    echo "[WARNING] This script is still in BETA in High Sierra, because the fdesetup binary has changed significantly. Please use with caution."
fi

# Check to see if the encryption process is complete
FV_STATUS="$(/usr/bin/fdesetup status)"
if grep -q "Encryption in progress" <<< "$FV_STATUS"; then
    REASON="The encryption process is still in progress."
    echo "$FV_STATUS"
    BAILOUT=true
elif grep -q "FileVault is Off" <<< "$FV_STATUS"; then
    REASON="Encryption is not active."
    echo "$FV_STATUS"
    BAILOUT=true
elif ! grep -q "FileVault is On" <<< "$FV_STATUS"; then
    REASON="Unable to determine encryption status."
    echo "$FV_STATUS"
    BAILOUT=true
fi

# Get the logged in user's name
CURRENT_USER=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# This first user check sees if the logged in account is already authorized with FileVault 2
FV_USERS="$(/usr/bin/fdesetup list)"
if ! egrep -q "^${CURRENT_USER}," <<< "$FV_USERS"; then
    REASON="$CURRENT_USER is not on the list of FileVault enabled users:"
    echo "$FV_USERS"
    BAILOUT=true
fi

# If specified, the FileVault key redirection profile needs to be installed.
if [[ "$PROFILE_IDENTIFIER" != "" ]]; then
    /usr/bin/profiles -Cv | grep -q "profileIdentifier: $PROFILE_IDENTIFIER"
    if [[ $? -ne 0 ]]; then
        REASON="The FileVault Key Redirection profile is not yet installed."
        BAILOUT=true
    fi
fi


################################ MAIN PROCESS #################################

# Get information necessary to display messages in the current user's context.
USER_ID=$(/usr/bin/id -u "$CURRENT_USER")
if [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -le 9 ]]; then
    L_ID=$(/usr/bin/pgrep -x -u "$USER_ID" loginwindow)
    L_METHOD="bsexec"
elif [[ "$OS_MAJOR" -eq 10 && "$OS_MINOR" -gt 9 ]]; then
    L_ID=$USER_ID
    L_METHOD="asuser"
fi

# If any error occurred in the validation section, bail out.
if [[ "$BAILOUT" == "true" ]]; then
    echo "[ERROR]: $REASON"
    launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$FAIL_MESSAGE: $REASON." -button1 'OK' -defaultButton 1 -startlaunchd &>/dev/null &
    exit 1
fi

# Display a branded prompt explaining the password prompt.
echo "Alerting user $CURRENT_USER about incoming password prompt..."
/bin/launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$PROMPT_MESSAGE" -button1 "Next" -defaultButton 1 -startlaunchd &>/dev/null

# Get the logged in user's password via a prompt.
echo "Prompting $CURRENT_USER for their Mac password..."
USER_PASS="$(/bin/launchctl "$L_METHOD" "$L_ID" /usr/bin/osascript -e 'display dialog "Please enter the password you use to log in to your Mac:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_POSIX//\"/\\\"}"'"' -e 'return text returned of result')"

# Thanks to James Barclay (@futureimperfect) for this password validation loop.
TRY=1
until /usr/bin/dscl /Search -authonly "$CURRENT_USER" "$USER_PASS" &>/dev/null; do
    (( TRY++ ))
    echo "Prompting $CURRENT_USER for their Mac password (attempt $TRY)..."
    USER_PASS="$(/bin/launchctl "$L_METHOD" "$L_ID" /usr/bin/osascript -e 'display dialog "Sorry, that password was incorrect. Please try again:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_POSIX//\"/\\\"}"'"' -e 'return text returned of result')"
    if (( TRY >= 5 )); then
        echo "[ERROR] Password prompt unsuccessful after 5 attempts. Displaying \"forgot password\" message..."
        /bin/launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$FORGOT_PW_MESSAGE" -button1 'OK' -defaultButton 1 -startlaunchd &>/dev/null &
        exit 1
    fi
done
echo "Successfully prompted for Mac password."

# If needed, unload and kill FDERecoveryAgent.
if /bin/launchctl list | grep -q "com.apple.security.FDERecoveryAgent"; then
    echo "Unloading FDERecoveryAgent LaunchDaemon..."
    /bin/launchctl unload /System/Library/LaunchDaemons/com.apple.security.FDERecoveryAgent.plist
fi
if pgrep -q "FDERecoveryAgent"; then
    echo "Stopping FDERecoveryAgent process..."
    killall "FDERecoveryAgent"
fi

# Translate XML reserved characters to XML friendly representations.
USER_PASS=${USER_PASS//&/&amp;}
USER_PASS=${USER_PASS//</&lt;}
USER_PASS=${USER_PASS//>/&gt;}
USER_PASS=${USER_PASS//\"/&quot;}
USER_PASS=${USER_PASS//\'/&apos;}

# For 10.13's escrow process, store the last modification time of /var/db/FileVaultPRK.dat
if [[ "$OS_MINOR" -ge 13 ]]; then
    echo "Checking for /var/db/FileVaultPRK.dat on macOS 10.13+..."
    PRK_MOD=0
    if [ -e "/var/db/FileVaultPRK.dat" ]; then
        echo "Found existing personal recovery key."
        PRK_MOD=$(/usr/bin/stat -f "%Sm" -t "%s" "/var/db/FileVaultPRK.dat")
    fi
fi

echo "Issuing new recovery key..."
FDESETUP_OUTPUT="$(/usr/bin/fdesetup changerecovery -norecoverykey -verbose -personal -inputplist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Username</key>
    <string>$CURRENT_USER</string>
    <key>Password</key>
    <string>$USER_PASS</string>
</dict>
</plist>
EOF
)"

# Clear password variable.
unset USER_PASS

# Test success conditions.
FDESETUP_RESULT=$?
# Differentiate <=10.12 and >=10.13 success conditions
if [[ "$OS_MINOR" -ge 13 ]]; then
    # Check new modification time of of FileVaultPRK.dat
    ESCROW_STATUS=1
    if [ -e "/var/db/FileVaultPRK.dat" ]; then
        NEW_PRK_MOD=$(/usr/bin/stat -f "%Sm" -t "%s" "/var/db/FileVaultPRK.dat")
        if [[ $NEW_PRK_MOD -gt $PRK_MOD ]]; then
            ESCROW_STATUS=0
            echo "Recovery key updated locally and available for collection via MDM."
        else
            echo "[WARNING] The recovery key does not appear to have been updated locally."
        fi
    fi
else
    # Check output of fdesetup command for indication of an escrow attempt
    grep -q "Escrowing recovery key..." <<< "$FDESETUP_OUTPUT"
    ESCROW_STATUS=$?
fi

if [[ $FDESETUP_RESULT -ne 0 ]]; then
    [[ -n "$FDESETUP_OUTPUT" ]] && echo "$FDESETUP_OUTPUT"
    echo "[WARNING] fdesetup exited with return code: $FDESETUP_RESULT."
    echo "See this page for a list of fdesetup exit codes and their meaning:"
    echo "https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man8/fdesetup.8.html"
    echo "Displaying \"failure\" message..."
    /bin/launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$FAIL_MESSAGE: fdesetup exited with code $FDESETUP_RESULT. Output: $FDESETUP_OUTPUT" -button1 'OK' -defaultButton 1 -startlaunchd &>/dev/null &
elif [[ $ESCROW_STATUS -ne 0 ]]; then
    [[ -n "$FDESETUP_OUTPUT" ]] && echo "$FDESETUP_OUTPUT"
    echo "[WARNING] FileVault key was generated, but escrow cannot be confirmed. Please verify that the redirection profile is installed and the Mac is connected to the internet."
    echo "Displaying \"failure\" message..."
    /bin/launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$FAIL_MESSAGE: New key generated, but escrow did not occur." -button1 'OK' -defaultButton 1 -startlaunchd &>/dev/null &
else
    [[ -n "$FDESETUP_OUTPUT" ]] && echo "$FDESETUP_OUTPUT"
    echo "Displaying \"success\" message..."
    /bin/launchctl "$L_METHOD" "$L_ID" "$jamfHelper" -windowType "utility" -icon "$LOGO" -title "$PROMPT_TITLE" -description "$SUCCESS_MESSAGE" -button1 'OK' -defaultButton 1 -startlaunchd &>/dev/null &
fi

exit $FDESETUP_RESULT
