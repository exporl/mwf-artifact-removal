# MWF-based EEG artifact removal in MATLAB 

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations. 
By downloading and/or installing this software and associated files on your computing system you agree to use the software under the terms and condition as specified in the License agreement.


## Manual

### About
A more detailed manual will follow soon.
 
Developed and tested in MATLAB R2015a. Required toolboxes:
 - EEGLAB (only required for manual marking of artifacts). [EEGLAB website](https://sccn.ucsd.edu/eeglab/index.php)

 
### Quick start guide
 
 All functions needed to perform MWF-based EEG artifact removal are in the mwf folder. The MWF-based artifact removal process is done in two steps:
 
 1. Split the data in EEG containing artifacts and EEG free of artifacts.
 2. Based on the segmentation in step 1, compute and apply a multi-channel Wiener filter.


 Step 1. is performed by manual marking of the data in a GUI. If you have your EEG
 data matrix in the the MATLAB workspace (channels x samples), you can obtain the artifact mask by calling
 
     mask = mwf_getmask(EEG, samplerate)
 
 This pops up a GUI in which artifacts can be marked by clicking and dragging over them. When done, clicking
 the 'Save Marks' button will close the GUI and the function returns a binary (1 x samples) mask. 
 In this mask, ones correspond to artifact segments, and zeroes correspond to clean data.
 
 Step 2. is performed by calling the mwf_process function on the EEG data, along with the created mask:
 
     clean_EEG = mwf_process(EEG, mask, delay)

 This will return the artifact-free EEG as clean_EEG. Note that an optional parameter delay can be passed 
 to the function, which includes temporal information into the filter, leading to better artifact removal 
 but longer processing time. See [1] for more details.


 ### References
 
 [1] B. Somers, T. Francart, A. Bertrand (2018). A generic EEG artifact removal algorithm based on the multi-channel Wiener filter. 
 Journal of Neural Engineering (Manuscript accepted for publication)
