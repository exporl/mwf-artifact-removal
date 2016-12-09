% Read out the EEG data corrupted with artifacts
% 
% INPUT: artifacted .bdf files for the 10 test subjects, referenced by both
% a name and the artifact type
%
% OUTPUT: EEG data as channels x samples, saved in the EEG_data_readout 
% folder in the format <name>_<artifact_type>.mat. 
%
% Also saves the working sample rate Fs and measurement duration.
%

function EEG_data_readout(name, artifact)

% Specify the desired working frequency Fs
Fs = 200;

% Specify the location of the file on the PC (make sure it's on the matlab path!)
folder = 'C:\Users\gebruiker\Documents\KULeuven Doctoraat\Thesispaper 2 - GUI\EEG Data - Artifacts';

% bdf_loc = [folder name '\blink.bdf'];
bdf_loc = [folder filesep name filesep artifactBDFname(artifact) '.bdf'];

% Read out the bdf file
eeg_struct  = biopil_raw_data('FileName',bdf_loc, 'MultipleEpochs', 'ignore','Channels','all');

% Extract some relevant figures from the read out data
Fs_original = eeg_struct.FileHeader.SampleRate; % Original sample frequency
duration = eeg_struct.FileHeader.RecordCount;   % Duration of measurement in seconds

% Apply high- and lowpass filtering as preprocessing
eeg_struct = biopil_filter(eeg_struct,'HighPass', 1,'LowPass', [] );

% Resample the EEG measurement from 8192 Hz to a lower working frequency Fs
% Resample() already applies a LP Anti-Aliasing Filter
eeg_struct.RawData.EegData = resample(double(eeg_struct.RawData.EegData),Fs,Fs_original);

% Put the data in the right format (channels x samples)
eeg_data = (eeg_struct.RawData.EegData(:,1:64)).';

% Save the structure and resampled frequency to a mat-file
save(['EEG_data_readout' filesep name '_' artifact '.mat'],'eeg_data','Fs','duration');


function [artifact_file] = artifactBDFname(artifact)

switch artifact
    case 'eyeblink'
        artifact_file = 'blink';
    case 'muscle'
        artifact_file = 'clench';
    case 'speech'
        artifact_file = 'count';
    case 'movement'
        artifact_file = 'nod';
    case 'mix'
        artifact_file = 'random';
    otherwise
        error('Error: Specified artifact type not found')
end


