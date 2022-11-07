#!/bin/bash 

# This script assumes 3 component seismic data per station, sorted by event
# An example file structure is included in the GitHub repository

StartDir="${PWD}" # Defines the starting directory as location of this script
DirPref="Event_" # Defines the prefix of the event directories
StatList="StationList.txt" # Defines the station list

#StatList requires a list of the 3 (or 2 or 4) digit station code for each station within the desired network
#Example: Network ZR from 2015-2018 has stations W1A, W1B, etc.
#This code assumes all stations are within the same network, will require some tweaking otherwise

NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In Station List"

for event in `ls -ad ${DirPref}*`; do 
    cd $event 
    echo "Working on $event"
    
    for i in $(seq 1 $NumStations); do 
	CurStat=$(awk 'NR=='$i'{ print; exit }' ../$StatList) # Reads the i'th line of the station list
	CurRotFile="$CurStat.rotate" # Defines rotation file for current station

	doSACFilesExist=$(find . -maxdepth 1 -type f -name "*$CurStat*.SAC") # Searches for SAC files within event directory. By default, will not search subdirectories

	if [ -z "$doSACFilesExist" ]; then # Only creates rotation files for stations with SAC files
	    :
        else
	cat > $CurRotFile <<+ # Has to be indented to left to write file properly
r *$CurStat*.HH[1,2,E,N]*.SAC
interp NPTS 15001
rot to gcp
w $CurStat.r $CurStat.t
r *$CurStat*.HHZ*.SAC
interp NPTS 15001
w $CurStat.z
q
+
 
		if [ -f "$CurRotFile" ]; then
           		echo "Successfully created rotation file for Station $CurStat in $event"
        	else
           		echo "Failed to create rotation file for Station $CurStat in $event"
		fi 

 		if [ -f $CurRotFile ]; then # Only tries to run the current rotation file if it exists 
			sac ./$CurRotFile 
   		fi 

    		if [[ -f "$CurStat.r" && "$CurStat.t" && "$CurStat.z" ]]; 
		then 
          		echo "Successfully rotated data for Station $CurStat in $event"
	   		rm $CurRotFile # Deletes rotation file - COMMENT IF DEBUGGING
        	else
           		echo "Failed to rotate data for Station $CurStat in $event"
   		fi
    	fi
    done 
    
    cd $StartDir # Returns to main data directory
done 
