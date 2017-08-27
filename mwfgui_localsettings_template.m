% Copy & paste this file and set the paths to your corresponding system folders

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
