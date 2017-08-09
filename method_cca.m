function [v, d, t] = method_cca(y, Fs, cache)
tic
[CCAcomps, ~, V] = cca(y, 1);
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
v = y-d;
t = t+toc;
end

function [CCAcomps, W, V] = cca(y, tau)
% Create a time-delayed version of x with time delay tau
yt = y(:,[ end-tau+1:end  1:end-tau ]);  % cyclic shift over tau to right 
yt(:, 1:tau) = 0;                        % remove first tau rows of y (delayed, not cyclic!)

% Calculate the CCA components of sets X and Y
[W, ~, ~] = canoncorr(y',yt');

% Demix EEG into CCA components
CCAcomps = W'*y;
V = inv(W');

end

