#!/bin/sh
pwpolicy -n /Local/Default -setglobalpolicy "requiresAlpha=1 requiresNumeric=1 minChars=8 passwordCannotBeName=1 requiresMixedCase=1 usingHistory=4"
exit 0
