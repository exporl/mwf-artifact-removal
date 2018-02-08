
clear

chans = [32:32:256];
Nchans = numel(chans);
Nsubj = 10;
timeMWF = zeros(Nsubj, Nchans);

artifact = 'muscle';
params = mwf_params('delay', 5, 'rank', 'poseig');
for c = 1:Nchans
    for s = 1:Nsubj
        [y, ~, ~]   = get_artifact_data(s, artifact);
        if chans(c) > size(y,1)
            y = [y; rand(chans(c)-size(y,1),size(y,2))];
        end
        y = y(1:chans(c),:);
        mask        = get_artifact_mask(s, artifact);
        tic
        [W]         = mwf_compute(y, mask, params);
        [n, ~]      = mwf_apply(y, W);
        timeMWF(s, c) = toc;
    end
end

fig = figure;
boxplot(timeMWF, chans)
xlabel('number of EEG channels [-]')
ylabel('computation time [s]')
title('MWF computation time in function of EEG channels')
settings = mwfgui_localsettings;
pf_printpdf(fig, fullfile(settings.figurepath,'nchannels_MWF'), 'eps')
close(fig)

%% infomax ICA

clear
rng('default')

artifact = 'muscle';
methods = {'ICA-infomax'};
Nsubj = 5;
chans = [64:32:256];
Nchans = numel(chans);
cache = struct;
cache.snr = 'real';

timeICA = zeros(Nsubj, Nchans);

cache.method = 'infomax';
cache.artifact = artifact;
for c = 1:Nchans
    for s = 1:Nsubj
        cache.name = get_name_from_id(s);
        [y, Fs] = get_artifact_data(s, artifact);
        if chans(c) > size(y,1)
            y = [y; rand(chans(c)-size(y,1),size(y,2))];
        end
        y = y(1:chans(c),:);
        mask = get_artifact_mask(s, artifact);
        [~,~,timeICA(s,c)] = method_infomax_ica(y, Fs, cache);
        rng('default')
    end
end

fig = figure;
boxplot(timeICA, chans)
xlabel('number of EEG channels [-]')
ylabel('computation time [s]')
title('ICA computation time in function of EEG channels')
settings = mwfgui_localsettings;
pf_printpdf(fig, fullfile(settings.figurepath,'nchannels_ICA'), 'eps')
close(fig)