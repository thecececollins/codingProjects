#!/bin/bash

if [ -f /Users/$3/Library/Application\ Support/Google/Chrome/Default/Preferences ];then
    echo "Google Chrome Preferences file already exists. Exiting..."
    exit 0
fi

if [ ! -d "/Library/Google" ]
then
    mkdir "/Library/Google"
fi

(
sudo cat <<'EOD'
{
	"bookmark_bar": {
		"show_on_all_tabs": true
	},
	"sync_promo": {
		"show_on_first_run_allowed": false,
		"user_skipped": true
	},
	"distribution": {
		"import_bookmarks_from_file": "/Library/Google/Simplebookmarks_05_23_17.html",
		"make_chrome_default": true,
		"suppress_first_run_bubble": true
	}	
}
EOD
) > "/Library/Google/Google Chrome Master Preferences"
