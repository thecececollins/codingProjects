#! /bin/bash

APP_PATH="/Applications/Microsoft Remote Desktop.app"

if ! [ -d "$APP_PATH" ]; then
     jamf policy -trigger install-remotedesktop
fi
