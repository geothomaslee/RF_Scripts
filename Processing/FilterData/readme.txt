IMPORTANT NOTE: FilterData assumes that the data has already been rotated. It also assumes the naming convention for files made from the RotateData script.
I may update this in the future to be more flexible, but I don't have any use for that currently because I'm working on receiver functions.

This script can automatically filter large amounts of seismic data using SAC commands.
It assumes the file structure of ScriptFolder/Events/seismicdata.sac where ScriptFolder is the directory from which you run this script.

This can perform several things:

Downsampling
Remove mean
Remove trend
Bandpass filter
