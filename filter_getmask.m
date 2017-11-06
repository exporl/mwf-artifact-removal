% Create an artifact mask for the input EEG data.
% 
% If an ID corresponding to a mask in the cache is provided, the cached 
% mask will be loaded instead. If an ID is given and the "redo" flag is
% set, the saved mask in the cache will be overwritten.
%
% The cache directory to read/write is set by mwfgui_localsettings.m
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   fs      EEG data sample rate
%   redo    flag:   if 1, a new mask will always be generated
%                   if 0, a new mask is generated only if no cache is present
%   mode    GUI/toolbox to use for artifact marking
%               0: EEGLAB (eegplot)
%               1: EyeBallGUI
%
% OUTPUTS: 
%   mask    markings of artifacts in y (1 x samples)
%           The mask contains 1's in marked artifact segments and 0's elsewhere.
%
% Toolbox references:
%   EEGLab: https://sccn.ucsd.edu/eeglab/
%   EyeBallGUI: http://eyeballgui.sourceforge.net
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [mask] = filter_getmask(y, fs, redo, mode)

if (nargin <3)
    redo = 0; % default: attempt to load existing mask from cache
end
if (nargin < 4)
    mode = 1; % default: EEGLAB
end

settings = mwfgui_localsettings;
maskpath = fullfile(settings.savemaskpath,[name '_' artifact '_mask.mat']);

if (~exist(maskpath, 'file') || redo)
    if (~mode) % Use EEGlab
        eegplot(y, 'srate', fs, 'winlength', 10, ...
            'tag', 'eegplot_marks', 'command', 'get_mask_eeglab', 'butlabel', 'SAVE MARKS');
        h = findobj(0, 'tag', 'eegplot_marks');
        [FIGexist, TMPREJexist] = updateEegplotStatus(h);
        if TMPREJexist % clear global variable for safety
            evalin('base',['clear ', 'TMPREJ'])
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
        evalin('base',['clear ', 'TMPREJ']) %clear global
        
        %build mask from markings
        mask = zeros(1,size(y,2));
        for i = 1:size(markings,1)
            mask(:,floor(markings(i,1)):ceil(markings(i,2))) = 1;
        end        
    else % use EyeBallGUI
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

function cleanup_EyeBallGUI
% Remove generated backup and initialization files created by EyeBallGUI 
% in the current working directory.
if exist('EyeBallGUI_BackUp','dir')
    rmdir('EyeBallGUI_BackUp','s')
end

if exist('EyeBallGUIini.mat','file')
    delete('EyeBallGUIini.mat')
end

if exist('TRAINING_DATA.mat','file')
    delete('TRAINING_DATA.mat');
end

if exist('TRAINING_DATABad.mat','file')
    delete('TRAINING_DATABad.mat');
end
end
