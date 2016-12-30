
% Multi-channel Wiener Filter (MWF) based on Generalized Eigenvalue
% Decompostion (GEVD) for EEG artifact removal.

function [v, d] = filter_MWF(y, mask, delay)

if (nargin < 3);
    delay = 0;
end

% Introduce time lags
M = size(y,1);
M_s = (2*delay+1)*M;
y_s = zeros(M_s,size(y,2));

for tau = -delay:delay;
    y_shift = circshift(y, tau, 2);
    y_shift(:, [1:tau, end+tau+1:end]) = 0;
    y_s((tau+delay)*M+1 : M*(tau+delay+1) , :) = y_shift;
end

% Calculate the covariance matrices Ryy and Rvv
Ryy = cov(y_s.');
Rvv = cov(y_s(:,mask == 0).');  % Rvv only uses clean data

% normal MWF
% w = eye(M) - Ryy \ Rvv;

% GEVD-based MWF
[X, GEVL] = eig(Ryy,Rvv);
[X, GEVL] = sort_evd(X,GEVL);
delta = GEVL - eye(M_s);

% set filter rank
% rank_w = M_s;                      % equivalent to normal MWF
% rank_w = M_s - sum(diag(delta)<0); % equivalent to normal MWF, keep only positive EVs
rank_w = M_s;

% Create filter of rank rank_w
delta(rank_w * (M_s + 1) + 1 : M_s + 1 : M_s * M_s) = 0; % set rank+1:end to 0
w = X / GEVL * delta / X; 

% Check assumption that X.' * Rvv * X is (close to) identity matrix
if max(abs(diag(X.' * Rvv * X - eye(M_s))) > 10e-10) 
    error('Scaling error: assumption of scaling of generalized eigenvectors is not valid')
end

% subtract the eye blinks from training data
d_s = (w.') * y_s;
v_s = y_s - d_s;

d = d_s((delay)*M+1:M*(delay+1),:);
v = v_s((delay)*M+1:M*(delay+1),:);

end