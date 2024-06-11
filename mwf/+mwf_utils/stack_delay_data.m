% Stack delayed versions of the input (multi-channel) data together.
% Zero-padding is applied to the delayed signals to ensure that samples per
% channel of the output data y_s remains the same as the input data y.
%
% INPUTS:
%   y               raw EEG data (channels x samples)
%   delay           number of additional time delays to include
%   singlesided     [default 0] use single sided or double sided delays
%                   if 1, use only positive time delays up to 'delay'
%                   if 0, use positive and negative time delays up to 'delay'
%   delay_spacing   [default 1] spacing between delay samples (samples) 
%                   if N, then every N'th sample will be used for the delays. (N should be an integer larger than 0).
%
%   ALTERNATIVELY   the second argument can be a struct with MWF parameters specifying delays to use. 
%                   In this case, the structs fields "delay", "delay_spacing" and "singlesided" will be used (if present).
%
% OUTPUTS: 
%   y_s     raw EEG data, included delayed versions (channels x samples)
%   M_s     number of channels in y_s
%
%% USAGE: 
%   y_s = mwf_utils.stack_delay_data(y, 3, 0, 3)
%       is equivalent to
%   p = mwf_params('delay', 3, 'delay_spacing', 3, 'singlesided', false)
%   y_s = mwf_utils.stack_delay_data(y, p)
%
%% EXAMPLEs:
%   paramters:      delay = 3   
%   delays used:    [-3 -2 -1 0 1 2 3]
%
%   paramters:      delay = 3, singlesided = 1
%   delays used:    [0 1 2 3]  
%
%   paramters:      delay = 3, singlesided = 0, delay_spacing = 3
%   delays used:    [-9 -6 -3 0 3 6 9]
%
%   paramters:      delay = 3, singlesided = 1, delay_spacing = 3
%   delays used:    [0 3 6 9]
%
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be
%
% 2024: Neil Bailey added delay_spacing option for MWF Toolbox


function [y_s, M_s] = stack_delay_data(y, delay, singlesided, delay_spacing)

% If second argument is struct (according to mwf_params), convert to correct values
if isstruct(delay)
    p_struct = delay;
    if nargin > 2
        error('Function stack_delay_data input parameters are ambiguously specified. Either provide a struct as second parameter, or provide numeric parameters.')
    end
    delay = p_struct.delay;
    if isfield(p_struct, 'delay_spacing')
        delay_spacing = p_struct.delay_spacing;
    end
    if isfield(p_struct, 'singlesided')
        singlesided = p_struct.singlesided;
    end
else
    % Set default values for singlesided and delay_spacing if not specified
    if nargin < 3 || isempty(singlesided)
        singlesided = false;
    end
    if nargin < 4 || isempty(delay_spacing)
        delay_spacing = 1;
    end
end

M = size(y,1);

if singlesided
    M_s = (delay + 1) * M;
    y_s = zeros(M_s, size(y,2));
    for tau = 0:delay
        y_shift = circshift(y, [0, tau*delay_spacing]);
        y_shift(:, [1:tau*delay_spacing, end+tau*delay_spacing+1:end]) = 0;
        y_s(tau*M+1 : M*(tau+1) , :) = y_shift;   
    end
else
    M_s = (2 * delay + 1) * M;
    y_s = zeros(M_s, size(y,2));
    for tau = -delay:delay
        y_shift = circshift(y, [0, tau*delay_spacing]);
        y_shift(:, [1:tau*delay_spacing, end+tau*delay_spacing+1:end]) = 0;
        y_s((tau+delay)*M+1 : M*(tau+delay+1) , :) = y_shift;
    end
end

end