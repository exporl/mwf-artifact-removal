function [v, d, t] = method_infomax_ica(y, Fs, name, artifact)
tic
[weigth, sphere] = runica(y, 'steps', 256);

% unmixing matrix, project to component space
W = weigth * sphere; 
ICAcomps = W * y;
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
V = inv(W);
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
            1:3, ...
            1, ...
            1:3, ...
            1:2, ...
            1, ...
            1:2, ...
            1:2, ...
            1:3, ...
            1:3, ...
            [1, 3]
        };
    case 'muscle'
end
Idx = subjcomps{name};

end


