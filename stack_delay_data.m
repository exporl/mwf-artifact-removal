% Construct stacked multichannel signal y_s consisting of multiple
% time-delayed versions of input y.

function [y_s, M_s] = stack_delay_data(y, delay, singlesided)

if nargin < 3
    singlesided = false;
end

M = size(y,1);

if singlesided
    M_s = (delay + 1) * M;
    y_s = zeros(M_s, size(y,2));
    for tau = 0:delay;
        y_shift = circshift(y, [0, tau]);
        y_shift(:, [1:tau, end+tau+1:end]) = 0;
        y_s(tau*M+1 : M*(tau+1) , :) = y_shift;   
    end
else
    M_s = (2 * delay + 1) * M;
    y_s = zeros(M_s, size(y,2));
    for tau = -delay:delay;
        y_shift = circshift(y, [0, tau]);
        y_shift(:, [1:tau, end+tau+1:end]) = 0;
        y_s((tau+delay)*M+1 : M*(tau+delay+1) , :) = y_shift;
    end
end

end