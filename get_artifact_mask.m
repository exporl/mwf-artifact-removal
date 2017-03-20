% Create mask for artifacts in an EEG measurement, specified by subject
% name and artifact type. 
%
% The argument redo can be specified to indicate if the has to be redone
% (for example if a bad marking was saved).
%
% INPUT:
%        name - Name of subject. Used in search for corresponding files.
%        artifact - Type of artifact
%        redo - 0 - If a corresponding mask is already present, always load that one
%               1 - redo the mask, regardless of whether it exists already
%        mode - Input to specify which tool to use to mark artifacts
%               mode = 0 - EyeBallGUI
%               mode = 1 - EEGLAB
% OUTPUT:
%        mask - All 0 in artifact-free segments, and 1 in marked artifact 
%               segments.
%
% Remarks: Masks are returned as output and saved in the EEG_artifact_masks 
%          folder. This function generates the masks using the EyeBallGUI 
%          or EEG Lab. The purpose of saving them is so they can easily be 
%          reused in the MWF analysis scripts without having to remark the 
%          artifacts for every EEG dataset.
% Used toolboxes:
%                   EEGLab     : https://sccn.ucsd.edu/eeglab/
%                   EyeBallGUI : http://eyeballgui.sourceforge.net
%
% Owner of Code : KU Leuven
% Developer of Code : Ben Somers 
% Contact Persons : Ben Somers (ben.somers1@kuleuven.be)

function [mask] = get_artifact_mask(name, artifact, redo, mode)

if (nargin <3)
    redo = 0; %default: load existing mask
end
if (nargin < 4)
    mode = 1; % default: EEGLAB
end

if (isa(name,'double'))
    name = get_name(name);
end

maskpath = ['EEG_artifact_masks' filesep name '_' artifact '_mask.mat'];

if (~exist(maskpath, 'file') || redo)
    [FileEEGdata, FileEEGsrate, ~] = get_data(name, artifact);
    if (~mode) % Use EyeBallGUI
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
        mask = isnan(EEGmask);
        mask = sum(mask,1);
        mask(mask>0) = 1;
        
        cleanup_EyeBallGUI;
    else % Use EEGLAB
        eegplot(FileEEGdata, 'srate', FileEEGsrate, 'winlength', 10, ...
            'tag', 'eegplot_marks', 'command', 'get_mask_eeglab', 'butlabel', 'SAVE MARKS');
        h = findobj(0, 'tag', 'eegplot_marks');
        [FIGexist, TMPREJexist] = updateEegplotStatus(h);
        if TMPREJexist % clear global variable for safety
            evalin('caller',['clear ', 'TMPREJ'])
        end
        
        % Wait for variable to be created in base workspace by EEGLAB after marking
        while(~TMPREJexist && FIGexist)
            [FIGexist, TMPREJexist] = updateEegplotStatus(h);
            if(~FIGexist && ~TMPREJexist) % eegplot closed without mask
                warning('Selection of artifact segments aborted by user. No new mask will be saved.')
                mask = [];
                return
            elseif(~FIGexist && TMPREJexist) % eegplot closed by clicking save mask
                break
            elseif(FIGexist && TMPREJexist) % mask exists while figure open, impossible
                error('Error clearing eegplot global variable TMPREJ')
            else % figure open & no mask yet
                pause(1);
                continue
            end
        end
        markings = evalin('base','TMPREJ');
        evalin('caller',['clear ', 'TMPREJ']) %clear global
        
        %build mask from markings
        mask = zeros(1,size(FileEEGdata,2));
        for i = 1:size(markings,1)
            mask(:,floor(markings(i,1)):ceil(markings(i,2))) = 1;
        end        
    end
    save(maskpath, 'mask');
else % mask already exists
    S = load(maskpath);
    mask = S.mask;
end

end

function [FIGexist, TMPREJexist] = updateEegplotStatus(h)
% return if eegplot still exist & if marking global variable exists
% INPUT: eegplot function handle
    W = evalin('base','whos');
    TMPREJexist = any(strcmp('TMPREJ',{W(:).name}));
    FIGexist = ishghandle(h);
end

function get_mask_eeglab() %#ok<DEFNU>
% Dummy function for eegplot button callback
    disp('Generating the mask from EEGLAB markings...');
end
