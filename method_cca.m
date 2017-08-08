function [v, d, t] = method_cca(y, Fs, name, artifact)
tic
[CCAcomps, W, V] = cca(y, 1);
t = toc;

% visualise components, ask for input
if nargin > 2
    Idx = cached_ICA_components(name, artifact);
else
    eegplot(CCAcomps,'srate',Fs,'winlength',20,'dispchans',10);
    Idx = input('\n Enter artefact components: ');
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

function Idx = cached_ICA_components(name, artifact)
switch artifact
    case 'eyeblink'
        subjcomps = {
            1:4, ...
            1, ...
            1, ...
            1, ...
            1:3, ...
            1, ...
            1, ...
            1:2, ...
            1, ...
            1
        };
    case 'muscle'
end
Idx = subjcomps{name};

end


