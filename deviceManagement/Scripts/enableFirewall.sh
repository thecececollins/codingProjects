#!/bin/bash

### Description
# This is an example to always enforce the Application layer Firewall

# enable firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# unload alf (firewall service)
sudo launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist

# load alf (firewall service)
sudo launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist

exit 0
