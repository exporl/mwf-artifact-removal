
clear

artifact = 'eyeblink';
methods = {'GEVD-MWF', 'infomax_ICA', 'fastICA', 'CCA'};
Nsubj = 10;
Nmeth = numel(methods);

SER = zeros(Nsubj, Nmeth);
ARR = zeros(Nsubj, Nmeth);
time = zeros(Nsubj, Nmeth);

% MWF
mwfparams = filter_params('delay', 10, 'rank', 'poseig');
[SER(:,1), ARR(:,1), t(:,1)] = remove_artifacts_allsubjects('muscle', mwfparams);

% infomax ICA
for subj = 1:Nsubj
[y, Fs] = get_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[v,d,time(subj,2)] = method_infomax_ica(y, Fs, subj, artifact);
[SER(subj,2), ARR(subj,2)] = filter_performance(y, d, mask);
end

% fastICA
rng('default')
for subj = 1:Nsubj
[y, Fs] = get_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[v,d,time(subj,3)] = method_fastica(y, Fs, subj, artifact);
[SER(subj,3), ARR(subj,3)] = filter_performance(y, d, mask);
end

% CCA
for subj = 1:Nsubj
[y, Fs] = get_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[v,d,time(subj,4)] = method_cca(y, Fs, subj, artifact);
[SER(subj,4), ARR(subj,4)] = filter_performance(y, d, mask);
end

figure; boxplot(SER, methods)
figure; boxplot(ARR, methods)




