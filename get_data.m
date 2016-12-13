function [ eeg_data, Fs, duration ] = get_data( name, artifact )
% Return a dataset for subject 'name' in artifact condition 'artifact'.
%
% If the data has been read and saved before using EEG_data_readout, the
% data is just loaded from the saved struct. If the name/artifact pair has
% no associated save file yet, it's created in the EEG_data_readout folder.
%
% name is expected to be either a string name or integer representing the
% alphabetical order of the 10 names.
% alex, anneleen, hanneke, jan-peter, jeroen, jonas, lorenz, olivia, otto, steven
%
% artifact is expected to be one of the following:
% eyeblink, muscle, speech, movement, mix
%
% output values are eeg_data in channels x samples format, sample rate and
% duration of the EEG data measurement
%

if (isa(name,'double'))
    name = get_name(name);
end
if (~ischar(name) || ~ischar(artifact))
    error('Error: invalid name or artifact specifier')
end

path = ['EEG_data_readout' filesep name '_' artifact '.mat'];
if (~exist(path, 'file'))
    warning(['No saved data for subject ' name ' for artifact type ' ...
        artifact ' was found in current path. New data will be generated in '...
        pwd filesep path '.'])
    
    EEG_data_readout(name, artifact)
end

S = load(path, '-mat');
eeg_data    = S.eeg_data;
Fs          = S.Fs;
duration    = S.duration;

end

