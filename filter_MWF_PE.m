% 
% Centralized MWF-based eye blink artifact removal
%
% All EEG data must be in channels x datapoints format
%
% INPUT:    training_data:    Training EEG data on which manual blink marking is performed
%           training_blinks:  Resulting blink marker signal 
%           eeg_data:         EEG data matrix conataining full data measurement
%                 
% OUTPUT:   eeg_filtered:     Filtered version of INPUT in same format
%           SER, ARR:         Performance parameters

function [eeg_filtered,SER,ARR] = filter_MWF_PE(training_data,training_blinks,eeg_data)

% Naming conciseness: y = mixed data, v = clean data, d = artifacts for
% training data
y = training_data;

% Set parameters
M = size(y,1);  % number of channels

% Set blink_segments (1-channel signal)
blink_segments = training_blinks;

% Calculate the covariance matrices Ryy and Rvv
Ryy = cov(y.');                       % Ryy uses all data
Ryy_inv = Ryy \ speye(size(Ryy));     % This is numerically more stable than inv(Ryy) !
Rvv = cov(y(:,blink_segments==0).');  % Rvv only uses clean data

% Calculate the MWF 
w = (eye(M) - Ryy_inv * Rvv);

% Set negative eigenvalues to zero
[V,D] = eig(w);
D(D<0) = 0;
w = V*D/V;

% subtract the eye blinks from training data
d = (w.') * y;      
v = y - d;

% subtract the eye blinks from all data
eeg_artifacts = (w.') * eeg_data;
eeg_filtered = eeg_data - eeg_artifacts;

% Performance parameters for training data
[SER,ARR] = filter_performance(y,d,training_blinks);



