% Apply the full MWF chain to the input EEG data.
%
% INPUTS:
%   y           raw EEG data (channels x samples)
%   mask        markings of artifacts in y (1 x samples)
%   p           [optional] MWF parameter struct (see mwf_params)
%
% OUTPUTS: 
%   n       filtered EEG data (channels x samples)
%   d       estimated artifacts in every channel (channels x samples)
%   W       MWF matrix used to estimate artifacts
%   SER     Signal to Error Ratio, measures clean EEG distortion
%   ARR     Artifact to Residue Ratio, measures artifact estimation
%   p       MWF parameter struct (see mwf_params)
%
% USAGE
% Only the first two inputs are required, if p is omitted the default
% parameters (with delay 0) will be used. Including delays is beneficial to 
% MWF performance, but increases computation time. 
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [n, d, W, SER, ARR, p] = mwf_process(y, mask, p)

mwf_utils.check_dimensions(size(y));

if nargin < 3
    p = mwf_params;
end
if ~isstruct(p) % For backward compatibility
    % Third parameter "p" used to be an integer delay value
    p = mwf_params('delay', p);
end

W           = mwf_compute(y, mask, p);
[n, d]      = mwf_apply(y, W, p);
[SER, ARR]  = mwf_performance(y, d, mask);

end