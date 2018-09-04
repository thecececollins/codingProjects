# Open Google Doc
tell application "Google Chrome"
	activate
	open location "https://docs.google.com/spreadsheets/d/1mymE8805JLMWhc9XGWN7PNCqQEd4f1v7aSBqeI1PuIg/edit#gid=1985560671"
end tell

delay 15


# Open new Excel document & paste text from Google Doc - set destination folder
set folderPath to "Macintosh HD:Users:username:Desktop:Scorecards:"

tell application "Microsoft Excel.app"
	set newWorkbook to make new «class X141»
end tell

delay 0.5

tell application "Microsoft Excel.app"
	activate
	tell application "System Events"
		tell process "Microsoft Excel"
			keystroke "v" using command down
			keystroke return
		end tell
	end tell
end tell

delay 0.5


# Delete rows 2-3
tell application "Microsoft Excel.app"
	set theWorkbook to «class 1172»
	tell «class XwSH» "Sheet1" of «class 1172»
		delete «class crow» "2:3"
	end tell
end tell


# Highlight & change font to size 10 and bold for row 1
tell application "Microsoft Excel.app"
	tell «class XftO» of «class X117» "A1:AD1" of «class X128» "Sheet1"
		set {«class bold», size} to {true, 10}
		tell «class XitO» of «class X117» "A1:AD1" of «class 1107»
			set «class 1098» to 6
		end tell
	end tell
end tell

# Center Align and wrap text row 1
tell application "Microsoft Excel.app"
	tell «class X117» "A1:AD1" of «class 1107»
		set «class 1575» to «constant e121ÔÙ»
		set «class 1631» to «constant e284´ÔÙ»
		set «class 1633» to true
	end tell
end tell

# Add filter to row 1
tell application "Microsoft Excel.app"
	tell «class 1107»
		select «class crow» "1:1"
	end tell
end tell

delay 1

tell application "System Events"
	tell process "Excel"
		click menu item "Filter" of menu 1 of menu bar item "Data" of menu bar 1
	end tell
end tell

delay 1


# Autofit width for row 1 titles and column B so the client names can be seen
tell application "Microsoft Excel.app"
	tell «class 1107»
		--enter your own custom range values like this:
		«event sTBL1524» «class ccol» "A1:AD1"
		«event sTBL1524» «class ccol» "B:B"
	end tell
end tell


# Hide columns C-H
tell application "Microsoft Excel.app"
	tell «class 1107»
		select «class crow» "C:H"
	end tell
end tell

tell application "System Events"
	tell process "Excel"
		click menu item "Hide" of menu 1 of menu item "Column" of menu 1 of menu bar item "Format" of menu bar 1
	end tell
end tell


# Freeze first row so titles are frozen
tell application "Microsoft Excel.app"
	tell «class 1107»
		select «class crow» "2:2"
	end tell
end tell

tell application "System Events"
	tell process "Excel"
		click menu item "Freeze Panes" of menu 1 of menu bar item "Window" of menu bar 1
	end tell
end tell


# Save and date file
tell application "Microsoft Excel.app"
	set today to (current date)
	«event smXLxSwA» newWorkbook given «class 5016»:(folderPath & "CS Scorecard" & " " & month of today & " " & day of today & ".xls")
end tell
