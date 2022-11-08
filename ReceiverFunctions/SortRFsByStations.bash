#!/bin/bash

DirPref="Event_"
StartDir=${PWD}
StatList="$StartDir/StationList.txt"
outfile="$StartDir/ProblemStationsList.txt"
WorkFile="$StartDir/SortByStationTemp.txt"

# Color table, most aren't even used but they're useful for debugging
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # Resets to no color
# Make sure to use -e flag in echo to allow the backslashes to be read correctly

echo -e "${LIGHT_GREEN}Beginning at $(date +'%B %d, %Y at %T')${NC}"

SECONDS=0 # Handy little thing to track calculation time of scripts
duration="SECONDS" 

echo # Blank line for ease of reading

if [ -e $WorkFile ]; # Temp file solution was 90% faster than any other alternatives and more consistent
    then
       cat /dev/null > $WorkFile # Clears output file if it already exists
       echo -e "${LIGHT_GREEN}Temp file cleared${NC}" # Uncomment if debugging
    else
       touch $WorkFile
       if [ -f $WorkFile ]; then # Simple check to see if it was created successfully
	   echo -e "${LIGHT_GREEN}Temp file successfilly created in $StartDir{NC}"
       fi
fi

if [ -d "$StartDir/Stations" ]; # Makes a folder for the stations if it doesn't already exist
    then
       :
    else
       mkdir "$StartDir/Stations"
fi

echo # Blank line for ease of reading

NumStations=$(wc -l < $StatList)
echo "$NumStations Stations Found In List"

for i in $(seq 1 $NumStations); do
    CurStat=$(awk 'NR=='$i'{ print; exit }' $StatList)
    if [ -d "$StartDir/Stations/$CurStat" ]; 
	then
	   :
	else
	   mkdir "$StartDir/Stations/$CurStat"
    fi
done



for dir in `ls -ad $DirPref*`; do # Enters event directory
    cd $dir
    echo -e "${NC}Working on $dir"

    for i in $(seq 1 $NumStations); do # Works on current station
	CurStat=$(awk 'NR=='$i'{ print; exit }' $StatList)

        doRFFilesExist=$(find . -mindepth 1 -maxdepth 1 -type f -name "*$CurStat*.it[r,t]")

	if [ -z "$doRFFilesExist" ]; then # Speed improvement - doesn't count SAC files if the number of files is 0"
	    :
	else
	    cat /dev/null > $WorkFile # Clears temp file
	    echo "$doRFFilesExist" >> $WorkFile # Writes number of stations to the SAC File"
	    
	    RFFileCount=$(wc -l < $WorkFile)

		for i in $(seq 1 $RFFileCount); do
		   CurrentRFFile=$(awk 'NR=='$i'{ print; exit }' $WorkFile) # Reads the i'th line in the temp file
		   cp "$StartDir/$dir/$CurrentRFFile" "$StartDir/Stations/$CurStat"
		done

		cat /dev/null > $WorkFile # Clears temp file

		cd "$StartDir/Stations/$CurStat" # Ok to be honest this check may be excessive but it's helpful for debugging
		doRFFilesExistMoveCheck=$(find . -type f -name "*$dir**$CurStat*.it[r,t]")
		cd "$StartDir/$dir"

	        echo "$doRFFilesExistMoveCheck" >> $WorkFile # Writes list of moved	    
		RFFileCountMoveCheck=$(wc -l < $WorkFile) # Separate variable for the move check to make sure it worked

		#echo -e "${YELLOW}$SACFileCountMoveCheck files removed from main folders${NC}" ## DEBUG LINE ##
		
		#echo -e "${YELLOW}$RFFileCount $RFFileCountMoveCheck${NC}" #Uncomment if debugging

		if [[ "$RFFileCount" == "$RFFileCountMoveCheck" ]];
		    then
		       echo -e "${LIGHT_GREEN}Successfully copied Iterdecon files for $CurStat in $dir${NC}"
		    else
		       echo -e "${LIGHT_RED}Failed to copy Iterdecon files for $CurStat in $dir${NC}"
		fi

	    fi

    done
    cd $StartDir

done

rm $WorkFile # Deletes the temp file at the end, comment this line if debugging

echo # Blank line for ease of reading
echo -e "${LIGHT_GREEN}Operation complete  at $(date +'%B %d, %Y at %T')"
echo -e "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed ${NC}"
