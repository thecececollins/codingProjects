#! /bin/bash

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin

if ! [ -f "/usr/local/outset/outset" ]; then
    jamf policy -trigger "install-outset2"
fi

CONFIG_CHROME=$(cat <<'EOF'
#! /bin/bash
open -a "Google Chrome" --args --make-default-browser
rm config-chrome.sh
EOF
)

CONFIG_CHROME_SCRIPT="/usr/local/outset/login-once/config-chrome.sh"

    printf "$CONFIG_CHROME" > $CONFIG_CHROME_SCRIPT
    chown root:wheel $CONFIG_CHROME_SCRIPT
    chmod 755 $CONFIG_CHROME_SCRIPT
