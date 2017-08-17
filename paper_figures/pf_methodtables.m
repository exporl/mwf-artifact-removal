% Generate data for tables comparing artifact removal methods (ICA & CCA)
% Process data with MWF with different timelags

clear

artifact = {'eyeblink','muscle'};
methods = { 'mwf5', 'mwf10', 'mwf15', 'infomax', 'fastica' 'cca'};
Nsubj = 10;
Nmeth = numel(methods);

cache = struct;
cache.snr = 'real';

SER = zeros(Nsubj, Nmeth);
ARR = zeros(Nsubj, Nmeth);
time = zeros(Nsubj, Nmeth);

for a = 1:numel(artifact)
cache.artifact = artifact{a};

% MWF, 5 lags
[domethod, ind] = ismember('mwf5',methods);
if domethod
    mwfparams = filter_params('delay', 5, 'rank', 'poseig');
    [SER(:,ind), ARR(:,ind), time(:,ind)] = remove_artifacts_allsubjects(artifact{a}, mwfparams);
end

% MWF, 10 lags
[domethod, ind] = ismember('mwf10',methods);
if domethod
    mwfparams = filter_params('delay', 10, 'rank', 'poseig');
    [SER(:,ind), ARR(:,ind), time(:,ind)] = remove_artifacts_allsubjects(artifact{a}, mwfparams);
end

% MWF, 20 lags
[domethod, ind] = ismember('mwf15',methods);
if domethod
    mwfparams = filter_params('delay', 15, 'rank', 'poseig');
    [SER(:,ind), ARR(:,ind), time(:,ind)] = remove_artifacts_allsubjects(artifact{a}, mwfparams);
end

% infomax ICA
[domethod, ind] = ismember('infomax',methods);
if domethod
    cache.method = 'infomax';
    for subj = 1:Nsubj
        cache.name = get_name(subj);
        [y, Fs] = get_data(subj, artifact{a});
        mask = get_artifact_mask(subj, artifact{a});
        [v,d,time(subj,ind)] = method_infomax_ica(y, Fs, cache);
        [SER(subj,ind), ARR(subj,ind)] = filter_performance(y, d, mask);
        rng('default')
    end
end

% fastICA
[domethod, ind] = ismember('fastica',methods);
if domethod
    cache.method = 'fastica';
    for subj = 1:Nsubj
        cache.name = get_name(subj);
        [y, Fs] = get_data(subj, artifact{a});
        mask = get_artifact_mask(subj, artifact{a});
        [v,d,time(subj,ind)] = method_fastica(y, Fs, cache);
        [SER(subj,ind), ARR(subj,ind)] = filter_performance(y, d, mask);
    end
end

% CCA
[domethod, ind] = ismember('cca',methods);
if domethod
    cache.method = 'cca';
    for subj = 1:Nsubj
        cache.name = get_name(subj);
        [y, Fs] = get_data(subj, artifact{a});
        mask = get_artifact_mask(subj, artifact{a});
        [v,d,time(subj,ind)] = method_cca(y, Fs, 1, cache);
        [SER(subj,ind), ARR(subj,ind)] = filter_performance(y, d, mask);
    end
end

switch artifact{a}
    case 'eyeblink'
        mSERb = round(mean(SER([1:7,9:10],:)),2);
        mARRb = round(mean(ARR([1:7,9:10],:)),2);
        mtimeb = round(mean(time([1:7,9:10],:)),2);
        sSERb = round(std(SER([1:7,9:10],:)),2);
        sARRb = round(std(ARR([1:7,9:10],:)),2);
        stimeb = round(std(time([1:7,9:10],:)),2);
    case 'muscle'
        mSERm = round(mean(SER),2);
        mARRm = round(mean(ARR),2);
        mtimem = round(mean(time),2);
        sSERm = round(std(SER),2);
        sARRm = round(std(ARR),2);
        stimem = round(std(time),2);
end

end

% Generate latex table strings
pm = ' $\pm$ ';
for i = 1:numel(methods)
    Bstring{i} = [num2str(mSERb(i)) pm  num2str(sSERb(i)) ' & ' ...
                    num2str(mARRb(i)) pm  num2str(sARRb(i)) ' & ' ...
                    num2str(mtimeb(i)) pm  num2str(stimeb(i)) ' \\'];
    Mstring{i} = [num2str(mSERm(i)) pm  num2str(sSERm(i)) ' & ' ...
                    num2str(mARRm(i)) pm  num2str(sARRm(i)) ' & ' ...
                    num2str(mtimem(i)) pm  num2str(stimem(i)) ' \\'];
end

for i = 1:numel(methods)
    Bstring{i}
end
for i = 1:numel(methods)
    Mstring{i}
end
