#!/bin/bash

#Google Backup & Sync is unable to backup the user’s Library folder because the user doesn’t have write access required to sync the Library folder to Google Drive.
#solution is to run this script, which makes a copy of the user’s Library folder (does not require write access) and places the copy into the user’s Documents folder.
#documents folder is one of the few that Google Backup & Sync is capable of backing up to the user’s Google Drive.

#this script will be executed using a crontab

#when ran the first time, creates an entire backup of the user’s Library folder to the destination Library_Backup.
#However, each time the script is run subsequently, it only writes modifications since the last sync to the destination folder, rather than writing an entire new copy.
rsync -avr ~/Library/ ~/Documents/localDataBackup/userLibrary
