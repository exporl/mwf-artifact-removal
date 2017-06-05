% Apply a pre-computed Multi-channel Wiener Filter on a multi-channel EEG
% signal y. The outputs are artifact estimate d and filtered signal v.
%
% If time delays y were incorporated in the computation of filter w, there
% will be a size mismatch between y and w. Before the filter can be
% applied, delays have to be introduced again in the channels of y.

function [v, d] = filter_apply(y, w)

M = size(y,1);
M_s = size(w,1);

tau = (M_s - M) / M;
if mod(tau,1) ~= 0
    error('the given filter is not compatible with the input EEG signal')
end

% re-introduce time lags
[y_s, ~] = stack_delay_data(y, tau);

% compute artifact estimate for original channels of y
orig_chans = 1:M;
d = w(:, orig_chans).' * y_s;

% subtract artifact estimate from data
v = y - d;

end
