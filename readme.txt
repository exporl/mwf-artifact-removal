### MATLAB CODE FOR MWF-BASED EEG ARTIFACT REMOVAL ###

Required toolboxes:
 - EyeBallGUI (if you need to create masks)
 - eegorl toolbox (if you need to read out BDF files)

The functions should work as-is in the toolbox. The only system-dependent variable to be set right is in EEG_data_readout, where the path to the raw bdf files is specified (to be fixed later).


The functions are currently built to work on a closed dataset of ~10 subjects with each an eyeblink artifact and a muscle artifact measurement. The a demonstration of this toolbox is given in demo_eyeblink.m:

 1. get_data -> get EEG data to process. If the data is preloaded, the .mat file is loaded, otherwise the data will be read out from the raw bdf files and saved.

 2. get_artifact_mask -> get the artifact mask corresponding to EEG data. If a mask was previously made it can be loaded, otherwise the eyeballgui is used to mark the artifacts. Setting the 'redo' argument to 1 also allows to redo the mask if it was saved before.

 3. filter_compute -> create GEVD-based MWF based on data and mask. A params struct can be passed on to alter parameters of the MWF processing (#time delays used, rank to keep in GEVD approximation,...)

 4. filter_apply -> apply a computed filter to the EEG data. Returns artifact estimate d and clean data v.

 5. filter_performance -> compute performance parameters for the artifact removal. SER is a measure for signal degradation in non-artifact parts. ARR is a measure for how well artifact estimate resembles real artifacts. Both are in dB and should be as high as possible.


The files starting with 'study' are scripts using the various functions to explore parameter settings and create graphs.


### HOW TO USE THE GUI FOR CREATING THE ARTIFACT MASK ###

The eyeballGUI use is implemented in get_artifact_mask.m. 

 - the code creates a .mat file called "TRAINING.mat" in the current directory
 - when the GUI is launched, select TRAINING.mat and click "view"
 - mark the artifact segments by clicking and dragging over them (also see EyeBallGUI manual)
 - when done, click "quick save" or close the window and save
 - from here on the code will take over again, load your markings and return is as a one-channel mask
