#!/bin/bash 

## IMPORTANT BEFORE USE ##
# This expects radial and tangential input files that are named as Station.Suffix where Suffix (NOT .SUFFIX) is defined in the parameters r_file_input and t_file_input. This is intended to add flexibility for testing different filtering parameters.
# This script assumes you have an alias set up for iterdecon in your .bashrc file. If this is not the case, edit lines 85 and 87 to replace iterdecon with the location of the executable
# Iterdecon breaks if you feed it more than 4096 points and the error message does not communicate the actual problem. Make sure your files have <4096 points. Use FilterData to quickly downsample if you need that.

## ITERDECON PARAMETERS ##
infile="input.iterdecon" # Defines the input file
iterations="400"
phaseshift="10" # Time difference between P-arrival and start of file
delta=".001"
gaussian="5"
wvforms="1"
r_file_input="bp.0.05.2.r" 
t_file_input="bp.0.05.2.t"
z_file_input="bp.0.05.2.z"

iterdecon="/usr/local/Owens_Software/bin/iterdecon_batch" ## Iterdecon executable location

LogOutput="1" # DEFAULT 1
outfile="output.iterdecon" 
# Set LogOutput to 0 if you want iterdecon to send its output into the terminal rather than a separate output file
# outfile defines the name of the output file

MakeRFs="1" # DEFAULT 1
# Set MakeRFs to 0 if you want it to make the iterdecon input files without actually running iterdecon, mostly for debugging purposes

StartDir="${PWD}" # Defines the starting directory as location of this script
DirPref="Event_" # Defines the prefix of the event directories
StatList="StationList.txt" # Defines the station list

#StatList requires a list of the 3 (or 2 or 4) digit station code for each station within the desired network
#Example: Network ZR from 2015-2018 has stations W1A, W1B, W2A, W2B, etc.
#This code assumes all stations are within the same network, will require some tweaking otherwise



NumStations=$(wc -l < $StatList) # Defines number of stations
echo "$NumStations Stations Found In Station List"

for event in `ls -ad ${DirPref}*`; do # Loops through event directories 
    cd $event 
    echo "Working on $event"
    
    if [ -f $infile ]; then
	cat /dev/null > $infile
    else
	touch $infile # Creates input file
    fi

    for i in $(seq 1 $NumStations); do
	CurStat=$(awk 'NR=='$i'{ print; exit }' ../$StatList) # Reads the i'th line of the station list
	doRotatedFilesExist=$(find . -maxdepth 1 -mindepth 1 -type f -name "$CurStat.r")

	if [ -z "$doRotatedFilesExist" ]; then 
	    :
        else
		echo "$CurStat.$r_file_input" >> $infile # Defines radial input file
		echo "$CurStat.$z_file_input" >> $infile # Defines vertical input file
		echo "$event.$CurStat.g.$gaussian.itr" >> $infile # Defines the radial output file
		echo $iterations >> $infile
		echo $phaseshift >> $infile
		echo $delta >> $infile
		echo $gaussian >> $infile
		echo $wvforms >> $infile
		echo "0" >> $infile
		echo "$CurStat.$t_file_input" >> $infile # Defines tangential input file
		echo "$CurStat.$z_file_input" >> $infile # Defines vertical  input file
		echo "$event.$CurStat.g.$gaussian.itt" >> $infile # Defines the tangential output file
		echo $iterations >> $infile
		echo $phaseshift >> $infile
		echo $delta >> $infile
		echo $gaussian >> $infile
		echo $wvforms >> $infile
		echo "0" >> $infile

        fi
    done 
    
    if [[ $MakeRFs == "1" ]];
    then
    	if [[ $LogOutput == "1" ]];
	then
		$iterdecon <input.iterdecon >output.iterdecon
	else
		$iterdecon  <input.iterdecon
	fi
    else
    	echo "Successfully created input files for iterdecon, but did not run iterdecon"
    fi
    
    cd $StartDir 
done 
