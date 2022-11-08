#!/bin/bash 

StartDir="${PWD}" # Defines the starting directory as location of this script
echo "Beginning in $StartDir"
DirPref="Event_" # Defines the prefix of the event directories
StatList="StationList.txt" # Defines the station list

## ITERDECON PARAMETERS ##
outfile="input.iterdecon" # Defines the output file
iterations="400"
phaseshift="30"
delta=".001"
gaussian="2.5"
wvforms="1"



#StatList requires a list of the 3 (or 2 or 4) digit station code for each station within the desired network
#This code assumes all stations are within the same network, will require some tweaking otherwise


NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In List"

for dir in `ls -ad ${DirPref}*`; do # Loops through event directories ##LOOP1
    cd $dir # Enters the event directory
    echo "Working on $dir"
    
    if [ -f $outfile ]; then
	echo "$outfile already exists in $dir" 
    else
	touch $outfile # Creates output file
	if [ -f $outfile ]; then
	    echo "$outfile successfully created in $dir"
	fi
    fi
    cat /dev/null > $outfile # Clears output file

    for i in $(seq 1 $NumStations); do ##LOOP2
	CurStat=$(awk 'NR=='$i'{ print; exit }' ../$StatList) # Reads the i'th line of the station list

	doFilteredFilesExist=$(find . -maxdepth 1 -type f -name "$CurStat.r")

	if [ -z "$doFilteredFilesExist" ]; then ##LOOP5 Only creates input
	    : # Does nothing if files don't exist
        else

	echo "$CurStat.r" >> $outfile # Defines radial input file
	echo "$CurStat.z" >> $outfile # Defines vertical input file
	echo "$dir.$CurStat.itr" >> $outfile # Defines the radial output file
        echo $iterations >> $outfile
	echo $phaseshift >> $outfile
	echo $delta >> $outfile
	echo $gaussian >> $outfile
	echo $wvforms >> $outfile
	echo "0" >> $outfile
	echo "$CurStat.t" >> $outfile # Defines radial input file
	echo "$CurStat.z" >> $outfile # Defines vertical  input file
	echo "$dir.$CurStat.itt" >> $outfile # Defines the tangential output file
        echo $iterations >> $outfile
	echo $phaseshift >> $outfile
	echo $delta >> $outfile
	echo $gaussian >> $outfile
	echo $wvforms >> $outfile
	echo "0" >> $outfile

        fi ##LOOP5 Closes the if statement that checks if data exists for the current station

    done ##LOOP2
    
    cd ../ # Returns to main data directory
done ##LOOP1
