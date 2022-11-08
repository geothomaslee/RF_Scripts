This is a collection of scripts for processing raw seismic data.
If you're making receiver functions, these should be run before Iterdecon.
If you're running all of these, they should be run in the order that they're listed below.

IMPORTANT NOTE: FilterData assumes that the data has already been rotated. It also assumes the naming convention for files made from the RotateData script.
I may update this in the future to be more flexible, but I don't have any use for that currently because I'm working on receiver functions.

MoveSmallTraces - sets aside SAC files that do not contain actual seismic data
RotateData - can rotate E/W N/S components into radial/tangential components
FilterData - automates various filtering processes. NOTE: assumes data has already been rotated

EXTENDED DOCUMENTATION FOR SCRIPTS

FilterData
This script can automatically filter large amounts of seismic data using SAC commands.
It assumes the file structure of ScriptFolder/Events/seismicdata.sac where ScriptFolder is the directory from which you run this script.

This can perform several things:

Downsampling
Remove mean
Remove trend
Bandpass filter
