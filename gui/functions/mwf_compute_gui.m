% Compute a Multi-channel Wiener Filter (MWF) based on a Generalized 
% Eigenvalue Decompostion (GEVD) for EEG artifact removal. The filter is
% trained on the raw EEG data y using the provided artifact mask. The
% struct p contains additional filter settings.
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   mask    markings of artifacts in y (1 x samples)
%   p       [optional] MWF parameter struct (see mwf_params)
%
% OUTPUTS: 
%   W       multi-channel Wiener filter (size depends on number of delays)
%   Lambda  diagonal matrix with genalized eigenvalues on main diagonal
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [W, Lambda] = mwf_compute(y, mask, p)

mwf_utils.check_dimensions(size(y));

if (nargin < 3) % use default settings
    p = mwf_params;
end

switch p.treatnans
    case 'ignore'
        % ignore NaNs in mask
    case 'artifact'
        mask(isnan(mask)) = 1; % treat NaNs in mask as artifact
    case 'clean'
        mask(isnan(mask)) = 0; % treat NaNs in mask as clean data
end

% Include time lagged versions of y
[y, M_s] = mwf_utils.stack_delay_data(y, p.delay);

% Calculate the covariance matrices Ryy and Rnn
Ryy = cov(y(:,mask == 1).');
Rnn = cov(y(:,mask == 0).');
clear y;

Ryy = mwf_utils.ensure_symmetry(Ryy);
Rnn = mwf_utils.ensure_symmetry(Rnn);

% Perform GEVD
[V, Lambda] = eig(Ryy, Rnn);
[V, Lambda] = mwf_utils.sort_evd(V, Lambda);
Lambda_y = V' * Ryy * V;
Lambda_n = V' * Rnn * V;
Delta = Lambda_y - Lambda_n;

% Eigenvectors V are assumed to be scaled such that Lambda_n is (approx.) identity
diffs = abs(Lambda_n - eye(M_s));
if any(diffs(:) > 1e-2)
    warning([...
        'Generalized eigenvectors are not scaled as assumed: results may be inacurrate. \n' ...
        'This is likely caused by (almost) rank deficient covariance matrices. \n' ...
        'Make sure that the EEG has full rank and that the mask provides enough' ...
        'clean/artifact EEG samples for covariance matrix estimation.'],[])
end

% Set filter rank depending on settings
switch p.rank
    case 'full'     % equivalent to regular (full-rank) MWF
        rank_w = M_s;
        msg = sprintf(' Keeping all eigenvalues... Rank = %d\n', rank_w);
    case 'poseig'   % only retain positive eigenvalues in rank approximation
        rank_w = M_s - sum(diag(Delta)<0); 
        msg = sprintf(' Rejecting %d negative eigenvalues (total: %d)... Rank = %d\n',sum(diag(Delta)<0),M_s,rank_w);
    case 'pct'      % retain only first x% of eigenvalues
        rank_w = ceil(p.rankopt*M_s/100);
        msg = sprintf(' Keeping largest %d%% of %d eigenvalues... Rank = %d\n',p.rankopt,M_s,rank_w);
    case 'first'    % retain only first x eigenvalues
        rank_w = p.rankopt;
        msg = sprintf(' Keeping largest %d of %d eigenvalues... Rank = %d\n',p.rankopt,M_s,rank_w);
    otherwise
        error('unknown rank specifier in filter parameter struct')
end

% display MWF info in command window
if p.verbose
    fprintf(msg)
end

% Create filter of rank specified above
Delta(rank_w * (M_s + 1) + 1 : M_s + 1 : M_s * M_s) = 0;
%Set last warning empty
warning("");
W = V / (Lambda+(p.mu-1)*eye(M_s)) * Delta / V;
w = lastwarn;
if(contains(w,'Matrix is close to singular or badly scaled'))
    waitfor(msgbox('Warning: Ill-conditioned filter: better and/or more artifact annotation is recommended','Warning','warn'));
end
