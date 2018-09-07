#!/bin/sh

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Created by Sepie Moinipanah
# February 6, 2018
# Credit: Joe Farage, March 18, 2015 (Version: 1.0)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Language Variables & Parameters
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Specify "en-US", "fr" or "de" otherwise default value is set to "en-US"
lang=""

# Check to see if a value was passed in parameter 4 and, if so, assign it to "lang"

if [[ "$4" != "" ]] && [[ "$lang" == "" ]]; then
	lang=$4
else 
	lang="en-US"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Miscellaneous Variables
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

dmgfile="FF.dmg"
logfile="/Library/Logs/FirefoxInstallScript.log"
intelCheck=$(/usr/bin/uname -p)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# Intel System Check
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

if [[ $intelCheck == "i386" ]] || [[ $intelCheck == "x86_64" ]]; then
	# Verify OS version and adjust for use with the URL string.
	OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )

	## Set the User Agent string for use with curl
	userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

	# Get the latest available version of Firefox directly from Mozilla.
	latestver=`/usr/bin/curl -s -A "$userAgent" https://www.mozilla.org/${lang}/firefox/new/ | grep 'data-latest-firefox' | sed -e 's/.* data-latest-firefox="\(.*\)".*/\1/' -e 's/\"//' | /usr/bin/awk '{print $1}'`
	echo "$(date): Latest Version is: $latestver"

	# Get the version number of the currently installed Firefox.
	if [[ -e "/Applications/Firefox.app" ]]; then
		currentinstalledver=`/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString`
		echo "Current installed version is: $currentinstalledver"
		if [[ ${latestver} = ${currentinstalledver} ]]; then
			echo "$(date): Firefox is up to date! Now exiting..."
			exit 0
		fi
	else
		currentinstalledver="None"
		echo "$(date): Firefox is NOT installed!"
	fi

	url="https://download-installer.cdn.mozilla.net/pub/firefox/releases/${latestver}/mac/${lang}/Firefox%20${latestver}.dmg"
	
	echo "$(date): Latest version of the URL is: $url"
	echo "$(date): Download URL: $url" >> ${logfile}

	# Compare the two versions and if they are different or Firefox is not present, then download and install the new version.
	if [[ "${currentinstalledver}" != "${latestver}" ]]; then
        echo "$(date): Current Firefox version: ${currentinstalledver}" >> ${logfile}
		echo "$(date): Available Firefox version: ${latestver}" >> ${logfile}
		echo "$(date): Downloading newer version." >> ${logfile}
		/usr/bin/curl -s -o /tmp/${dmgfile} ${url}
		echo "$(date): Mounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
		echo "$(date): Installing..." >> ${logfile}
		ditto -rsrc "/Volumes/Firefox/Firefox.app" "/Applications/Firefox.app"
		
		/bin/sleep 10
		echo "$(date): Unmounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep Firefox | awk '{print $1}') -quiet
		/bin/sleep 10
		echo "$(date): Deleting disk image." >> ${logfile}
		/bin/rm /tmp/${dmgfile}
		
		# Verify if new version was successfully installed.
		newlyinstalledver=`/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString`
        if [[ "${latestver}" = "${newlyinstalledver}" ]]; then
            echo "$(date): SUCCESS: Firefox has been updated to version ${newlyinstalledver}" >> ${logfile}
	    else
            echo "$(date): ERROR: Firefox update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
            echo "--" >> ${logfile}
			exit 1
		fi
    
	# If Firefox is already updated, write to the log file and exit.       
	else
		echo "$(date): Firefox is already up to date, running ${currentinstalledver}." >> ${logfile}
        echo "--" >> ${logfile}
	fi	
else
	echo "$(date): ERROR: This script is for Intel Macs only." >> ${logfile}
fi

exit 0
