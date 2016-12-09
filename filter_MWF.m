
% TODO comments info

function [v, d] = filter_MWF(y, mask)

% Set parameters
M = size(y,1);  % number of channels

% Calculate the covariance matrices Ryy and Rvv
Ryy = cov(y.');
Rvv = cov(y(:,mask == 0).');  % Rvv only uses clean data

% Calculate the filter to estimate artifacts

% normal MWF
w = eye(M) - Ryy \ Rvv;

% PE MWF == GEVD with threshold 0
[v,d] = eig(w);
[v,d] = sort_evd(v,d);
d(d<0) = 0;
w_pe = v*d/v;

% GEVD-based MWF
threshold = 0; %select largest eigenvalue to maintain threshold
[X, GEVL] = eig(Ryy,Rvv);
delta = GEVL - eye(M);
delta(delta<threshold) = 0;
w_gevd = X / GEVL * delta / X; 

% Check assumption that X.' * Rvv * X is (close to) identity matrix
if max(abs(diag(X.' * Rvv * X - eye(M))) > 10e-10) 
    error('Scaling error: assumption of scaling of generalized eigenvectors is not valid')
end

% subtract the eye blinks from training data
d = (w.') * y;
v = y - d;

end