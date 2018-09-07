#!/bin/sh

#This must be set to if you are going to allow non-admin access to any of the preference panes.
security authorizationdb write system.preferences allow

# enable non-admin access to the Date and time prefrence panes
security authorizationdb write system.preferences.datetime allow

## enable network Prefs
security authorizationdb write system.preferences.network allow
security authorizationdb write system.services.systemconfiguration.network allow

# enable non-admin access to the time machine prefrences
security authorizationdb write system.preferences.timemachine allow

exit 0
