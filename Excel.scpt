#Text Bolding
set FindWordsToReplace to "This word" as text
tell application "Microsoft Word"
	set GetTxt to find object of selection
	tell GetTxt
	clear formatting
	set its content to FindWordsToReplace
	tell its replacement
	clear formatting
	set its content to FindWordsToReplace
	tell its font object
	set bold to true
end tell
end tell
	execute find wrap find find continue replace replace all with match forward and match whole word without match case
end tell
end tell

____ Delay script____
tell application "Microsoft Excel"
	delay 1
	quit
end tell


____ Open specific file___

do shell script "open ~/desktop/RetailStores.xls"

___ Copy Select text____

tell application "Microsoft Excel" to activate
tell application "System Events"
	tell process "Excel"
		tell menu bar 1
			click menu item "Copy" of menu "Edit"
		end tell
	end tell
end tell

____ Autosize cells___

tell application "Microsoft Excel"
	autofit columns of range "A:BT"
	autofit rows of range "A1:A25"
end tell

___ Dialog Display____

tell application "Microsoft Excel"
	display dialog "What is the store number?" default answer ""
	set storeNumber to text returned of theResult
	return storeNumber
end tell
