#!/bin/bash

# Uses Applescript to open a terminal and install Homebrew(for current user, instead of root)
osascript <<'EOF'
tell application "Terminal"
    activate
    do script ("/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"") in window 1
end tell
EOF

exit 0
