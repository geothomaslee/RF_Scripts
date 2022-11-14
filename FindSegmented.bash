#!/bin/bash

DirPref="Event_" # Common prefix for all event directories
StartDir=`pwd`
StatList="$StartDir/StationList.txt"

## COMPONENT NAMES ##
Comp1="HH1" # First horizontal component code
Comp2="HH2" # Second horizontal component code
CompVert="HHZ" # Vertical component code


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

if [ -d $StartDir/Missing_And_Excess_Components ];
then
	:
else
	mkdir $StartDir/Missing_And_Excess_Components
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
				NumComp1=$(grep -c $Comp1 FindSegmentedTempFile.txt)
				NumComp2=$(grep -c $Comp2 FindSegmentedTempFile.txt)
				NumCompVert=$(grep -c $CompVert FindSegmentedTempFile.txt)

				if [[ $NumComp1 -gt "1" ]] || [[ $NumComp2 -gt "1" ]] || [[ $NumCompVert -gt "1" ]];
				then
					echo "$CurStat in $event has excess and missing components"
					if [ -d $StartDir/Missing_And_Excess_Components/$event ];
					then
						:
					else
						mkdir $StartDir/Missing_And_Excess_Components/$event
					fi
					mv $Comps $StartDir/Missing_And_Excess_Components/$event
				fi
			else
				if [[ $NumComps -lt "3" ]];
				then
					echo "$CurStat in $event is missing components"
					if [ -d $StartDir/Missing_Components/$event ];
					then
						:
					else
						mkdir $StartDir/Missing_Components/$event
					fi 
					mv $Comps $StartDir/Missing_Components/$event
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
					mv $Comps $StartDir/Segmented_Components/$event
				fi
			fi

					
		fi

		cat /dev/null > FindSegmentedTempFile.txt
	done
	cd $StartDir
done

rm FindSegmentedTempFile.txt

TempFiles=$(find -mindepth 1 -maxdepth 3 -type f -name "FindSegmentedTempFile.txt")
rm $TempFiles
