% Stack delayed versions of the input (multi-channel) data together.
% Zero-padding is applied to the delayed signals to ensure that samples per
% channel of the output data y_s remains the same as the input data y.
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   delay   maximum time delay to include
%   singlesided     [default 0] use single sided or double sided delays
%                   if 1, use only positive time delays up to 'delay'
%                   if 0, use positive and negative time delays up to 'delay'
%
% OUTPUTS: 
%   y_s     raw EEG data, included delayed versions (channels x samples)
%   M_s     number of channels in y_s
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [y_s, M_s] = stack_delay_data(y, delay, singlesided)

if nargin < 3
    singlesided = false;
end

M = size(y,1);

if singlesided
    M_s = (delay + 1) * M;
    y_s = zeros(M_s, size(y,2));
    for tau = 0:delay
        y_shift = circshift(y, [0, tau]);
        y_shift(:, [1:tau, end+tau+1:end]) = 0;
        y_s(tau*M+1 : M*(tau+1) , :) = y_shift;   
    end
else
    M_s = (2 * delay + 1) * M;
    y_s = zeros(M_s, size(y,2));
    for tau = -delay:delay
        y_shift = circshift(y, [0, tau]);
        y_shift(:, [1:tau, end+tau+1:end]) = 0;
        y_s((tau+delay)*M+1 : M*(tau+delay+1) , :) = y_shift;
    end
end

end