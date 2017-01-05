% Construct stacked multichannel signal y_s consisting of multiple
% time-delayed versions of input y.

function [y_s, M_s] = stack_delay_data(y, delay)

M = size(y,1);
M_s = (2 * delay + 1) * M;
y_s = zeros(M_s, size(y,2));

for tau = -delay:delay;
    y_shift = circshift(y, [0, tau]);
    y_shift(:, [1:tau, end+tau+1:end]) = 0;
    y_s((tau+delay)*M+1 : M*(tau+delay+1) , :) = y_shift;
end

end