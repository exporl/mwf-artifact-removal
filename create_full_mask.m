
cleanup

% Load eeg_data, Fs, duration
% load(['EEG_data_readout' filesep 'eye_blink_lorenz.mat'])

% Create .mat file to be loaded by EyeBallGUI
FileEEGdata = eeg_data;
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
full_mask = sum(mask,1);
full_mask(full_mask>0) = 1;

cleanup

save('full_masks\full_mask_blinks_steven.mat','full_mask') % EDIT NAME
