% Read out raw EEG data containing artifacts corresponding to the given 
% name/artifact inputs from bdf files. The result is stored in the cache.
%
% The cache directory to read/write and the cache directory with raw bdf 
% files is set by mwfgui_localsettings.m.
%
% INPUTS:
%   name        subject identifier (string)
%   artifact    artifact type specifier (string)
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function EEG_data_readout(name, artifact)
settings = mwfgui_localsettings;

% Specify the desired working frequency Fs and reference channel
Fs = 200;
refchan = 48;

% Specify the location of the file on the PC (make sure it's on the matlab path!)
folder = settings.rawdatapath;

% bdf_loc = [folder name '\blink.bdf'];
bdf_loc = fullfile(folder,name,[artifactBDFname(artifact) '.bdf']);

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

% Rereference to Cz (channel 48)
eeg_data = bsxfun(@minus, eeg_data, eeg_data(refchan,:));
eeg_data(refchan,:) = [];

% Save the structure and resampled frequency to a mat-file
save(fullfile(settings.savedatapath,[name '_' artifact '.mat']),'eeg_data','Fs','duration');

end

% Transform bdf naming to artifact names used in this toolbox
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
end



