% look at performance on synthetic data for varying SNR

clear

Nsubj = 10;
SNRs = -24:3:12;
Nsnrs = numel(SNRs);

SER = zeros(Nsubj, Nsnrs);
ARR = zeros(Nsubj, Nsnrs);
ARRre = zeros(Nsubj, Nsnrs);

% Loop over SNRs and subjects
params = mwf_params('delay', 10, 'rank', 'poseig');
for i = 1:Nsubj
    for j = 1:Nsnrs
    T   = EEG_data_synthetic(i, SNRs(j));
    [W]         = mwf_compute(T.eeg_data, T.mask, params);
    [~, d]      = mwf_apply(T.eeg_data, W);
    [SER(i,j), ARR(i,j)]  = mwf_performance(T.eeg_data, d, T.mask, T.artifact);
    [SER(i,j), ARRre(i,j)]  = mwf_performance(T.eeg_data, d, T.mask);
    end
end

figure
contributions.shadedErrorbar(SNRs,SER(:,:),{@mean,@std},'-b',1)
hold on
contributions.shadedErrorbar(SNRs,ARR(:,:),{@mean,@std},'-r',1)
contributions.shadedErrorbar(SNRs,ARRre(:,:),{@mean,@std},'-g',1)
contributions.shadedErrorbar(SNRs,diff(:,:),{@mean,@std},'-k',1) % difference between ARR synth and ARR real


%% plot differences between result and ground truth
subj = 3;
snr = -18;
params = mwf_params('delay', 10, 'rank', 'poseig');
T = EEG_data_synthetic(subj, snr);
[W] = mwf_compute(T.eeg_data, T.mask, params);
[n, d] = mwf_apply(T.eeg_data, W);
[SER, ARR] = mwf_performance(T.eeg_data, d, T.mask, T.artifact);
y = T.eeg_data;
d_gt = T.artifact;

% estimated artifact in channel 1
figure;
plot(d(1,:))
hold on;
plot(d_gt(1,:),'red')

% clean data in channel 1
figure;
plot(y(1,:))
hold on;
plot(n(1,:),'red')

%% do rank study for synthetic data
rank_pct = [1, 5:5:100];
for j = 1:numel(rank_pct)
    params = mwf_params('delay',5,'rank','pct','rankopt',rank_pct(j));    
    for i = 1:Nsubj
        [y, mask, blinkchannel, spatialdist_gt] = get_artifact_data_synthetic(i);
        [W]         = mwf_compute(y, mask, params);
        [n, d]      = mwf_apply(y, W);
        [SER(i,j), ARR(i,j)]  = mwf_performance(y, d, mask);
    end
end

figure
contributions.shadedErrorbar(rank_pct,SER(:,:),{@mean,@std},'-b',1)
hold on
contributions.shadedErrorbar(rank_pct,ARR(:,:),{@mean,@std},'-r',1)
