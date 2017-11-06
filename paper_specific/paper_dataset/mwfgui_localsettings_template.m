% Return local system directories for reading/writing cached EEG data.
%
% INSTRUCTIONS:
%  - make a copy of this template and rename it mwfgui_localsettings.m
%  - make sure that the copy is on the Matlab path
%  - change the file paths in this file to your local system directories
%       where you'd like to cache the EEG data.
%
% OUTPUTS: 
%   settings    struct containing local directory paths
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function settings = mwfgui_localsettings

settings = struct;

% Read cache with bdf recording files
settings.rawdatapath = 'C:\...';

% Read/write cache for raw EEG data
settings.savedatapath = 'C:\...';

% Read/write cache for artifact masks of raw EEG data
settings.savemaskpath = 'C:\...';

% Read/write cache for hybrid EEG data
settings.syntheticpath = 'C:\...';

% Write path for generating figures
settings.figurepath = 'C:\...';
end
