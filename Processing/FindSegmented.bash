#!/bin/bash

DirPref="Event_" # Common prefix for all event directories
StartDir=`pwd`
StatList="$StartDir/StationList.txt"

if [ -d $StartDir/Missing_Components ];
then
	:
else
	mkdir $StartDir/Missing_Components
fi

if [ -d $StartDir/Segmented_Components ];
then
	:
else
	mkdir $StartDir/Segmented_Components
fi

StatCount=$(wc -l < $StatList)

echo "$StatCount stations found"

cat /dev/null > FindSegmentedTempFile.txt

for event in `ls -ad ${DirPref}*`; do
	cd $event
	echo "Working on $event"
	for stat in $(seq 1 $StatCount); do
		CurStat=$(awk 'NR=='$stat'{ print; exit }' $StatList) # Reads current station
		Comps=$(find -mindepth 1 -maxdepth 1 -type f -name "*$CurStat*.SAC")
		
		echo "$Comps" >> FindSegmentedTempFile.txt

		if [[ -z $Comps ]];
		then
			:
		else	
			NumComps=$(wc -l < FindSegmentedTempFile.txt)
			if [[ $NumComps == "3" ]];
			then
				:
			else
				if [[ $NumComps -lt "3" ]];
				then
					echo "$CurStat in $event is missing components"
					if [ -d $StartDir/Missing_Components/$event];
					then
						:
					else
						mkdir $StartDir/Missing_Components/$event
					fi 
					cp $Comps $StartDir/Missing_Components/$event
				fi
				
				if [[ $NumComps -gt "3" ]];
				then
					echo "$CurStat in $event has more than 3 files, likely segmented"
					
					if [ -d $StartDir/Segmented_Components/$event ];
					then
						:
					else
						mkdir $StartDir/Segmented_Components/$event
					fi
					cp $Comps $StartDir/Segmented_Components/$event
				fi
			fi
		fi

		cat /dev/null > FindSegmentedTempFile.txt
	done
	cd $StartDir
done

rm FindSegmentedTempFile.txt
