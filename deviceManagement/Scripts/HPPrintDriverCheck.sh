#! /bin/bash

if ! pkgutil --pkgs=com.apple.pkg.HewlettPackardPrinterDrivers; then
jamf policy -id 252 

fi
