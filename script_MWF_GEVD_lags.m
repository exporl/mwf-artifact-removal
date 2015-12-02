% SETTINGS: taumax = 0 (no lags), 3 (lags)
%           gevd = 0 (no gevd), 1 (gevd)


% Centralized MWF-based eye blink artifact removal
% name = 'alex';
% artifact_type = 'muscle'; %blinks, muscle

load(['training_' artifact_type filesep 'training_' artifact_type '_' name '.mat'])

Fs = 200;

% Naming conciseness: y = mixed data, v = clean data, d = artifacts for
% training data
y = training_data;

% create y_stack for stacking all delayed version
y_stack = y;
eeg_stack = eeg_data;
%taumax = 3;

for tau = 1:taumax
    
y_delay = y(:,[ tau+1:end  1:tau ]);  % cyclic shift over tau to right 
y_delay(:, 1:tau) = 0;                % remove first tau rows of y (delayed, not cyclic!)

y_forward = y(:,[ end-tau+1:end  1:end-tau ]);  % cyclic shift over tau to left 
y_forward(:, end-tau+1:end) = 0;     

y_stack = [y_stack ; y_forward ; y_delay];

% construct EEG data
eeg_delay = eeg_data(:,[ tau+1:end  1:tau ]);   % cyclic shift over tau to right 
eeg_delay(:, 1:tau) = 0;                        % remove first tau rows of y (delayed, not cyclic!)

eeg_forward = eeg_data(:,[ end-tau+1:end  1:end-tau ]);  % cyclic shift over tau to left 
eeg_forward(:, end-tau+1:end) = 0;         

eeg_stack = [eeg_stack ; eeg_forward ; eeg_delay];
end

% Set parameters
M = size(y,1);  % number of channels
M_stack = size(y_stack,1);  % number of channels

% Set blink_segments (1-channel signal)
blink_segments = training_mask;

% Calculate the covariance matrices Ryy and Rvv
Ryy = cov(y_stack.');                       % Ryy uses all data
Ryy_inv = Ryy \ speye(size(Ryy));     % This is numerically more stable than inv(Ryy) !
Rvv = cov(y_stack(:,blink_segments==0).');  % Rvv only uses clean data

if (gevd == 0)
% Calculate the MWF 
w = (eye(M_stack) - Ryy_inv * Rvv);
else
% GEVD-based MWF
threshold = 0; %select largest eigenvalue to maintain threshold
[X,delta] = eig(Ryy,Rvv);
triangle = delta - eye(M_stack);
triangle(triangle<threshold) = 0;
w = X*inv(delta)*triangle*inv(X); 
end

% Rank R approximation
% R = 34;
% triangle(1:end-R,1:end-R) = 0;
% %triangle(end-R+2:end,end-R+2:end) = 0; % inlcude if you ONLY want the R'th component
% w = X*inv(delta)*triangle*inv(X); % Rank R approximate


% subtract the eye blinks from training data
d = (w.') * y_stack;      
v = y_stack - d;

% subtract the eye blinks from all data
eeg_artifacts = (w.') * eeg_stack;
eeg_filtered = eeg_stack - eeg_artifacts;

% Performance parameters for training data
[SER,ARR] = filter_performance(y_stack(1:M,1:20*300),d(1:M,1:20*300),training_mask(1:20*300));
[SER,ARR]

% eegplot(eeg_data(1:M,:),'data2',eeg_filtered(1:M,:),'srate',Fs,'winlength',10,'dispchans',3,...
%   'spacing',200,'title',['Original EEG data (blue) + Filtered EEG data (red), taumax = ' num2str(taumax)])
% 
% eegplot(eeg_artifacts(1:M,:),'srate',Fs,'winlength',10,'dispchans',3,...
%   'spacing',200,'title','Artifacts')

