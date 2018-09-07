#!/bin/bash
################################################################################
#
#  NAME:
#    userLibraryBackup.sh
#
#  DESCRIPTION:
#    Google's Backup & Sync is unable to backup the user's Library folder
#    because it doesn't have the write access required to sync the Library
#    folder to Google Drive. 
#    
#    This script makes a copy of the specified folders within the Library 
#    folder and places the copies in the ~/Documents/Tech Resources
#    folder. Backup & Sync is then able to sync the copied Library folders 
#    to Google Drive. Note that the user will have read-only access to the
#    Tech Resources folder ensuring they do not accidentally delete the backup.
#
#    The script will be auto-installed on all Simple managed devices using JAMF.
#
#    When run the first time, the script copies the full contents of each fodler
#    listed below. Subsequent runs will only write modifications since the last
#    sync to the destination folder.
#
#  FOLDERS TO BE SYNCED:
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

 Set some variables
LOGFILE="/Library/Logs/userLibraryBackup.log"
USER=`ls -l /dev/console | awk '{print $3}'`

# Grants write permissions to Tech Resources folder in order for next command to run
chmod -R a+w ~/Documents/Tech\ Resources/
chmod -R 775 /Library/Logs/

# Adds a cronjob to run userLibraryBackup if cronjob doesn't already exist

# Checks if Library Backup directory exists. Creates the directory if it's absent.
if [ -d "Library\ Backup" ]; then
mkdir ~/Documents/Tech\ Resources/Library\ Backup
/bin/echo "`date`: Creating Library Backup in Tech Resources... SUCCESS" >> ${LOGFILE}
else
/bin/echo "`date`: Library Backup exists in Tech Resources... TRUE" >> ${LOGFILE}
fi

# Let The Syncing Commence!
rsync -avr ~/Library/Application\ Support/1Password\ 4/. ~/Documents/Tech\ Resources/Library\ Backup/Application\ Support/1Password\ 4
/bin/echo "`date`: Syncing 1Password folder... SUCCESS" >> ${LOGFILE}

rsync -avr ~/Library/Application\ Support/Alfred\ 3/. ~/Documents/Tech\ Resources/Library\ Backup/Application\ Support/Alfred\ 3
/bin/echo "`date`: Syncing Alfred folder... SUCCESS" >> ${LOGFILE}

rsync -avr ~/Library/Application\ Support/Google/. ~/Documents/Tech\ Resources/Library\ Backup/Application\ Support/Google
/bin/echo "`date`: Syncing Google folder... SUCCESS" >> ${LOGFILE}

rsync -avr ~/Library/Application\ Support/TextExpander/. ~/Documents/Tech\ Resources/Library\ Backup/Application\ Support/TextExpander
/bin/echo "`date`: Syncing TextExpander folder... SUCCESS" >> ${LOGFILE}

rsync -avr ~/Library/Preferences/. ~/Documents/Tech\ Resources/Library\ Backup/Preferences
/bin/echo "`date`: Syncing Preferences folder... SUCCESS" >> ${LOGFILE}

rsync -avr ~/Library/StickiesDatabase ~/Documents/Tech\ Resources/Library\ Backup/StickiesDatabase
/bin/echo "`date`: Syncing StickiesDatabase file... SUCCESS" >> ${LOGFILE}
/bin/echo "`date`: Sync has finished!" >> ${LOGFILE}
