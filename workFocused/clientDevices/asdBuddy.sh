#!/bin/bash

################################################################################
#                                                                              #
#                                   ASD Buddy                                  #
#             * A Simple tool for imaging Triage and ASD Drives *              #
#                                                                              #
################################################################################

#------------------------------ Compress & Scan -------------------------------#
compress+scan(){
# Verify that user wants to compress, remove old and scan DMG's for restore
clear
echo ""
echo "This script will compress any DMG files that do NOT have 'Compressed-'"
echo "appended to the beginning of their name."
echo ""
echo "After compression completes the file name will be re-named accordingly."
echo ""
echo "All remaining DMG's will then be scanned for restore."
echo ""
echo "*NOTE: This can be run in place if new DMG's are added to the directory."
echo "       Only new DMG files will be compressed and scanned."
echo "" 
read -r -p "Continue? (y/n)" response
	if [ $response != "y" ]; then
		echo ""
		echo "Exiting..."
		echo ""
		exit 1 
	fi

# Check for new DMG's -- exit if none are found
newDMGs=$(ls *.dmg | grep -v "Scanned+Compressed")
if [ "$newDMGs" == "" ]; then
	clear
	echo ""
	echo "ERROR: No new DMG files found. Please select from the following."
	echo ''
	echo '[1] Restore DMGs to drive named "geniusdrive." (this will erase target volume) '
	echo '[2] Help / About'
	echo '[3] Exit'
	echo ''
	read -p '>' whichfunction
	echo ''
	if [ $whichfunction == '1' ]; then
		partition+restore
	elif [ $whichfunction == '2' ]; then
		help+about
	elif [ $whichfunction == '3' ]; then
		echo 'Exiting...'
		echo ''
		exit 1
	fi
fi

# create start variable to show total time taken to compress & scan dmgs
starttime=$(date)

# Check for DMG's that have not been compressed...then compress them!
IFS=$'\n'
for i in $(ls *.dmg | grep -v Compressed); do
	hdiutil convert $i -format UDZO -o "Compressed-"$i 
	echo ""
done

# Scan DMG's for restore 
echo ""
echo "Scanning Images for restore"
echo ""
for i in Compressed-*.dmg; do
	asr imagescan --source $i
	echo ""
done

# Rename 'Scanned+Compressed=*.dmg'
for i in Compressed-*.dmg; do
	mv $i "Scanned+"$i
done
echo ""
echo "Images Scanned Successfully"
echo ""

# create end time variable
endtime=$(date)

# Remove original DMG's -- yes or no?
olddmgs=$(ls *.dmg | grep -v Scanned+Compressed)
echo "All source DMG's have been compressed and scanned for restore." 
echo ""
read -r -p "Would you like to delete the original DMG's? (y/n)" response
	if [ $response != "y" ]; then 	
		echo ""
		echo "Exiting..."
		echo ""
		exit 1 
	else
		echo ""
		echo "Removing original DMG files..."
		echo ""
		rm -rf $olddmgs
	fi
unset IFS
clear

# echo start & end times and choose next step 
echo ''
echo "Start Time: "$starttime
echo "End Time:   "$endtime
echo ''
echo 'All source DMGs have been compressed and scanned for restore.'
echo ''
echo 'Please choose from the following to continue...'
echo ''
echo '[1] Restore DMGs to drive named "geniusdrive." (this will erase target volume) '
echo '[2] Help / About'
echo '[3] Exit'
echo ''
read -p '>' whichfunction
echo ''
if [ $whichfunction == '1' ]; then
	partition+restore
elif [ $whichfunction == '2' ]; then
	help+about
elif [ $whichfunction == '3' ]; then
	echo 'Exiting...'
	echo ''
	exit 1
fi
}

#--------------------------- Partition & Restore  -----------------------------#
partition+restore(){
sudo defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool YES
clear
VERIFY=1
MOUNT_POINT=/Volumes/geniusdrive
DRIVE_NAME=$(diskutil list geniusdrive | grep /dev)

# Check that volume "geniusdrive" is mounted
if [ "$DRIVE_NAME" != "" ]; then
	echo ""
    echo "Found Volume $MOUNT_POINT..."
	echo ""
else
	echo ""
    echo "ERROR: No destination volume found!"
    echo ""
    echo "Please connect a volume to image named 'geniusdrive' and restart script."
    echo ""
    exit 1
fi

# Data Loss Warning
echo "************************************************"
echo "*                                              *"
echo "*            IMPENDING DATA LOSS!!!            *"
echo "*                                              *"
echo "*   - The volume named 'geniusdrive' will be   *"
echo "*     reformatted and erased!                  *"
echo "*                                              *"
echo "************************************************"
echo ""
read -r -p "Continue? (y/n)" response
if [ $response != "y" ]; then 
	echo ""
	echo "Exiting..."
	echo ""
	exit 1 
fi;

# create start variable to show total time taken to partition and restore dmgs
starttime=$(date)

# Temp file creation / removal 
tempMAP=".temp_partition_map.txt" 
if [ "$(ls | grep .temp_partition_map.txt)" != "" ]; then
	rm $tempMAP
fi

# Building temp file used to create partition name
loopCOUNT=0
dmgCOUNT=$(ls Scanned+Compressed*.dmg | grep -c "dmg")
partFORMAT="HFS+"

until [ $loopCOUNT -eq $dmgCOUNT ]; do
		loopCOUNT=$(($loopCOUNT + 1))
		partNAME="disk_part_"$loopCOUNT
		tempSIZE=$(du -s -g Scanned+Compressed*.dmg | awk NR==$loopCOUNT | awk '{print $1}')
		if [ "$tempSIZE" -ge "10" ]; then
			partSIZE="70G"
		elif [ "$tempSIZE" -ge "7" ] && [ "$tempSIZE" -le "9" ]; then
			partSIZE="50G"
		elif [ "$tempSIZE" -ge "4" ] && [ "$tempSIZE" -le "6" ]; then
			partSIZE="30G"
		elif [ "$tempSIZE" -ge "2" ] && [ "$tempSIZE" -le "3" ]; then
			partSIZE="15G"
		elif [ "$tempSIZE" -eq "1" ]; then
			partSIZE="5G"
		fi
		echo $partFORMAT $partNAME $partSIZE >> $tempMAP
		if [ $loopCOUNT -eq $dmgCOUNT ]; then
			echo "HFS+ Tools R" >> $tempMAP
		fi 
done

# Partition Disk 
partitionMAP=$(cat $tempMAP)
diskNUMBER=$(diskutil list geniusdrive | grep /dev | cut -c6-10)
dmgCOUNT=$(($dmgCOUNT + 1))
diskutil partitionDisk $diskNUMBER $dmgCOUNT $partitionMAP

# restore dmg's to partitions created above  
loopCOUNT=0
dmgCOUNT=$(ls *.dmg | grep -c "dmg")

until [ $loopCOUNT -eq $dmgCOUNT ]; do
		loopCOUNT=$(($loopCOUNT + 1))
		dmgpath=$(pwd)/
		dmgsource=$(ls Scanned+Compressed*.dmg | awk NR==$loopCOUNT)
		fullpath=$dmgpath$dmgsource
		dmgtarget="/Volumes/disk_part_"$loopCOUNT
		echo ''
		echo "Restoring $dmgsource to $dmgtarget"
		asr restore --source "$fullpath" --target "$dmgtarget" --erase --noprompt --noverify
		dmgname=$(ls Scanned+Compressed*.dmg | awk NR==$loopCOUNT | sed 's/Scanned+Compressed-//' | sed 's/.dmg//')
		diskID=$(mount | grep "$dmgname" | awk '{print $1}' | cut -c6-)
		newDMGname=$(ls Scanned+Compressed*.dmg | awk NR==$loopCOUNT | sed 's/Scanned+Compressed-//' |\
		 sed 's/.dmg//' | sed 's/ASD //' | sed 's/EFI /e./' | sed 's/OS /o./' | sed 's/3S//')
		ASDorTECH=$(diskutil list $diskID | grep "ASD")
		if [ "$ASDorTECH" != "" ]; then
			diskutil rename $diskID $newDMGname
			mdutil -i off "/Volumes/"$newDMGname
		fi
done
clear

# create end variable and show start / end time of partition & restore 
endtime=$(date)
echo ''
echo "Start Time: "$starttime
echo "End Time:   "$endtime

# where to now?
echo ''
echo 'All source DMGs have been restored to geniusdrive.'
echo ''
echo '[1] Eject Finished Drive & Exit'
echo '[2] Help / About'
echo ''
read -p '>' whichfunction
echo ''
if [ $whichfunction == '1' ]; then
	diskutil eject $diskNUMBER
	echo ''
	echo "Exiting..."
	echo ''
	exit 1
elif [ $whichfunction == '2' ]; then
	help+about
fi
sudo defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool NO
}

#-------------------------------- Help & About --------------------------------#
help+about(){
howto=~/Desktop/About-ASD-Buddy.txt
echo 'Press "q" at any time to exit' > $howto
echo '' >> $howto
echo 'This file has been saved to the desktop for future reference.' >> $howto 
echo '' >> $howto
echo 'This script is intended for use in the Genius Room only' >> $howto
echo '' >> $howto
echo '' >> $howto
echo 'How to use "ASD-Buddy.sh":' >> $howto
echo '' >> $howto
echo '"ASD-Buddy.sh" was written to make the creation of ASD or Triage drives' >> $howto
echo 'much simpler. It will save time and automate most of the process. Using' >> $howto
echo 'this tool is very simple. ' >> $howto
echo '' >> $howto
echo '1. Place all DMG files along with a copy of "ASD-Buddy.sh" into a folder' >> $howto
echo '   on the machine you will be using for imaging.' >> $howto
echo '2. Connect an external HDD, re-partition the drive using Disk Utility so' >> $howto
echo '   that it has one partition named "geniusdrive"' >> $howto
echo '3. Open "Terminal" from /Applications/Utilities' >> $howto
echo '4. As script requires root privilege type <sudo> and then drag "ASD-Buddy.sh"' >> $howto
echo '   from the DMG directory onto your Terminal window and press return.' >> $howto
echo '5. If this is the first time running the script or if new DMGs have been' >> $howto
echo '   added to the directory run section [1] to compress and scan your DMGs.' >> $howto
echo '*  Skip Step 5 if all DMGs have already been compressed/scanned.' >> $howto
echo '' >> $howto
echo '6. After compression and scanning completes run section [2] to partition' >> $howto
echo '   the volume "geniusdrive" and restore images.' >> $howto
echo '7. Partitions will be re-named after restoring to e.XXX or o.XXX' >> $howto
echo '' >> $howto
echo '*  Due to how startup manager recognizes volume names the new name may' >> $howto
echo '   or may not appear until it has been booted to at least one time.' >> $howto
echo '' >> $howto
echo '*  As a result of how ASD images are packaged from gsx.apple.com they' >> $howto
echo '   must be compressed prior to image scanning. This only needs to be done' >> $howto
echo '   per image. This script is broken into two main parts -- section [1] will' >> $howto
echo '   compress and scan  source DMGs; section [2] will partition an attached' >> $howto
echo '   volume named "geniusdrive" and restore source images.' >> $howto
echo '' >> $howto
echo '' >> $howto
echo '[1] About Compressing and Image Scanning:' >> $howto
echo '' >> $howto
echo 'All .dmg files in the source directory will be compressed. The new .dmg' >> $howto
echo 'files will will have "Compressed-" appended to the beginning of their' >> $howto
echo 'names (ie "ASD EFI 3S138.dmg" will become "Compressed-ASD EFI 3S138.dmg")' >> $howto
echo 'It is critical the "Compressed-" does not get altered or removed.' >> $howto
echo '' >> $howto
echo 'After compression all .dmgs with the "Compressed-" naming will be scanned' >> $howto
echo 'for restore. After they have been scanned the name will change to match' >> $howto
echo 'the following example. (ie "Compressed-ASD EFI 3S138.dmg" will become' >> $howto
echo '"Scanned+Compressed-ASD EFI 3S138.dmg") Again, it is important that the' >> $howto
echo 'beginning portion of the name is not changed or removed.' >> $howto
echo ''>> $howto
echo 'As a result of the naming conventions it is possible to add new .dmg' >> $howto
echo 'to the source directory and compress/scan only the new files. This' >> $howto
echo 'should prove useful when a new version of ASD releases or a new triage' >> $howto
echo 'image is ready for deployment.' >> $howto
echo ''>> $howto
echo 'After compression and scanning the user will be prompted to with the' >> $howto
echo 'option to delete the non-compressed or original .dmg files. This is' >> $howto
echo 'not required, but will save space on the source machine.' >> $howto
echo '' >> $howto
echo '' >> $howto
echo '[2] About Partitioning target disk and Restoring source Images' >> $howto
echo '' >> $howto
echo 'All images must be compressed and image scanned once before restoring. In' >> $howto
echo 'order for the restore to work it is important that the naming convention' >> $howto
echo 'from above is retained. The only requirement is that the .dmg files all' >> $howto
echo 'maintain "Scanned+Compressed-" appended to the beginning of their name.' >> $howto
echo '' >> $howto
echo 'The partitions created will be sized based on the size of the source .dmg' >> $howto
echo 'files. The partitions created will be 5, 15, 20, or 50GB in size.' >> $howto
echo '' >> $howto
echo 'In order to prevent accidental reformatting of connected drives this script' >> $howto
echo 'will ONLY repartition and work with an attached volume named "geniusdrive"' >> $howto
echo '' >> $howto
echo '' >> $howto
echo '[3] The Importance of names:' >> $howto
echo '' >> $howto
echo 'This script will make your life much easier in that it will also rename the' >> $howto
echo 'final volume to "e.XXX" for "ASD EFI XXX" or "o.XXX" for "ASD OS XXX." This' >> $howto
echo 're-naming function works when dmgs have their orignal name formatting. For' >> $howto
echo 'this reason it is advisable to leave the dmgs name as is after downloading' >> $howto
echo 'them from gsx.apple.com. The standard naming convention is "ASD EFI 3SXXX.dmg"' >> $howto
echo 'or "ASD OS 3SXXX.dmg"' >> $howto
echo '' >> $howto
echo '' >> $howto
echo 'Questions or comments please e-mail bclement@apple.com' >> $howto
echo 'Written by Benjamin Clement -- May 2013' >> $howto
echo '' >> $howto
less $howto
clear
echo ''
echo '[1] Compress & Scan DMGs for restore'
echo '[2] Restore DMGs to drive named "geniusdrive." (this will erase target volume) '
echo '[3] Help / About'
echo '[4] Exit'
echo ''
read -p '>' whichfunction
echo ''
if [ $whichfunction == '1' ]; then
	compress+scan
elif [ $whichfunction == '2' ]; then
	partition+restore
elif [ $whichfunction == '3' ]; then
	help+about
elif [ $whichfunction == '4' ]; then
	echo 'Exiting...'
	echo ''
	exit 1
fi
}

#------------------------------- Body of Script -------------------------------#
clear
echo "********************************************************************************"
echo "*                                                                              *"
echo "*                                   ASD Buddy                                  *"
echo "*             * A simple tool for imaging Triage and ASD Drives *              *"
echo "*                                                                              *"
echo "********************************************************************************"

# Ensure user is root -- exit with error if not
if (( "$(id -u)" != "0" )); then
	echo ''
    echo 'ERROR: must be ran as root user'
   	echo ''
   	echo "Please run: sudo $0"
   	echo ''
    exit 1
fi

# Change to directory where script is stored.
changedir="$( cd "$( dirname "$0" )" && pwd )"
cd "$changedir"
 
# Choose which function to run -- compress, restore, help, exit.
echo ''
echo '[1] Compress & Scan DMGs for restore'
echo '[2] Restore DMGs to drive named "geniusdrive." (this will erase target volume) '
echo '[3] Help / About'
echo '[4] Exit'
echo ''
read -p '>' whichfunction
echo ''
if [ $whichfunction == '1' ]; then
	compress+scan
elif [ $whichfunction == '2' ]; then
	partition+restore
elif [ $whichfunction == '3' ]; then
	help+about
elif [ $whichfunction == '4' ]; then
	echo 'Exiting...'
	echo ''
	exit 1
fi
