% Compute a Multi-channel Wiener Filter (MWF) based on a Generalized 
% Eigenvalue Decompostion (GEVD) for EEG artifact removal. 
%
% The filter w is computed for a given multi-channel input data y, the 
% corresponding artifact mask m, and the chosen processing settings in p.
%
% The filter size depends on the number of delays in the parameter struct p

function w = filter_compute(y, mask, p)

if (nargin < 3);
    p = filter_params; % default
end

% Split data for training/validation if train_len is set
if p.train_len > 0
    train_samples = p.train_len * p.srate;
    y = y(:,1:train_samples);
    mask = mask(:,1:train_samples);
end

% Introduce time lags
[y, M_s] = stack_delay_data(y, p.delay);

% Calculate the covariance matrices Ryy and Rvv
Ryy = cov(y.');
Rvv = cov(y(:,mask == 0).');  % Rvv only uses clean data

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
w = X / (GEVL+(p.mu-1)*eye(M_s)) * delta / X;

% Check assumption that X.' * Rvv * X is (close to) identity matrix
if max(abs(diag(X.' * Rvv * X - eye(M_s))) > 10e-10) 
    error('Scaling error: assumption of scaling of generalized eigenvectors is not valid')
end

end
