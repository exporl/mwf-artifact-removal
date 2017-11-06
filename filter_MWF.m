% Apply the full MWF chain to the input EEG data.
%
% INPUTS:
%   y           raw EEG data (channels x samples)
%   fs          precomputed multi-channel Wiener filter
%   delay       maximum time delay to include (samples)
%   cacheID     specifier to identify cached mask
%   cachepath   path to cache folder where masks can be saved
%   redo        flag:   if 1, a new mask will always be generated
%                       if 0, a new mask is generated only if no cache is present
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
% Only the first two inputs are required, the rest is optional.
%
% Using delay is beneficial to MWF performance, but increases computation
% time. Set the 'delay' input to a positive integer for improved performance.
%
% For caching options (cacheID, cachepath and redo), see filter_getmask.m
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [n, d, W, SER, ARR, p] = filter_MWF(y, fs, delay, cacheID, cachepath, redo)

if nargin < 3
    delay = 0;
end
if nargin < 4
    cacheID = '';
end
if nargin < 5
    cachepath = '';
end
if nargin < 5
    redo = '0';
end

p           = filter_params(...
                'srate', fs, ...
                'rank', 'poseig', ...
                'delay', delay);
mask        = filter_getmask(y, fs, cacheID, cachepath, redo);
W           = filter_compute(y, mask, p);
[n, d]      = filter_apply(y, W);
[SER, ARR]  = filter_performance(y, d, mask);

end