#!/bin/bash
Serial_Number=$(ioreg -l | awk '/IOPlatformSerialNumber/ { print $4;}')
#grabs the serial number from the computer
ID_Number=$(curl  -q -H "token:ab8ee29031f64cd9176d02caf1b0f5c9" -X GET \
      -d "search=$Serial_Number" \
    https://simple.ezofficeinventory.com/search.api 2> /dev/null| grep -o '"identifier":"[0-9]*"' | cut -d : -f 2 | tr -d '"' )
echo $ID_Number
#uses the ezofficeinventory API to curl the serial number up and search through and parse the results to just get the serial number.

jamf recon -assetTag $ID_Number
#uses jamfs built in tool to upload the serial number grabbed from ezoffice.
