% Compute a Multi-channel Wiener Filter (MWF) based on a Generalized 
% Eigenvalue Decompostion (GEVD) for EEG artifact removal. The filter is
% trained on the raw EEG data y using the provided artifact mask. The
% struct p contains additional filter settings.
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   mask    markings of artifacts in y (1 x samples)
%   p       [optional] MWF parameter struct (see mwf.params)
%
% OUTPUTS: 
%   W       multi-channel Wiener filter (size depends on number of delays)
%   Lambda  diagonal matrix with genalized eigenvalues on main diagonal
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [W, Lambda] = compute(y, mask, p)

if (nargin < 3); % use default settings
    p = mwf.params;
end

if p.train_len > 0 % if needed, split data in distinct training & testing sets
    train_samples = p.train_len * p.srate;
    y = y(:,1:train_samples);
    mask = mask(:,1:train_samples);
end

% Include time lagged versions of y
[y, M_s] = mwf.util.stack_delay_data(y, p.delay);

% Calculate the covariance matrices Ryy and Rnn
Ryy = cov(y(:,mask == 1).');
Rnn = cov(y(:,mask == 0).');

% Perform GEVD
[V, Lambda] = eig(Ryy, Rnn);
[V, Lambda] = mwf.util.sort_evd(V, Lambda);
Delta = Lambda - eye(M_s);

% Set filter rank depending on settings
switch p.rank
    case 'full'     % equivalent to regular (full-rank) MWF
        rank_w = M_s;
        fprintf(' Keeping all eigenvalues... Rank = %d\n', rank_w)
    case 'poseig'   % only retain positive eigenvalues in rank approximation
        rank_w = M_s - sum(diag(Delta)<0); 
        fprintf(' Rejecting %d negative eigenvalues (total: %d)... Rank = %d\n',sum(diag(Delta)<0),M_s,rank_w)
    case 'pct'      % retain only first x% of eigenvalues
        rank_w = ceil(p.rankopt*M_s/100);
        fprintf(' Keeping largest %d%% of %d eigenvalues... Rank = %d\n',p.rankopt,M_s,rank_w)
    case 'first'    % retain only first x eigenvalues
        rank_w = p.rankopt;
        fprintf(' Keeping largest %d of %d eigenvalues... Rank = %d\n',p.rankopt,M_s,rank_w)
    otherwise
        error('unknown rank specifier in filter parameter struct')
end

% Create filter of rank specified above
Delta(rank_w * (M_s + 1) + 1 : M_s + 1 : M_s * M_s) = 0;
W = V / (Lambda+(p.mu-1)*eye(M_s)) * Delta / V;

% Check assumption that X.' * Rvv * X is (close to) identity matrix
if max(abs(diag(V.' * Rnn * V - eye(M_s))) > 10e-3) 
    error('Scaling error: assumption of scaling of generalized eigenvectors is not valid')
end

end
