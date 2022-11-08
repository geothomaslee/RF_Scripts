#!/bin/bash
# Edited 8/18/2017 by EER to check SAC files aren't empty
# Edited 10/20/2022 by TL to be adjustable for file structures
# Edited 11/7/22 by TL to be even more adjustable

## COLOR TABLE ##
RED='\033[1;31m'
NC='\033[0m' # Resets to no color

DirPref="Event_" # Prefix for directories containing SAC files
ProbDir="Small_Traces" # Defines the name of the problem folder
StartDir=`pwd`
EmptyThreshold="10" # Threshold for assuming that a file contains only metadata, in kilobytes

for evt in `ls -ad $DirPref*`; do 
	cd $evt
if [ -d $ProbDir ] ; then
	:
else
	mkdir $ProbDir
fi

   traces=`ls *.SAC`
   for trace in $traces ; do 
		size1=`saclst depmax f $trace | awk '{print $2}'`
		size2=`du $trace | awk '{print $1}'`
		if [ $size2 -lt $EmptyThreshhold ]; then
			echo -e "${RED}Small trace found${NC}"
			mv $trace $ProbDir
		fi
		if [ "$size1" == "-nan" ]; then
			echo -e "${RED}Empty SAC file found${NC}"
			mv $trace $ProbDir
		fi
                if [ "$size1" == "nan" ]; then
                        echo -e "${RED}Empty SAC file found${NC}"
                        mv $trace $ProbDir
                fi
	done
	cd $StartDir
done
