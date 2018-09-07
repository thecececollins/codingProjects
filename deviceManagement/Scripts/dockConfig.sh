#!/bin/sh
export PATH=/usr/local/bin:$PATH
sleep 5
#Removes unwanted default Dock Apps
dockutil --remove 'Mail' --allhomes
dockutil --remove 'Contacts' --allhomes
dockutil --remove 'Calendar' --allhomes
dockutil --remove 'Notes' --allhomes
dockutil --remove 'Maps' --allhomes
dockutil --remove 'FaceTime' --allhomes
dockutil --remove 'Messages' --allhomes
dockutil --remove 'Photos' --allhomes
dockutil --remove 'iTunes' --allhomes
dockutil --remove 'Reminders' --allhomes
dockutil --remove 'Keynote' --allhomes
dockutil --remove 'iBooks' --allhomes
dockutil --remove 'Safari' --allhomes
dockutil --remove 'Mail' --allhomes
#adds Applications to the Dock
dockutil --add /Applications/Self\ Service.app --after 'Launchpad' --allhomes
dockutil --add /Applications/1Password\ 6.app --after 'Settings' --allhomes
dockutil --add /Applications/Google\ Chrome.app --after '1Password 6' --allhomes
dockutil --add /Applications/Slack.app --after 'Google Chrome' --allhomes
dockutil --add /Applications/Alfred\ 3.app --after 'Slack' --allhomes
dockutil --add /Applications/Viscosity.app --after 'Alfred 3' --allhomes
dockutil --add '~/Documents' --before 'Downloads' --display folder --allhomes
