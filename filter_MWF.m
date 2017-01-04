
% Multi-channel Wiener Filter (MWF) based on Generalized Eigenvalue
% Decompostion (GEVD) for EEG artifact removal.

function [v, d, w] = filter_MWF(y, mask, p)

if (nargin < 3);
    p = filter_params; % default
end

% Introduce time lags
M = size(y,1);
M_s = (2*p.delay+1)*M;
y_s = zeros(M_s,size(y,2));

for tau = -p.delay:p.delay;
    y_shift = circshift(y, [0, tau]);
    y_shift(:, [1:tau, end+tau+1:end]) = 0;
    y_s((tau+p.delay)*M+1 : M*(tau+p.delay+1) , :) = y_shift;
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
switch p.rank
    case 'full'
        rank_w = M_s; % equivalent to normal MWF 
    case 'poseig'
        rank_w = M_s - sum(diag(delta)<0); % equivalent to normal MWF, but keep only positive EVs
    otherwise
        error('unknown rank specifier in filter parameter struct')
end

% Create filter of rank rank_w
delta(rank_w * (M_s + 1) + 1 : M_s + 1 : M_s * M_s) = 0; % set rank+1:end to 0
w = X / GEVL * delta / X;

% Check assumption that X.' * Rvv * X is (close to) identity matrix
if max(abs(diag(X.' * Rvv * X - eye(M_s))) > 10e-10) 
    error('Scaling error: assumption of scaling of generalized eigenvectors is not valid')
end

% compute artifact estimate for original channels of y
orig_chans = (p.delay) * M+1 : (p.delay+1) * M;
d = w(:,orig_chans).' * y_s;

% subtract artifact estimate from data
v = y - d;

end