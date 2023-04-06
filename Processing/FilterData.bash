#!/bin/bash 

# This script can automatically filter large amounts of seismic data using SAC commands.
# It assumes the file structure of ScriptFolder/Events/seismicdata.sac where ScriptFolder is the directory from which you run this script.

## FILTERING PARAMETERS ##
# The first line of each section defines whether or not the action should be done.
# Example: Set Downsample="0" to skip downsampling, Downsample="1" will downsample using the given delta value.

##DOWNSAMPLING
Downsample="1" # DEFAULT 0
Delta="0.05" # Time-step between points, equivalent to 1/sampling frequency 

# NOTE: Iterdecon cannot take more than 4096 points and the error message is quite unhelpful. 
# It can be downsampled later, but I prefer to do it at this step to cut down on file size.

#REMOVE MEAN AND TREND
rmean="1" # DEFAULT 1
rtrend="1" # DEFAULT 1

## Enabling bandpass will automatically enable rmean and rtrend if they are set to 0

#BANDPASS
Bandpass="1" # DEFAULT 1
BotCo="0.05" # Bottom corner
TopCo="2" # Top corner
Passes="1" # Number of passes, either 1 or 2

StartDir="${PWD}" # Defines the starting directory as location of this script
DirPref="Event_" # Defines the prefix of the event directories
StatList="StationList.txt" # Defines the station list

#StatList requires a list of the 3 (or 2 or 4) digit station code for each station within the desired network
#Example: Network ZR from 2015-2018 has stations W1A, W1B, etc.
#This code assumes all stations are within the same network, will require some tweaking otherwise

NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In Station List"

for event in `ls -ad ${DirPref}*`; do # Loops through event directories
    cd $event #Enters the event directory
    echo "Working on $event"
    
    for i in $(seq 1 $NumStations); do
	CurStat=$(awk 'NR=='$i'{ print; exit }' ../$StatList) # Reads the i'th line of the station list
	CurFilterFile="$CurStat.filter" # Defines name for current filter filter

	doRotatedFilesExist=$(find . -maxdepth 1 -type f -name "$CurStat.[r,t,z]") # Set var to output of a find command to get thse dumb wildcards to work

	if [ -z "$doRotatedFilesExist" ]; # Only creates rotation files for stations with SAC files
	then 
	    : 
        else

		if [ -f $CurFilterFile ]; 
		then
			cat /dev/null > $CurFilterFile
		else
			touch $CurFilterFile
		fi

		echo "r *$CurStat*.[r,t,z]" >> $CurFilterFile
		
		if [[ $Downsample == "1" ]];
		then
			echo "INTERP DELTA $Delta" >> $CurFilterFile
		fi
		
		if [[ $Bandpass == "1" ]]; ## Force enables rmean and rtrend if bandpassing is enabled 
		then
			rmean="1"
			rtrend="1"
		fi
		
		if [[ $rmean == "1" ]];
		then
			echo "rmean" >> $CurFilterFile
		fi
		
		if [[ $rtrend == "1" ]];
		then
			echo "rtrend" >> $CurFilterFile
		fi
			
		if [[ $Bandpass == "1" ]];
		then
			echo "bp co $BotCo $TopCo n $Passes" >> $CurFilterFile
		fi

		echo "w $CurStat.bp.$BotCo.$TopCo.r $CurStat.bp.$BotCo.$TopCo.t $CurStatbp.$bp.$BotCo.$TopCo.z" >> $CurFilterFile
		echo "q" >> $CurFilterFile
 
		#if [ -f "$CurFilterFile" ]; then ##UNCOMMENT IF DEBUGGING
           		#echo "Successfully created filter file for Station $CurStat in $event"
        	#else
           		#echo "Failed to create filter file for Station $CurStat in $event"
		#fi

		if [ -f $CurFilterFile ]; then # Only tries to run the current rotation file if it exist
			sac ./$CurFilterFile 
			rm $CurFilterFile # Removes filter file for organization, KEEP IF DEBUGGING
		fi 

        fi 

    done
    
    cd $StartDir 
done 
