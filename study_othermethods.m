
clear

artifact = 'muscle';
methods = {'mwf', 'infomax', 'fastica', 'cca'};
Nsubj = 10;
Nmeth = numel(methods);

cache = struct;
cache.artifact = artifact;
cache.snr = 'real';

SER = zeros(Nsubj, Nmeth);
ARR = zeros(Nsubj, Nmeth);
time = zeros(Nsubj, Nmeth);

% MWF
mwfparams = filter_params('delay', 10, 'rank', 'poseig');
[SER(:,1), ARR(:,1), time(:,1)] = remove_artifacts_allsubjects(artifact, mwfparams);

% infomax ICA
cache.method = 'infomax';
for subj = 1:Nsubj
cache.name = get_name(subj);
[y, Fs] = get_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[v,d,time(subj,2)] = method_infomax_ica(y, Fs, cache);
[SER(subj,2), ARR(subj,2)] = filter_performance(y, d, mask);
end

% fastICA
rng('default')
cache.method = 'fastica';
for subj = 1:Nsubj
cache.name = get_name(subj);
[y, Fs] = get_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[v,d,time(subj,3)] = method_fastica(y, Fs, cache);
[SER(subj,3), ARR(subj,3)] = filter_performance(y, d, mask);
end

% CCA
cache.method = 'cca';
for subj = 1:Nsubj
cache.name = get_name(subj);
[y, Fs] = get_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[v,d,time(subj,4)] = method_cca(y, Fs, cache);
[SER(subj,4), ARR(subj,4)] = filter_performance(y, d, mask);
end

figure; boxplot(SER, methods)
figure; boxplot(ARR, methods)
figure; boxplot(time, methods)




