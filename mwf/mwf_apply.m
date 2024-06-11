% Apply a pre-computed Multi-channel Wiener Filter W on a multi-channel EEG
% signal y, producing artifact estimate d and filtered signal n.
%
% This function works for input EEG with a DC component. As the MWF is 
% computed on zero-meaned data, it should be applied on zero-meaned
% data as well. Therefore, the mean of the EEG data is subtracted first
% and added after MWF application. 
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   W       precomputed multi-channel Wiener filter
%   p       [optional] MWF parameter struct (see mwf_params)
%
% OUTPUTS: 
%   n       filtered EEG data (channels x samples)
%   d       estimated artifacts in every channel (channels x samples)
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [n, d] = mwf_apply(y, W, p)

% input checking
[M, T] = size(y);
mwf_utils.check_dimensions(size(y));

if nargin < 3     % For backward compatibility, assume default values and derive delay parameter from sizes of y and W
    warning('mwf_apply was changed to take a parameter struct (see mwf_params) as a third argument. The function will assume a parameter struct with default values for backward compatibility.')

    M_s = size(W, 1);
    tau = (M_s - M) / (2 * M); % only true if singlesided = 0 (default)
    if mod(tau, 1) ~= 0
        error('the given filter is not compatible with the input EEG signal or parameters')
    end
    p = mwf_params;
    p.delay = tau;
end


% subtract mean from data
channelmeans = mean(y,2);
y = y - repmat(channelmeans, 1, T);

% re-apply time lags to y to apply filter W
[y_s, ~] = mwf_utils.stack_delay_data(y, p);

% compute artifact estimate for original channels of y
if ~p.singlesided
    orig_chans = p.delay * M+1 : (p.delay+1) * M;
else
    orig_chans = 1:M;
end
d = W(:, orig_chans).' * y_s;

% subtract artifact estimate from data
n = y - d;

% add mean back to filtered EEG
n = n + repmat(channelmeans, 1, T);

end
