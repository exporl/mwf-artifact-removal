
% Centralized MWF-based eye blink artifact removal
name = 'alex';
artifact_type = 'muscle'; %blinks, muscle

load(['training_' artifact_type filesep 'training_' artifact_type '_' name '.mat'])

Fs = 200;

% Naming conciseness: y = mixed data, v = clean data, d = artifacts for
% training data
y = training_data;

% Set parameters
M = size(y,1);  % number of channels

% Set blink_segments (1-channel signal)
blink_segments = training_mask;

% Calculate the covariance matrices Ryy and Rvv
Ryy = cov(y.');                       % Ryy uses all data
Ryy_inv = Ryy \ speye(size(Ryy));     % This is numerically more stable than inv(Ryy) !
Rvv = cov(y(:,blink_segments==0).');  % Rvv only uses clean data

% Calculate the MWF 
w = (eye(M) - Ryy_inv * Rvv);

% EVD and setting negative eigenvalues to zero
% [V,D] = eig(w);
% D(D<0) = 0;
% w = V*D/V;

% GEVD-based MWF
threshold = 0; %select largest eigenvalue to maintain threshold
[X,delta] = eig(Ryy,Rvv);
triangle = delta - eye(M);
plot(diag(triangle))
triangle(triangle<threshold) = 0;
w = X*inv(delta)*triangle*inv(X);

% Rank R approximation
% R = 34;
% triangle(1:end-R,1:end-R) = 0;
% %triangle(end-R+2:end,end-R+2:end) = 0; % inlcude if you ONLY want the R'th component
% w = X*inv(delta)*triangle*inv(X); % Rank R approximate


% subtract the eye blinks from training data
d = (w.') * y;      
v = y - d;

% subtract the eye blinks from all data
eeg_artifacts = (w.') * eeg_data;
eeg_filtered = eeg_data - eeg_artifacts;

% Performance parameters for training data
[SER,ARR] = filter_performance(y,d,training_mask);
[SER,ARR]

eegplot(eeg_data,'data2',eeg_filtered,'srate',Fs,'winlength',10,'dispchans',3,...
   'spacing',200,'title','Original EEG data (blue) + Filtered EEG data (red)')

eegplot(eeg_artifacts,'srate',Fs,'winlength',10,'dispchans',3,...
   'spacing',200,'title','Artifacts')

