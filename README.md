# MWF-based EEG artifact removal in MATLAB 

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations. 
By downloading and/or installing this software and associated files on your computing system you agree to use the software under the terms and condition as specified in the License agreement.

## Using the MWF-EEG toolbox

### About
 
Developed and tested in MATLAB R2015a. Required toolboxes:
 - EEGLAB (only required for manual marking of artifacts). [EEGLAB website](https://sccn.ucsd.edu/eeglab/index.php).  
 (Make sure EEGLAB is added to the MATLAB path: you can check this by typing "eeglab" in the command window)

### Documentation

A more detailed manual will follow soon.
 
### Quick start guide
 
All functions needed to perform MWF-based EEG artifact removal are in the mwf folder.
Before starting, make sure that this folder is added to the MATLAB path.
The MWF first requires examples of EEG with and EEG without artifacts. Based on this
segmentation of the EEG data, the MWF can be computed and applied in order to remove
the artifacts. This two-step approach is fully implemented in the toolbox.

**Step 1: EEG segmentation.** In the toolbox, this step is performed by manual marking
of the data using a GUI. If you have your EEG data matrix in the the MATLAB workspace
(channels x samples), you can obtain the artifact mask by calling

     mask = mwf_getmask(EEG, samplerate)
 
This pops up the GUI in which artifacts can be marked by clicking and dragging over
them. When done, clicking the 'Save Marks' button will close the GUI and the function
returns a binary (1 x samples) mask. In this mask, ones correspond to artifact segments, and
zeros correspond to clean data.

The artifact detection step is not inherently a part of the MWF algorithm: if you prefer,
you can also use a different method for acquiring the artifact mask (e.g. an automatic method,
for example based on thresholding,. . . ). The mask needs to consist of ones and zeros, and
have the same length as the EEG data.
 
**Step 2: MWF artifact removal** is performed by calling the mwf process function. It
requires the EEG data, the mask indicating which segments are artifacts, and optionally a
delay parameter:
 
     clean_EEG = mwf_process(EEG, mask, delay)

This will return the artifact-free EEG in the clean EEG variable. Using the optional delay
parameter includes temporal information into the filter, leading to better artifact removal but
may increase processing time. If omitted, the default value is zero. See [1] for more details.


 ## References
 
 [1] B. Somers, T. Francart, A. Bertrand (2018). A generic EEG artifact removal algorithm based on the multi-channel Wiener filter. 
 Journal of Neural Engineering (Manuscript accepted for publication)
