% Retrieve the hybrid EEG data with artificial eye blink artifact 
% corresponding to the given name input. If no hybrid EEG data is present 
% in the cache, the data will be generated and stored in the cache.
%
% The cache directory to read/write is set by mwfgui_localsettings.m
%
% INPUTS:
%   name        subject identifier (string)
%
% OUTPUTS: 
%   eeg_data    raw eeg data with artificial artifacts (channels x samples)
%   mask        ground truth mask with artifact locations (1 x samples)
%   blinkchannel  ground truth single-channel artifact (1 x samples)
%   spatialdist   ground truth spatial mixing vector (channels x 1)
%   Fs          EEG data sample rate
%   duration    EEG data recording duration in seconds
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [eeg_data, mask, blinkchannel, spatialdist, Fs, duration] = get_artifact_data_synthetic(name)

if (isa(name,'double'))
    name = get_name_from_id(name);
end

settings = mwfgui_localsettings;
path = fullfile(settings.syntheticpath,[name '_synthetic.mat']);
if (~exist(path, 'file'))
    warning(['No saved synthetic data for subject ' name ...
        ' was found in current path. New data will be generated in ' path '.'])
    EEG_data_synthetic(name);
end

S = load(path, '-mat');
eeg_data    = S.eeg_data;
mask        = S.mask;
blinkchannel = S.blinkchannel;
spatialdist = S.spatialdist;
Fs          = S.Fs;
duration    = S.duration;

end

