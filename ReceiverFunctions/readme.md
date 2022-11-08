# Receiver Function Scripts
#### A collection of scripts that helps with making receiver function stacks.

### Summary
1. IterdeconByEvents uses the iterative time-domain deconvolution (iterdecon) method for making RFs 3 component seismic data that has is organized by event and has already been rotated (use RotateData).
   - This DOES NOT include iterdecon, it just automates calling iterdecon for large sets of seismic data.
2. MovePoorCorrelation sets aside RFs made with Iterdecon with low correlation values into a subdirectory within each event folder to set them aside from stacking.
3. SortRFsByStations takes RFs organized by event and sorts them by station, primarily for stacking.
4. StackRFs stacks RFs from the same station.
