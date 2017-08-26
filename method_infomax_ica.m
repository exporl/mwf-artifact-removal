function [n, d, t] = method_infomax_ica(y, Fs, cache)
rng(0);
tic
[weigth, sphere] = runica(y, 'steps', 256);

% unmixing matrix, project to component space
W = weigth * sphere; 
ICAcomps = W * y;
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
V = inv(W);
V_art = V(:,Idx);
ARTcomps = ICAcomps(Idx,:);
d = V_art*ARTcomps;
n = y - d;
t = t + toc;
end
