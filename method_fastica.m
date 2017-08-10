function [v, d, t] = method_fastica(y, Fs, cache)
rng(0);
tic
[ICAcomps, V, ~] = fastica(y, 'maxNumIterations', 250);
t = toc;

% check if cached components exist, otherwise ask them from user
Idx = method_cached_components(cache);
if isempty(Idx);
    eegplot(ICAcomps,'srate',Fs,'winlength',20,'dispchans',10,'spacing',20);
    Idx = input('\n Enter artifact components: ');
    method_cached_components(cache, Idx); % save entered components to cache
    close(gcf);
end

% mixing matrix, project back to sensor space
tic
V_art = V(:,Idx);
ARTcomps = ICAcomps(Idx,:);
d = V_art*ARTcomps;
v = y-d;
t = t+toc;
end


