% Clean up backup en initialization files created by EyeBallGUI in the
% current working directory

if exist('EyeBallGUI_BackUp')
    rmdir('EyeBallGUI_BackUp','s')
end

if exist('EyeBallGUIini.mat')
    delete('EyeBallGUIini.mat')
end

if exist('TRAINING_DATA.mat')
    delete('TRAINING_DATA.mat');
end

if exist('TRAINING_DATABad.mat')
    delete('TRAINING_DATABad.mat');
end