% Figure of marking process in EEGLAB

settings = mwfgui_localsettings;

name = 10;
artifact = 'eyeblink';
redo = 1;
[y, Fs, duration] = get_artifact_data(name, artifact);
mask = get_artifact_mask(name, artifact, redo);

% MAKE MARKINGS IN PLOT THAT POPS OPEN
%   - EEG voltage scale to 50
%   - number channels to 20, display from 29 to 49
%   - time range to 10 seconds, display from 28 to 38
%
% PRESS CTRL + C TO FREEZE GUI

print(fullfile(settings.figurepath,'gui.eps'), '-depsc2');

% RESIZE EPS IN INKSCAPE: FIT DOCUMENT SIZE TO CONTENTS
% SAVE TO PDF