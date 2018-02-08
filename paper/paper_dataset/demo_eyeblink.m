
% Demonstration of eye blink artifact removal in one measurement.

% subject name can be specified by either the string (e.g. 'alex') or by a
% number from 1 to 10.
name = 3; % retrieves data from 'alex'

% artifact name is specified by a string indicating artifact type (e.g.
% 'eyeblink', 'muscle')
artifact = 'muscle';
redo = 0; % put to 1 if you want to use the eyeballgui to make the mask

% retrieve EEG data with 'eyeblink' artifacts from subject 1 ('alex')
% EEG data y is in channels x samples format
[y, Fs, duration] = get_artifact_data(name, artifact);

% retrieve EEG artifact mask for subject 1 ('alex')
mask = get_artifact_mask(name, artifact, redo);

% set some processing parameters in struct p
p = mwf_params('delay', 10, 'rank', 'poseig');

% compute GEVD-MWF for data y
[W]         = mwf_compute(y, mask, p);

% apply the computed filter W to data y
% n and d are resp. clean data and artifact estimate
[n, d]      = mwf_apply(y, W);

% compute performance parameters for the artifact removal
[SER, ARR]  = mwf_performance(y, d, mask);

% plot result of artifact removal
chan = 1;  % Fp1
figure
plot(y(chan,:)); hold on; plot(d(chan,:),'red');
legend('raw data', 'artifact estimate')

figure
plot(y(chan,:)); hold on; plot(n(chan,:),'green');
legend('raw data', 'clean data')

