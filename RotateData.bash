#!/bin/bash 

StartDir="${PWD}" # Defines the starting directory as location of this script
echo "Beginning in $StartDir"
DirPref="Event_" # Defines the prefix of the event directories
StatList="StationList.txt" # Defines the station list

#StatList requires a list of the 3 (or 2 or 4) digit station code for each station within the desired network
#This code assumes all stations are within the same network, will require some tweaking otherwise

NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In List"

for dir in `ls -ad ${DirPref}*`; do # Loops through event directories ##LOOP1
    cd $dir # Enters the event directory
    echo "Working on $dir"
    
    for i in $(seq 1 $NumStations); do ##LOOP2
	CurStat=$(awk 'NR=='$i'{ print; exit }' ../$StatList) # Reads the i'th line of the station list
	CurRotFile="$CurStat.rotate" # Creates variable for current rotation file before checking if it actually needs to be made to avoid breaking checks later in code


	doSACFilesExist=$(find . -maxdepth 1 -type f -name "*$CurStat*.SAC") # Set var to output of a find command to get thse dumb wildcards to work

	if [ -z "$doSACFilesExist" ]; then ##LOOP5 Only creates rotation files for stations with SAC files
	    #echo "No SAC files found for Station $CurStat in $dir" De-comment for debug
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
 
	if [ -f "$CurRotFile" ]; then ##LOOP3 Checks if rotation file was properly created, only if data exists for the station
           echo "Successfully created rotation file for Station $CurStat in $dir"
        else
           echo "Failed to create rotation file for Station $CurStat in $dir"
	fi ##LOOP3


 if [ -f $CurRotFile ]; then # Only tries to run the current rotation file if it exists ##LOOP6
	sac ./$CurRotFile 
    fi ##LOOP6

    if [[ -f "$CurStat.r" && "$CurStat.t" && "$CurStat.z" ]]; then ##LOOP4
           echo "Successfully rotated data for Station $CurStat in $dir"
	   rm $CurRotFile # Deletes rotation file for better organization, KEEP IF DEBUGGING
        else
           echo "Failed to rotate data for Station $CurStat in $dir"
    fi ##LOOP4

        fi ##LOOP5 Closes the if statement that checks if data exists for the current station

    done ##LOOP2
    
    cd ../ # Returns to main data directory
done ##LOOP1
