% Remove artifacts from the data using the marked data segments to train
% the MWF covariance matrices

function [eeg_filtered_MWF,SER,ARR] = remove_artifacts(eeg_data,Fs)

% Load eeg_data, Fs, duration
% load(['EEG_data_readout' filesep 'eye_blink_lorenz.mat'])

% Select first x seconds as training data
training_duration = 30;
training_data = eeg_data(:,1:Fs*training_duration);

% Create .mat file to be loaded by EyeBallGUI
FileEEGdata = training_data;
FileEEGsrate = Fs;
save(['TRAINING_DATA.mat'],'FileEEGdata','FileEEGsrate')

% Launch EyeBallGUI
EyeBallGUI

% Wait until the "Bad" file exists with markings in the directory. If one
% exists already, delete it
if(exist('TRAINING_DATABad.mat','file'))
    delete('TRAINING_DATABad.mat');
end
while(~exist('TRAINING_DATABad.mat','file'))
    pause(1);
end

% Close GUI after markings are saved and clean up backup files
close all force
rmdir('EyeBallGUI_BackUp','s')
delete('EyeBallGUIini.mat')

% Extract marked eye blinks from markings .mat file
load('TRAINING_DATABad.mat');
mask = isnan(EEGmask);  % 1's where artifacts are marked
training_blinks = sum(mask,1);
training_blinks(training_blinks>0) = 1;

% Perform MWF filtering
[eeg_filtered_MWF,SER_MWF,ARR_MWF] = filter_MWF(training_data,training_blinks,eeg_data);
[eeg_filtered_PE,SER_PE,ARR_PE] = filter_MWF_PE(training_data,training_blinks,eeg_data);
[eeg_filtered_GEVD,SER_GEVD,ARR_GEVD] = filter_MWF_GEVD(training_data,training_blinks,eeg_data);

% Collect performance parameters
SER = [SER_MWF,SER_PE,SER_GEVD];
ARR = [ARR_MWF,ARR_PE,ARR_GEVD];

% EEG plot of the original data and the filtered data on top in red
eegplot(eeg_data,'data2',eeg_filtered_MWF,'srate',Fs,'winlength',10,'dispchans',3,...
    'spacing',200,'title','Original EEG data (blue) + Filtered EEG data (red)')

% EEG plot of the original data and the filtered data on top in red
eegplot(eeg_filtered_MWF,'data2',eeg_filtered_PE,'srate',Fs,'winlength',10,'dispchans',3,...
    'spacing',200,'title','MWF (blue) + MWF_PE (red)')

% Clean up directory
cleanup

end
