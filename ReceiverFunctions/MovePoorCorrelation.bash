#!/bin/bash

## CORRELATION THRESHOLD ##
MinCorr="70" # Threshold for correlation below which RFs will be set aside

StartDir="${PWD}" # Reference directory is location where script is run
StatList="$StartDir/StationList.txt" # Defines the station list
ProbDir="Low_Correlation_RFs" # Name of the directory where low correlation files will be set
DirPref="Event_" # Prefix of event files
IterOut="output.iterdecon" # Names of Iterdecon output file
TempFile="$StartDir/MovePoorCorrelationTempFile.txt"

# Color table, useful for debugging
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # Resets to no color

if [ -e $TempFile ]; then
    cat /dev/null > $TempFile
else
    touch $TempFile
fi

BadTicker="0" # Ticker for counting bad stations
RFCountTotal="0" # Ticker for counting total number of RFs found in entire dataset

NumStations=$(wc -l < $StatList) # Defines the number of stations
echo "$NumStations Stations Found In List"

EventList=$(find . -maxdepth 1 -mindepth 1 -type d -name "$DirPref*")
NumEvents=$(echo -n "$EventList" | grep -c '^')
echo -e "${LIGHT_GREEN}$NumEvents events found${NC}"

for event  in `ls -ad ${DirPref}*`; do
    cd $event
    echo "Working on $event"

    rm *spk # Removes the spk files
    
    cat /dev/null > $TempFile
   
    
    if [ -d $ProbDir ]; then # Makes folder for prob RFs if it doesn't exist already
	:
    else
	mkdir $ProbDir
    fi

    RFCount=$(wc -l < $IterOut) # Number of RFs for given event
    echo "$RFCount RFs found for $event"

    RFCountTotal=$(($RFCountTotal + $RFCount)) # Adds current RFs to RF Total

    for i in $(seq 1 $RFCount); do
	RF=$(awk 'NR=='$i'{ print $5}' $IterOut) # Reads RF from output file
	Corr=$(awk 'NR=='$i'{ print $3}' $IterOut) # Reads correlation value from output file
	
	if [ -e $RF ]; # Only attempts the following code if the files haven't been moved already
	then 
		if (( $(bc <<<"$Corr < $MinCorr") )); 
		then
		   extension="${RF##*.}" # Finds file extension for current file
		   RFBase=$(basename -s $extension $RF) # Removes file extension

		   ProbFileList=$(find . -type f -name "$RFBase???")

		   mv $ProbFileList $ProbDir # Moves both itr and itt files

		   BadTicker=$(($BadTicker+2))

		fi
	else # No need to do anything in the case of a good station
	    :
	fi
    done
    echo "Finished with $event"
    cd $StartDir
done

rm $TempFile
echo ""

NumRFs=$(( $RFCountTotal / 2))
echo -e "$RFCountTotal RFs ($NumRFs radial and tangential pairs) found for $NumEvents Events at $NumStations Stations"

GoodRFs=$(($RFCountTotal - $BadTicker))

echo -e "${LIGHT_GREEN}$GoodRFs RFs with Correlation >= $MinCorr% Found"
echo -e "${LIGHT_RED}$BadTicker RFs with Correlation < $MinCorr% Found${NC}"

