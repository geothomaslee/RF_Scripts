#!/bin/bash 

StartDir="${PWD}" # Defines the starting directory as location of this script
echo "Beginning in $StartDir"
DirPref="Event_" # Defines the prefix of the event directories
StatList="StationList.txt" # Defines the station list

## FILTERING PARAMETERS ##
BotCo="0.05" # Lower corner for bandpass filtering
TopCo="2" # Upper corner for bandpass filtering

#StatList requires a list of the 3 (or 2 or 4) digit station code for each station within the desired network
#This code assumes all stations are within the same network, will require some tweaking otherwise


NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In List"

for dir in `ls -ad ${DirPref}*`; do # Loops through event directories ##LOOP1
    cd $dir # Enters the event directory
    echo "Working on $dir"
    
    for i in $(seq 1 $NumStations); do ##LOOP2
	CurStat=$(awk 'NR=='$i'{ print; exit }' ../$StatList) # Reads the i'th line of the station list
	CurFilterFile="$CurStat.filter" # Defines name for current filter filter


	doRotatedFilesExist=$(find . -maxdepth 1 -type f -name "$CurStat.[r,t,z]") # Set var to output of a find command to get thse dumb wildcards to work

	if [ -z "$doRotatedFilesExist" ]; then ##LOOP5 Only creates rotation files for stations with SAC files
	    : # Does nothing if file rotated files don't exist
        else
	cat > $CurFilterFile <<+ # Has to be indented to left to write file properly
r *$CurStat*.[r,t,z]
rmean
rtrend
bp bu c $BotCo $TopCo p 2
interp DELTA 0.05
w $CurStat.r $CurStat.t $CurStat.z
q
+
 
	if [ -f "$CurFilterFile" ]; then ##LOOP3 Checks if rotation file was properly created, only if data exists for the station
           echo "Successfully created filter file for Station $CurStat in $dir"
        else
           echo "Failed to create filter file for Station $CurStat in $dir"
	fi ##LOOP3


    if [ -f $CurFilterFile ]; then # Only tries to run the current rotation file if it exists ##LOOP6
	sac ./$CurFilterFile 
	rm $CurFilterFile ## Removes filter file for organization, KEEP IF DEBUGGING
    fi ##LOOP6

        fi ##LOOP5 Closes the if statement that checks if data exists for the current station

    done ##LOOP2
    
    cd ../ # Returns to main data directory
done ##LOOP1
