#!/bin/bash

# This script finds iterdecon files within event directories and sorts them by station.
# By default the stations folder is located within the same directory that contains the event folders

DirPref="Event_" # Prefix for event directories
StartDir=${PWD}
WorkFile="$StartDir/SortByStationTemp.txt"


## STATION DIRECTORY ##
StatDir="$StartDir/Stations" # Change this to adjust the stations directory. DEFAULT $StartDir/Stations

StatList="$StartDir/StationList.txt"
#StatList requires a list of the 3 (or 2 or 4) digit station code for each station within the desired network
#Example: Network ZR from 2015-2018 has stations W1A, W1B, etc.
#This code assumes all stations are within the same network, will require some tweaking otherwise

# Color table, most aren't even used but they're useful for debugging
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # Resets to no color

echo # Blank line for ease of reading

if [ -e $WorkFile ]; # Temp file solution was 90% faster than any other alternatives and more consistent
    then
       cat /dev/null > $WorkFile # Clears temp file if it already exists
       echo -e "${LIGHT_GREEN}Temp file cleared${NC}" 
    else
       touch $WorkFile
       if [ -f $WorkFile ]; 
       then 
	   echo -e "${LIGHT_GREEN}Temp file successfilly created in $StartDir{NC}"
       fi
fi

if [ -d "$StartDir/Stations" ]; # Makes a folder for the stations if it doesn't already exist
    then
       :
    else
       mkdir $StatDir
fi

echo # Blank line for ease of reading

NumStations=$(wc -l < $StatList)
echo "$NumStations Stations Found In List"

for i in $(seq 1 $NumStations); do
    CurStat=$(awk 'NR=='$i'{ print; exit }' $StatList)
    if [ -d "$StatDir/$CurStat" ]; 
	then
	   :
	else
	   mkdir "$StatDir/$CurStat"
    fi
done


for event in `ls -ad $DirPref*`; do # Enters event directory
    cd $event
    echo -e "${NC}Working on $event"

    for i in $(seq 1 $NumStations); do # Works on current station
	CurStat=$(awk 'NR=='$i'{ print; exit }' $StatList)

        doRFFilesExist=$(find . -mindepth 1 -maxdepth 1 -type f -name "*$CurStat*.it[r,t]")

	if [ -z "$doRFFilesExist" ]; 
	then
	    :
	else
	    cat /dev/null > $WorkFile # Clears temp file
	    echo "$doRFFilesExist" >> $WorkFile # Writes number of stations to the SAC File"
	    
	    RFFileCount=$(wc -l < $WorkFile)

		for i in $(seq 1 $RFFileCount); do
		   CurrentRFFile=$(awk 'NR=='$i'{ print; exit }' $WorkFile) # Reads the i'th line in the temp file
		   cp "$StatDir/$CurrentRFFile" "$StatDir/$CurStat"
		done

		cat /dev/null > $WorkFile # Clears temp file

		cd "$StatDir/$CurStat" 
		doRFFilesExistMoveCheck=$(find . -type f -name "*$dir**$CurStat*.it[r,t]")
		cd "$StatDir/$dir"

	        echo "$doRFFilesExistMoveCheck" >> $WorkFile # Writes list of moved	    
		RFFileCountMoveCheck=$(wc -l < $WorkFile) # Separate variable for the move check to make sure it worked

		if [[ "$RFFileCount" == "$RFFileCountMoveCheck" ]];
		    then
		       echo -e "${LIGHT_GREEN}Successfully copied Iterdecon files for $CurStat in $event${NC}"
		    else
		       echo -e "${LIGHT_RED}Failed to copy Iterdecon files for $CurStat in $event${NC}"
		fi
	fi

    done
    cd $StartDir
done

rm $WorkFile # Deletes the temp file at the end, comment this line if debugging
