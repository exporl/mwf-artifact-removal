% Retrieve the EEG data corresponding to the given name/artifact inputs. 
% If no EEG data is present in the cache, the data will be read out from 
% the raw bdf files and stored in the cache.
%
% The cache directory to read/write is set by mwfgui_localsettings.m
%
% INPUTS:
%   name        subject identifier (string)
%   artifact    artifact type specifier (string)
%
% OUTPUTS: 
%   eeg_data    raw eeg data with artifacts (channels x samples)
%   Fs          EEG data sample rate
%   duration    EEG data recording duration in seconds
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [eeg_data, Fs, duration] = get_artifact_data(name, artifact)

if (isa(name,'double'))
    name = get_name_from_id(name);
end
if (~ischar(name) || ~ischar(artifact))
    error('Error: invalid name or artifact specifier')
end

settings = mwfgui_localsettings;
path = fullfile(settings.savedatapath,[name '_' artifact '.mat']);
if (~exist(path, 'file'))
    warning(['No saved data for subject ' name ' for artifact type ' ...
        artifact ' was found in current path. New data will be generated in '...
        path '.'])
    
    EEG_data_readout(name, artifact)
end

S = load(path, '-mat');
eeg_data    = S.eeg_data;
Fs          = S.Fs;
duration    = S.duration;

end

