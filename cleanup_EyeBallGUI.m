% Remove generated backup and initialization files created by EyeBallGUI 
% in the current working directory.

function cleanup_EyeBallGUI

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
