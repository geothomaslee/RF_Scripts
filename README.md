# Receiver Function Scripts and other SAC Tools
#### A collection of bash scripts for processing SAC (Seismic Analysis Code) files, intended to speed up the pipeline for receiver function analysis via iterative time-domain deconvolution (iterdecon).

I wrote most of these scripts as an undergraduate while working on a receiver function project at Laguna Maule volcano in Chile. As such, many of the default/example values may reflect that. The efficiency and quality of the code also probably reflect that I wrote these as an undergraduate just learning how to code. That said, these do work for their very specific purpose.

Processing helps make the traces ready for input into Iterdecon. ReceiverFunctions contains scripts for feeding the data into Iterdecon. Post-processing helps organize the data to make it easier to work with, including stacking by station. All of these are done in Bash.

Visualizing contains Python scripts that can help plot receiver functions in various ways to help visualize the data.
