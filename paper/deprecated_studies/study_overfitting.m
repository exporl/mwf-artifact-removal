
clear

Nsubj = 10;
artifact = 'eyeblink';
trdur = 30;
tau = 0;
notrain_params = mwf_params('delay',tau);
train_params = mwf_params('delay',tau,'train_len',trdur);

% Use full data to compute filter
[SER, ARR] = remove_artifacts_allsubjects(artifact, notrain_params);

% Use training data to compute filter
for i = 1:Nsubj
    [y, ~, ~]   = get_artifact_data(i, artifact);
    mask        = get_artifact_mask(i, artifact);
    [W]         = mwf_compute(y, mask, train_params);
    [~, d]      = mwf_apply(y, W);
    
    % split y and d in training/nontraining segments
    train_samples = train_params.train_len * train_params.srate;
    y1 = y(:,1:train_samples);
    mask1 = mask(:,1:train_samples);
    d1 = d(:,1:train_samples);
    y2 = y(:,train_samples+1:end);
    mask2 = mask(:,train_samples+1:end);
    d2 = d(:,train_samples+1:end);
    
    [SERt(i), ARRt(i)]  = mwf_performance(y, d, mask);
    [SER1(i), ARR1(i)]  = mwf_performance(y1, d1, mask1);
    [SER2(i), ARR2(i)]  = mwf_performance(y2, d2, mask2);
end

S = [SER SERt' SER1' SER2'];
A = [ARR ARRt' ARR1' ARR2'];
label = {'no training','full_30','traindata_30','validate_30'};

S(8,:) = [];
A(8,:) = [];

figure
boxplot(S, 1:size(S,2))
ylabel('SER [dB]')
title('SER in function of training used')
hold on
plot(S.','.--','MarkerSize',10)
set(gca,'XTick',1:size(S,2))
set(gca,'XTickLabel',label)


figure
boxplot(A, 1:size(A,2))
ylabel('ARR [dB]')
title('ARR in function of training used')
hold on
plot(A.','.--','MarkerSize',10)
set(gca,'XTick',1:size(A,2))
set(gca,'XTickLabel',label)