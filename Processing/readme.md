# Pre-RF Processing Scripts

This is a collection of scripts for processing raw seismic data.
If you're making receiver functions, these should be run before Iterdecon.
If you're running all of these, they should be run in the order that they're listed below.

### SUMMARY 
1. MoveSmallTraces - sets aside SAC files that do not contain actual seismic data
2. FindSegmented - looks for stations that have components segmented into multiple files, also looks for missing components
3. RotateData - can rotate E/W N/S components into radial/tangential components
4. FilterData - automates various filtering processes. NOTE: assumes data has already been rotated

## MoveSmallTraces
This script removes empty traces using 2 different detection methods.

1. Checks the size of the file and sets it aside if it's below a certain threshold, assuming that metadata will only take up a small amount of disk space.
   - Default threshold is 10kb which works well in my testing, but can be adjusted if necessary
2. Checks the depmax (maximum amplitude) header in SAC and if it's undefined, assumes the file is empty and sets it aside.

## FindSegmented
This script looks for components that have been segmented into multiple files. It may be possible to simply splice the files together, but these often contain time gaps that make the data unusable. It also looks for stations with missing components and sets aside the files. Makes 3 directories.
1. Segmented_Components - for segmented components
2. Missing_Components - for missing components
3. Missing_And_Excess_Components - for situations where previous 2 methods didn't detect issues because there are 3 files, but one or more are missing and one or more have repeats.  
   - Requires channel names to be defined according to your data at the beginning of the script.

## RotateData
This script can automatically rotate large amounts of 3 component seismic data using SAC's rotate command.
It is assumed that the data is grouped by event and the script is run in the directory that contains the event directories.

#### The following fields are required to be defined for this to work:
* CMPAZ - component azimuth
* CMPINC - component inclination
* STLA - station latitude
* STLO - station longitude
* EVLA - event latitude
* EVLO - event longitude

##### Common Errors
* Bad number of files read in upon execution of first rotate file: happens when you forget to provide a station list

## FilterData
### IMPORTANT NOTE: FilterData assumes that the data has already been rotated. It also assumes the naming convention for files made from the RotateData script.
I may update this in the future to be more flexible, but I don't have any use for that currently because I'm working on receiver functions.

This script can automatically filter large amounts of seismic data using SAC commands.
It assumes the file structure of ScriptFolder/Events/seismicdata.sac where ScriptFolder is the directory from which you run this script.

##### This can perform several things:
* Downsampling
* Remove mean
* Remove trend
* Bandpass filter
