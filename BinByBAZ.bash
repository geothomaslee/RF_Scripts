#!/bin/bash

BinSize="30" # Size of bins in degrees 
## MUST BE A FACTOR OF 360 ##

StatDir="Stations" # Location of station folder
StatPref="W" # Common prefix for all station names
BAZDir="Backazimuth_Bins" # Name of directory for backazimuth bins

StartDir=`pwd`
StatDir="$StartDir/$StatDir"

BinCheck=$(bc <<< "scale=2; 360/$BinSize") # Checks if 360/BinSize is an intege to check that the bin is a factor of 360
BinCheckIsInt=$(echo "$BinCheck" | grep -o '..$')
if [[ "$BinCheckIsInt" == "00" ]];
then
	:
else
	echo "Error: Bin size is not factor of 360. Exiting now. Adjust bin size"
	exit 1
fi

lastBin=$((360 - $BinSize)) # If we go all the way to 360, the 360 folder should contain same data as 0 folder. Makes last bin the one before 360

cd $StatDir

doBAZAlreadyExist=$(find -type d -name "$BAZDir")
doesBAZStackAlreadyExist=$(find -type d -name "BAZStacks")

if [[ -z $doBAZAlreadyExist ]]; # Checks if program has been previously run and gives you the option to figure it out before breaking anything
then
	:
else
	echo "Backazimuth binning has previously been run."
	echo "Do you wish to remove previous backazimuth bins? [Y/N]"
	read WriteOverBAZ

	if [[ $WriteOverBAZ == "Y" ]];
	then
		echo "Removing previous backazimuth bins"
		rm -r $doBAZAlreadyExist
		rm -r $doesBAZStackAlreadyExist
	else
		echo "Exiting now."
		exit 1
	fi
fi

for stat in `ls -ad ${StatPref}*`; do
	cd $stat
	echo "Working on $stat"

	mkdir $BAZDir
	cd $BAZDir

	for bin in $(seq 0 $BinSize $lastBin); do
		mkdir $bin
	done
	

	touch binreport.txt
	cat /dev/null > binreport.txt

	cd $StatDir/$stat # Moves back to current station directory
	
	for trace in $(find -mindepth 1 -maxdepth 1 -type f -name "*.itr"); do

		BAZWithDecimal=$(saclst BAZ f $trace | awk '{print "\t"$2}')
		BAZWithSpaces=${BAZWithDecimal%.*} # Removes the decimal from the BAZ 
		BAZ=$(echo $BAZWithSpaces | sed 's/ //g')
		

		for binplac in $(seq 0 $BinSize $lastBin); do
			currentBottom=$binplac
			currentTop=$(( $binplac + $BinSize))

			if [ $BAZ -ge $currentBottom ] && [ $BAZ -lt $currentTop ];
			then
				#echo "$trace has a BAZ of $BAZ and belongs in bin $binplac because it is between $currentBottom and $currentTop" #Debug line
				cp $trace $StatDir/$stat/$BAZDir/$binplac
			else	
				:
			fi
		done
	done

	cd $BAZDir
	for bin in `ls -d */`; do
		binClean=${bin%/*}
		binTop=$(($binClean + $BinSize))
		
		cd $bin

		NumFiles=$(find -mindepth 1 -type f -name "*.itr" | wc -l)
		echo "$binClean to $(( $binClean + $BinSize )) degrees: $NumFiles events" >> ../binreport.txt


		if [[ $NumFiles -gt 0 ]]; then # Avoids potential to divide by 0

			touch stacktemp.txt
			cat /dev/null > stacktemp.txt		
			find -mindepth 1 -type f -name "*.itr" >> stacktemp.txt

			CurStackFile="$stat.$binClean.stack"

			firstfile=$(head -n 1 stacktemp.txt)
			echo "r $firstfile" >> $CurStackFile

			for traceNum in $(seq 2 1 $NumFiles); do
			curFile=$(awk 'NR=='$traceNum'{print; exit }' stacktemp.txt)
			echo "addf $curFile" >> $CurStackFile
			done

			echo "div $NumFiles" >> $CurStackFile
			echo "w $binClean.$binTop.$stat.stack.itr" >> $CurStackFile
			echo "q" >> $CurStackFile	

			rm stacktemp.txt

			sac ./$CurStackFile
			rm $CurStackFile
		fi

		cd ../
	done

	cd $StatDir/$stat
		
	mkdir BAZStacks

	cp $(find -mindepth 1 -type f -name "*.stack.itr") ./BAZStacks	

	cd $StatDir
done


