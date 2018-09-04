
		set {wrap text} to {true}
		set color of interior object to {141, 180, 226}

tell font object of range "C:H" of sheet "Sheet1"
		set hidden of range "C:H" to true


	set myColumn to range "C:H"
		set hidden of myColumn to true


set hidden of format of range "C:H" to true


tell application "System Events"
   tell process "Excel"
       click menu item "AutoFit Selection" of menu 1 of menu item "Column" of menu 1 of menu bar item "Format" of menu bar 1
   end tell
end tell

set selection range of table 1 to range "C:H" 


		set color to highlightColor

tell font object of range "A1:AD1" of sheet "Sheet1"
		set {bold, font size} to {true, 10}
		set color of interior object to {141, 180, 226}

	save workbook as myWorkbook filename "Client Services Account Performance Scorecard2"

tell application "Microsoft Excel"
	set myWorkbook to make new workbook
	set workbookName to "Test" as string
	set destinationPath to "Desktop"
	save active workbook in destinationPath
end tell

	save workbook as myWorkbook filename "Client Services Account Performance Scorecard2"
tell used range
			set cc to count of columns
		end tell
		select range ("C:H" & cc)
tell application "Google Chrome"
	activate
	tell application "System Events"
		tell process "Microsoft Excel"
			keystroke "v" using command down
			keystroke return
		end tell
	end tell
end tell

# Copy Google Doc

tell application "Google Chrome"
	activate
	goToWebPage(“https://docs.google.com/spreadsheets/d/1mymE8805JLMWhc9XGWN7PNCqQEd4f1v7aSBqeI1PuIg/edit#gid=1985560671”)
	tell application "System Events"
		tell process "Google Chrome"
			keystroke "a" using command down
			keystroke "a" using command down
			keystroke "c" using command down
		end tell
	end tell
end tell


set wrap text of cell 2 of row 4 to true
		set {wrap text} of range "A1:AD1" to {true}

set wrap text of row 1 to true

tell application "Microsoft Excel"
	tell active sheet
		select row "1:1"
	end tell
end tell

delay 1

tell application "System Events"
	tell process "Excel"
		click menu item "Filter" of menu 1 of menu bar item "Data" of menu bar 1
	end tell
end tell


		set row height of range "1:1" to 40 -- points (rows)
		set row width of range "1:1" to 2 -- characters (columns)




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

#Delay script
tell application "Microsoft Excel"
	delay 1
	quit
end tell


#Open specific file
do shell script "open ~/desktop/RetailStores.xls"

#Copy Select text
tell application "Microsoft Excel" to activate
tell application "System Events"
	tell process "Excel"
		tell menu bar 1
			click menu item "Copy" of menu "Edit"
		end tell
	end tell
end tell

#Autosize cells
tell application "Microsoft Excel"
	autofit columns of range "A:BT"
	autofit rows of range "A1:A25"
end tell

#Dialog Display
tell application "Microsoft Excel"
	display dialog "What is the store number?" default answer ""
	set storeNumber to text returned of theResult
	return storeNumber
end tell
