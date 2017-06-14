function [eeg_data, mask, blinkchannel, spatialdist, Fs, duration] = get_data_synthetic(name)
% Return a synthetic dataset for subject 'name'.
%
% name is expected to be either a string name or integer representing the
% alphabetical order of the 10 names.
% alex, anneleen, hanneke, jan-peter, jeroen, jonas, lorenz, olivia, otto, steven
%
% output values are 
% - eeg_data in channels x samples format, 
% - ground truth artifact locations
% - ground truth one-dimensional artifact signal
% - ground truth spatial artifact mixing vector
% - sample rate 
% - duration of the EEG data measurement
%

if (isa(name,'double'))
    name = get_name(name);
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

