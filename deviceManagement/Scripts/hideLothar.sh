#!/bin/sh

\# check if the <name of admin account> directory is present
if [ -d /Users/<lothar> ]; then
dscl . -create /Users/<lothar> UniqueID 401
chown -R <lothar> /Users/<lothar>
defaults write /Library/Preferences/com.apple.loginwindow Hide500Users -bool YES
mv /Users/<lothar>/ /var/<lothar>/
dscl . -create /Users/<lothar> NFSHomeDirectory /var/<name of admin account>
else
exit
fi
