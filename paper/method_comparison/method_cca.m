% Perform Canonical Correlation Analysis for artifact removal.
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   Fs      EEG data sample rate
%   Nlags   number of CCA time lags to use
%   cache   data identifier struct to retrieve cached components
%
% OUTPUTS: 
%   n       filtered EEG data (channels x samples)
%   d       estimated artifacts in every channel (channels x samples)
%   t       computation time (seconds)
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [n, d, t] = method_cca(y, Fs, Nlags, cache)
tic
[CCAcomps, ~, V] = cca(y, Nlags);
t = toc;

% check if cached components exist, otherwise ask them from user
Idx = method_cached_components(cache);
if isempty(Idx);
    eegplot(CCAcomps,'srate',Fs,'winlength',20,'dispchans',10,'spacing',20);
    Idx = input('\n Enter artifact components: ');
    method_cached_components(cache, Idx); % save entered components to cache
    close(gcf);
end

% mixing matrix, project back to sensor space
tic
V_art = V(:,Idx);
ARTcomps = CCAcomps(Idx,:);
d = V_art*ARTcomps;
n = y - d;
t = t + toc;
end

function [CCAcomps, W, V] = cca(y, Nlags)
% Create a time-delayed version of x with time delay tau
yt = mwf_utils.stack_delay_data(y, Nlags, true);
yt(1:size(y,1),:) = [];

% Calculate the CCA components of sets X and Y
[W, ~, ~] = canoncorr(y',yt');

% Demix EEG into CCA components
CCAcomps = W'*y;
V = inv(W');

end

