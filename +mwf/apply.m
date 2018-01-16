% Apply a pre-computed Multi-channel Wiener Filter W on a multi-channel EEG
% signal y, producing artifact estimate d and filtered signal n.
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   W       precomputed multi-channel Wiener filter
%
% OUTPUTS: 
%   n       filtered EEG data (channels x samples)
%   d       estimated artifacts in every channel (channels x samples)
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [n, d] = apply(y, W)

M = size(y, 1);
M_s = size(W, 1);

tau = (M_s - M) / (2 * M);
if mod(tau, 1) ~= 0
    error('the given filter is not compatible with the input EEG signal')
end

% re-apply time lags to y to apply filter W
[y_s, ~] = mwf.util.stack_delay_data(y, tau);

% compute artifact estimate for original channels of y
orig_chans = tau * M+1 : (tau+1) * M;
d = W(:, orig_chans).' * y_s;

% subtract artifact estimate from data
n = y - d;

end
