#!/bin/bash
################################################################################
#
#  NAME:
#    distributeBackupFiles.sh
#
#  SYNOPSIS:
#    sudo ./distributeBackupFiles.sh
#
#  DESCRIPTION:
#    The user will need to login to Google Drive and navigate to their Library
#    Backup folder. It will be located in Computers > My [Computer Model] > 
#    Documents > Tech Resources. They will then right-click on Library Backup
#    and select Download. The Library Backup folder will be zipped and downloaded
#    to the user's Downloads folder. When the download is complete, execute this 
#    script to unzip the downloaded Library Backup file and copy the housed 
#    folders to their respective counterparts in the user's ~/Library.
#
#  FOLDERS TO BE DISTRIBUTED:
#    Application Support/1Password 4
#    Application Support/Alfred 3
#    Application Support/Google
#    Application Support/TextExpander
#    Preferences
#    StickiesDatabase
#
################################################################################
#
#  HISTORY:
#    Version 1.0
#      Monroe Smith 25.06.2018
#
################################################################################


# Set some variables
LOGFILE="/Library/Logs/distributeBackupFiles.log"
USER=`ls -l /dev/console | awk '{print $3}'`

# Change to Downloads directory and unzip Library Backup file.
# Because Google attaches a random string of chars to the end of the zip's
# filename we'll use an asterisk since we don't know the exact name in advance.
cd ~/Downloads
unzip Library\ Backup*.zip

#Say What We're Doing
/bin/echo "`date`: Replacing folders with backup versions for $USER..." >> ${LOGFILE}

# Let The Distribution Commence!
cd Library\ Backup
cp -a Application\ Support/1Password\ 4/. ~/Library/Application\ Support/1Password\ 4/
cp -a Application\ Support/Alfred\ 3/. ~/Library/Application\ Support/Alfred\ 3/
cp -a Application\ Support/Google/. ~/Library/Application\ Support/Google/
cp -a Application\ Support/TextExpander/. ~/Library/Application\ Support/TextExpander/
cp -a Preferences/. ~/Library/Preferences/
cp -a StickiesDatabase ~/Library/
/bin/echo "`date`: Finished" >> ${LOGFILE}

# Cleanup Tasks
/bin/echo "`date`: Removing Library Backup folders from Downloads..." >> ${LOGFILE}
cd ~/Downloads
rm Library\ Backup*.zip
rm -rf Library\ Backup
