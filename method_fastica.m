function [v, d, t] = method_fastica(y, Fs, name, artifact)
tic
rng(0);
[ICAcomps, V, W] = fastica(y, 'maxNumIterations', 250);
t = toc;

% visualise components, ask for input
if nargin > 2
    Idx = cached_ICA_components(name, artifact);
else
    eegplot(ICAcomps,'srate',Fs,'winlength',20,'dispchans',10);
    Idx = input('\n Enter artefact components: ');
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

function Idx = cached_ICA_components(name, artifact)
switch artifact
    case 'eyeblink'
        subjcomps = {
            13, ...
            8, ...
            [3, 5], ...
            [5, 6, 12], ...
            5, ...
            [14, 16], ...
            [2, 6], ...
            [19,22], ...
            [2, 4, 5], ...
            [7, 9]
        };
    case 'muscle'
end
Idx = subjcomps{name};

end


