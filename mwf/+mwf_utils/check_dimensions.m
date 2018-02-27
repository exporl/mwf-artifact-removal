% Check the whether the dimensions of the EEG signal agree with the
% expected format, i.e. a 2D matrix in channels x samples format. If a 
% mismatch is detected, an error is thrown.
%
% INPUTS:
%   EEGsize     size vector of the EEG, obtained by size(EEG)
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function check_dimensions(EEGsize)

if numel(EEGsize) ~= 2
    error(['Error: expected EEG to be 2D matrix in format: channels x samples. ' ...
    'The input EEG has %s dimensions.'], num2str(numel(EEGsize)));
end

if EEGsize(1) > EEGsize(2)
    error(['Error: expected EEG to be 2D matrix in format: channels x samples. ' ...
    'The input number of channels (%i) is greater than the input number of time samples (%i). ' ...
    '\nShould your EEG matrix be transposed?'], ...
    EEGsize(1), EEGsize(2));
end

end
