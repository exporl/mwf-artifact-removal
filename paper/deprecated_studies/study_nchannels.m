
clear

chans = [32:32:256];
Nchans = numel(chans);
Nsubj = 10;
time = zeros(Nsubj, Nchans);

artifact = 'muscle';
params = mwf.params('delay', 5, 'rank', 'poseig');
for c = 1:Nchans
    for s = 1:Nsubj
        [y, ~, ~]   = get_artifact_data(s, artifact);
        if chans(c) > size(y,1)
            y = [y; rand(chans(c)-size(y,1),size(y,2))];
        end
        y = y(1:chans(c),:);
        mask        = get_artifact_mask(s, artifact);
        tic
        [W]         = mwf.compute(y, mask, params);
        [n, ~]      = mwf.apply(y, W);
        time(s, c) = toc;
    end
end

fig = figure;
boxplot(time, chans)
xlabel('number of EEG channels [-]')
ylabel('computation time [s]')
title('computation time in function of EEG channels')
settings = mwfgui_localsettings;
pf_printpdf(fig, fullfile(settings.figurepath,'nchannels'), 'eps')
close(fig)
