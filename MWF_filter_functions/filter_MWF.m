% Apply the full MWF chain to the input EEG data.
%
% INPUTS:
%   y           raw EEG data (channels x samples)
%   mask        markings of artifacts in y (1 x samples)
%   delay       maximum time delay to include (samples) DEFAULT: 0 samples
%
% OUTPUTS: 
%   n       filtered EEG data (channels x samples)
%   d       estimated artifacts in every channel (channels x samples)
%   W       MWF matrix used to estimate artifacts
%   SER     Signal to Error Ratio, measures clean EEG distortion
%   ARR     Artifact to Residue Ratio, measures artifact estimation
%   p       MWF parameter struct (see filter_params.m)
%
% USAGE
% Only the first two inputs are required, if delay is omitted the default
% value 0 will be used. Including delays is beneficial to MWF performance, 
% but increases computation time. Set the 'delay' input to a positive 
% integer for improved performance.
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [n, d, W, SER, ARR, p] = filter_MWF(y, mask, delay)

if nargin < 3
    delay = 0;
end

p           = filter_params(...
                'rank', 'poseig', ...
                'delay', delay);
W           = filter_compute(y, mask, p);
[n, d]      = filter_apply(y, W);
[SER, ARR]  = filter_performance(y, d, mask);

end