#!/bin/sh

loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

sudo -u $loggedInUser defaults write com.apple.screensaver askForPassword 1
sudo -u $loggedInUser defaults write com.apple.screensaver askForPasswordDelay 0
sudo -u $loggedInUser defaults -currentHost write com.apple.screensaver idleTime 900
