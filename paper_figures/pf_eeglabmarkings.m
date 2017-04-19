% Figure of marking process in EEGLAB

settings = mwfgui_localsettings;

name = 1;
artifact = 'muscle';
redo = 1; % put to 1 if you want to use the eyeballgui to make the mask
[y, Fs, duration] = get_data(name, artifact);
mask = get_artifact_mask(name, artifact, redo);
