% Apply a pre-computed Multi-channel Wiener Filter W on a multi-channel EEG
% signal y. The outputs are artifact estimate d and filtered signal n.
%
% If time delays were incorporated in the computation of filter W, there
% will be a size mismatch between y and W. Before the filter can be
% applied, delays have to be introduced again in the channels of y.

function [n, d] = filter_apply(y, W)

M = size(y,1);
M_s = size(W,1);

tau = (M_s - M) / (2 * M);
if mod(tau,1) ~= 0
    error('the given filter is not compatible with the input EEG signal')
end

% re-introduce time lags
[y_s, ~] = stack_delay_data(y, tau);

% compute artifact estimate for original channels of y
orig_chans = tau * M+1 : (tau+1) * M;
d = W(:, orig_chans).' * y_s;

% subtract artifact estimate from data
n = y - d;

end
