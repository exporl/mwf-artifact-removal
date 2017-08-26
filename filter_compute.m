% Compute a Multi-channel Wiener Filter (MWF) based on a Generalized 
% Eigenvalue Decompostion (GEVD) for EEG artifact removal. 
%
% The filter W is computed for a given multi-channel input data y, the 
% corresponding artifact mask, and the chosen processing settings in p.
%
% The filter size depends on the number of delays in the parameter struct p

function [W, Lambda] = filter_compute(y, mask, p)

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

% Calculate the covariance matrices Ryy and Rnn
Ryy = cov(y(:,mask == 1).');
Rnn = cov(y(:,mask == 0).');  % Rvv only uses clean data

% GEVD-based MWF
[V, Lambda] = eig(Ryy, Rnn);
[V, Lambda] = sort_evd(V, Lambda);
Delta = Lambda - eye(M_s);

% set filter rank
switch p.rank
    case 'full'
        rank_w = M_s; % equivalent to normal MWF
        fprintf(' Keeping all eigenvalues... Rank = %d\n', rank_w)
    case 'poseig'
        rank_w = M_s - sum(diag(Delta)<0); % equivalent to normal MWF, but keep only positive EVs
        fprintf(' Rejecting %d negative eigenvalues (total: %d)... Rank = %d\n',sum(diag(Delta)<0),M_s,rank_w)
    case 'pct' % retain first x% of eigenvalues
        rank_w = ceil(p.rankopt*M_s/100);
        fprintf(' Keeping largest %d%% of %d eigenvalues... Rank = %d\n',p.rankopt,M_s,rank_w)
    case 'first' % retain first x eigenvalues
        rank_w = p.rankopt;
        fprintf(' Keeping largest %d of %d eigenvalues... Rank = %d\n',p.rankopt,M_s,rank_w)
    otherwise
        error('unknown rank specifier in filter parameter struct')
end

% Create filter of rank rank_w
Delta(rank_w * (M_s + 1) + 1 : M_s + 1 : M_s * M_s) = 0; % set rank+1:end to 0
W = V / (Lambda+(p.mu-1)*eye(M_s)) * Delta / V;

% Check assumption that X.' * Rvv * X is (close to) identity matrix
if max(abs(diag(V.' * Rnn * V - eye(M_s))) > 10e-3) 
    error('Scaling error: assumption of scaling of generalized eigenvectors is not valid')
end

end
