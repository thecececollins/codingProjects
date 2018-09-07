#!/bin/bash
#
# postinstall-profileInstaller.sh

for mobileconfig in /tmp/profiles/* ; do
    profiles -I -F "${mobileconfig}"
done

rm -R /tmp/profiles/

exit 0
