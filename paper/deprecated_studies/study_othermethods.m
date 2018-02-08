
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
mwfparams = mwf_params('delay', 10, 'rank', 'poseig');
[SER(:,1), ARR(:,1), time(:,1)] = remove_artifacts_allsubjects(artifact, mwfparams);

% infomax ICA
cache.method = 'infomax';
for subj = 1:Nsubj
cache.name = get_name_from_id(subj);
[y, Fs] = get_artifact_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[~,d,time(subj,2)] = method_infomax_ica(y, Fs, cache);
[SER(subj,2), ARR(subj,2)] = mwf_performance(y, d, mask);
end

% fastICA
rng('default')
cache.method = 'fastica';
for subj = 1:Nsubj
cache.name = get_name_from_id(subj);
[y, Fs] = get_artifact_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[~,d,time(subj,3)] = method_fastica(y, Fs, cache);
[SER(subj,3), ARR(subj,3)] = mwf_performance(y, d, mask);
end

% CCA
cache.method = 'cca';
for subj = 1:Nsubj
cache.name = get_name_from_id(subj);
[y, Fs] = get_artifact_data(subj, artifact);
mask = get_artifact_mask(subj, artifact);

[~,d,time(subj,4)] = method_cca(y, Fs, 1, cache);
[SER(subj,4), ARR(subj,4)] = mwf_performance(y, d, mask);
end

% MCCA
% cache.method = 'mcca';
% for subj = 1:Nsubj
% cache.name = get_name_from_id(subj);
% [y, Fs] = get_artifact_data(subj, artifact);
% mask = get_artifact_mask(subj, artifact);
% 
% [v,d,time(subj,4)] = method_cca(y, Fs, 5, cache);
% [SER(subj,4), ARR(subj,4)] = mwf_performance(y, d, mask);
% end

figure; boxplot(SER, methods)
figure; boxplot(ARR, methods)
figure; boxplot(time, methods)

switch artifact
    case 'eyeblink'
        mSERb = mean(SER([1:7,9:10],:));
        mARRb = mean(ARR([1:7,9:10],:));
        mtimeb = mean(time([1:7,9:10],:));
        sSERb = std(SER([1:7,9:10],:));
        sARRb = std(ARR([1:7,9:10],:));
        stimeb = std(time([1:7,9:10],:));
    case 'muscle'
        mSERm = mean(SER);
        mARRm = mean(ARR);
        mtimem = mean(time);
        sSERm = std(SER);
        sARRm = std(ARR);
        stimem = std(time);
end




