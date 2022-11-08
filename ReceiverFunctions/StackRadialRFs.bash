#!/bin/bash 

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

StartDir="${PWD}" # Defines the starting directory as location of this script
StatList="StationList.txt" # Defines the station list
StationsDir="$StartDir/Stations"
WorkFile="$StartDir/StackRFsTemp.txt"
Outfile="$StartDir/Stations/RadStackOutput.txt"

NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In List"

if [ -e $WorkFile ]; # Temp file solution was 90% faster than any other alternatives and more consistent
    then
       echo "Temp file already exists"
       cat /dev/null > $WorkFile # Clears output file if it already exists
       echo "Temp file cleared"
    else
       touch $WorkFile
       if [ -f $WorkFile ]; then # Simple check to see if it was created successfully
	   echo "Temp file successfilly created in $StartDir"
       fi
fi

cd $StationsDir

for dir in `ls -ad ${W}*`; do
    cd $dir
    
    fileListRadial=$(find . -maxdepth 1 -type f -name "*.itr")
    echo "$fileListRadial" >> $WorkFile

    if [ -z "$fileListRadial" ];  # Checking the length of an empty text file returns 1, so it's giving a value of 1 RF even when no RFs exist
	then
	   :
	else

    echo "Working on Station $dir"
    NumRadial=$(wc -l < $WorkFile) # Defines number of radial RFs found for current station
    echo "$NumRadial Receiver Functions Found for $dir"

    echo "Station $dir: $NumRadial Radial Receiver Functions in stack" >>$Outfile

	CurStat=$dir # Reads the i'th line of the station list
	CurStackFile="$CurStat.Radial.Stack" # Defines name for current stack file

	if [ -e $CurStackFile ]; # Creates stack file if it doesn't already exist
	then
	    cat /dev/null > $CurStackFile # Clears stack file if it already exists
	else
	    touch $CurStackFile
	fi
	
	FirstIterFile=$(head -n 1 $WorkFile) # Quick way of extracting first line from work file
	echo "r $FirstIterFile" >> $CurStackFile

	for i in $(seq 2 1 $NumRadial); do
	   CurRadFile=$(awk 'NR=='$i'{ print; exit }' $WorkFile)
	   echo "addf $CurRadFile" >> $CurStackFile
	done

	echo "div $NumRadial" >> $CurStackFile
	echo "w $dir.stack.r" >> $CurStackFile
	echo "q" >> $CurStackFile
	
	if [ -f "$CurStackFile" ]; then # Check to see if stack file was created correctly
           echo -e "${LIGHT_GREEN}Successfully created stack file for Station $dir${NC}"
        else
           echo -e "${LIGHT_RED}Failed to create stack file for Station $dir${NC}"
	fi 
	
	sac ./$CurStackFile
     
     fi

    cat /dev/null > $WorkFile # Clears temp file
     
     cd $StationsDir

done

rm $WorkFile # Deletes the temp file at the end, comment this line if debugging

echo # Blank line for ease of reading
echo -e "${LIGHT_GREEN}Operation complete  at $(date +'%B %d, %Y at %T')"
echo -e "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed ${NC}"



