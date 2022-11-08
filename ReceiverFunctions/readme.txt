A collection of scripts that helps with making receiver function stacks.

IterdeconByEvents uses the iterative time-domain deconvolution (iterdecon) method for making RFs 3 component seismic data that has is organized by event and has already been rotated (use RotateData)
MovePoorCorrelation sets aside RFs made with Iterdecon with low correlation values into a subdirectory within each event folder to set them aside from stacking.
SortRFsByStations takes RFs organized by event and sorts them by station, primarily for stacking.
StackRFs stacks RFs from the same station.
