% Create mask for artifacts in an EEG measurement, specified by subject
% name and artifact type. The created masks are all 0 in artifact-free
% segments, and 1 in marked artifact segments.
%
% The argument redo can be specified to indicate if the has to be redone
% (for example if a bad marking was saved).
%
% Masks are returned as output and saved in the EEG_artifact_masks folder.
%
% This function generates the masks using the EyeBallGUI. The purpose of
% saving them is so they can easily be reused in the MWF analysis scripts
% without having to remark the artifacts for every EEG dataset.

function [mask] = get_artifact_mask(name , artifact , redo)

if (nargin <3)
    redo = 0;
end

if (isa(name,'double'))
    name = get_name(name);
end

maskpath = ['EEG_artifact_masks\' name '_' artifact '_mask.mat'];

if (~exist(maskpath, 'file') || redo)
    
    [FileEEGdata, FileEEGsrate, ~] = get_data(name, artifact); %#ok
    
    % Create .mat file to be loaded by EyeBallGUI
    save('TRAINING_DATA.mat','FileEEGdata','FileEEGsrate')
    
    % Launch EyeBallGUI
    EyeBallGUI
    
    % Wait until the "Bad" file exists with markings in the directory. If one
    % exists already, delete it
    if(exist('TRAINING_DATABad.mat','file'))
        delete('TRAINING_DATABad.mat');
    end
    while(~exist('TRAINING_DATABad.mat','file'))
        pause(1);
    end
    
    % Close GUI after markings are saved and clean up backup files
    close all force
    rmdir('EyeBallGUI_BackUp','s')
    delete('EyeBallGUIini.mat')
    
    % Extract marked artifact segments from markings .mat file
    load('TRAINING_DATABad.mat');
    mask = isnan(EEGmask);  % 1's where artifacts are marked
    mask = sum(mask,1);
    mask(mask>0) = 1;
    
    cleanup_EyeBallGUI;
    
    % save results
    save(maskpath, 'mask')
    
else % mask already exists
    
    S = load(maskpath);
    mask = S.mask;
    
end

end
