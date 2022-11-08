This script removes empty traces, 2 different detection methods.

Method 1 checks the size of the file and sets it aside if it's below a certain threshold, assuming that metadata will only take up a small amount of disk space.
Method 2 uses the depmax (maximum amplitude) header in SAC and if it's undefined, assumes the file is empty and sets it aside.
