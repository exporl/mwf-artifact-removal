clear

Nsubj = 10;
SER = zeros(Nsubj, 1);
ARR = zeros(Nsubj, 1);

%% SER and ARR for all subjects

params = filter_params('delay', 10, 'rank', 'poseig');
for i = 1:Nsubj
    [y, mask, ~, ~] = get_data_synthetic(i);
    [W]         = filter_compute(y, mask, params);
    [~, d]      = filter_apply(y, W);
    [SER(i), ARR(i)]  = filter_performance(y, d, mask);
end

%% plot differences between result and ground truth
subj = 3;
params = filter_params('delay', 10, 'rank', 'poseig');
[y, mask, blinkchannel, spatialdist_gt] = get_data_synthetic(subj);
[W] = filter_compute(y, mask, params);
[n, d] = filter_apply(y, W);
[SER, ARR]  = filter_performance(y, d, mask);

% ground truths
d_gt = spatialdist_gt*blinkchannel;
n_gt = y - d_gt;

% estimated spatial distribution of artifacts
spatialdist_est = std(d(:,mask==1),[],2);
spatialdist_est = spatialdist_est./max(spatialdist_est);
figure; plot(spatialdist_gt); hold on; plot(spatialdist_est)

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
    params = filter_params('delay',5,'rank','pct','rankopt',rank_pct(j));    
    for i = 1:Nsubj
        [y, mask, blinkchannel, spatialdist_gt] = get_data_synthetic(i);
        [W]         = filter_compute(y, mask, params);
        [n, d]      = filter_apply(y, W);
        [SER(i,j), ARR(i,j)]  = filter_performance(y, d, mask);
    end
end

figure
shadedErrorbar(rank_pct,SER(:,:),{@mean,@std},'-b',1)
hold on
shadedErrorbar(rank_pct,ARR(:,:),{@mean,@std},'-r',1)
