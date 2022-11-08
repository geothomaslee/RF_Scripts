#!/bin/bash 

## STATION PREFIX ##
StatPref="W" # Common prefix for all stations. Ex: for stations W1A, W1B, W2B, etc. use W

## SORT STACKS ##
# Moves all stacks into a folder in the parent directory of the Stations directory
# Set SortStacks to 0 to disable
SortStacks="1" # DEFAULT 1

# Color table, useful for debugging
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # Resets to no color

StartDir="${PWD}" # Defines the starting directory as location of this script
StationsDir="$StartDir/Stations"
WorkFile="$StartDir/StackRFsTemp.txt"
Outfile="$StartDir/Stations/StackOutput.txt"
StackDir="$StartDir/Stacks"

NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In List"

if [ -e $WorkFile ];
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



if [[ $SortStacks == "1" ]];
then
	if [ -d $StackDir ];
	then
		:
	else
		mkdir $StackDir
	fi
fi

cat /dev/null > $Outfile # Clears the output file

cd $StationsDir
for station in `ls -ad $StatPref*`; do
    cd $station
    
    fileListRadial=$(find . -maxdepth 1 -type f -name "*$station.itr")
    echo "$fileListRadial" >> $WorkFile

    if [ -z "$fileListRadial" ]; # Only works if radial RFs are found
	then
	   :
	else
		echo "Working on Station $station"
    		NumRadial=$(wc -l < $WorkFile) # Defines number of radial RFs found for current station
    		echo -e "${LIGHT_GREEN}$NumRadial Receiver Functions Found for Station $station${NC}"

    		echo "Station $station: $NumRadial Receiver Functions Added To Stack" >>$Outfile

		CurStat=$station
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
		echo "w $station.stack.itr" >> $CurStackFile
		echo "q" >> $CurStackFile
	
		sac ./$CurStackFile
		rm $CurStackFile # COMMENT IF DEBUGGING
	
		if [[ $SortStacks == "1" ]];
		then
			cp $station.stack.itr $StackDir
		fi
     
   fi

	cat /dev/null > $WorkFile
	fileListTangential=$(find . -maxdepth 1 -type f -name "*$station.itt")
    	echo "$fileListTangential" >> $WorkFile

    	if [ -z "$fileListTangential" ]; # Only works if radial RFs are found
	then
	   :
	else
    		NumTangential=$(wc -l < $WorkFile) # Defines number of radial RFs found for current station
		CurStat=$station
		CurStackFile="$CurStat.Tangential.Stack" # Defines name for current stack file

		if [ -e $CurStackFile ]; # Creates stack file if it doesn't already exist
		then
			cat /dev/null > $CurStackFile # Clears stack file if it already exists
		else
	   		touch $CurStackFile
		fi
	
		FirstIterFile=$(head -n 1 $WorkFile) # Quick way of extracting first line from work file
		echo "r $FirstIterFile" >> $CurStackFile

		for i in $(seq 2 1 $NumTangential); do
	   		CurTanFile=$(awk 'NR=='$i'{ print; exit }' $WorkFile)
	   		echo "addf $CurTanFile" >> $CurStackFile
		done

		echo "div $NumTangential" >> $CurStackFile
		echo "w $station.stack.itt" >> $CurStackFile
		echo "q" >> $CurStackFile
		
		sac ./$CurStackFile
		rm $CurStackFile # COMMENT IF DEBUGGING
     		
		if [[ $SortStacks == "1" ]];
		then
			cp $station.stack.itt $StackDir
		fi
   fi

   cat /dev/null > $WorkFile # Clears temp file
   
  


   cd $StationsDir

done

if [[ $SortStacks == "1" ]];
then
	echo -e "${LIGHT_GREEN}Successfully created and sorted stacks${NC}"
else
	echo -e "${LIGHT_GREEN}Successfully created stacks"
	echo -e "${LIGHT_RED}Did not move stacks to separate folder"
	echo -e "Ignore this message if intentional"
	echo -e "If unintentional, set SortStacks=1 and re-run script${NC}"
fi

rm $WorkFile # COMMENT IF DEBUGGING

