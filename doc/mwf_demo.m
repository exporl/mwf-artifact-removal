%% Demonstration of the MWF-based tool for EEG artifact removal. 
%
% This file demonstrates section-by-section how to use MWF functions 
% provided in this toolbox.
%
% NOTES: 
%   - check that the "mwf" folder is on the MATLAB path.
%   - ensure that eeglab is on the MATLAB path Type "eeglab" in the 
%     command window to verify that eeglab is on the MATLAB path.
%
% The processing with MWF basically goes as follows:
%   - obtain raw EEG data
%   - obtain an artifact mask, i.e. where are the artifacts in the EEG?
%   - choose MWF parameters
%   - compute the MWF
%   - apply the MWF
%   - evaluate performance
%
% If this method has been useful for you, please cite the corresponding
% paper: 
% [1] Somers, B., Francart, T. and Bertrand, A. (2018). A generic EEG 
% artifact removal method based on the multi-channel Wiener filter. 
% Journal of Neural Engineering, 15(3), 036007. DOI: 10.1088/1741-2552/aaac92
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

%% Load some dummy EEG data

L = load('demo_data.mat');
y = L.demo_EEG;             % Raw EEG data, contains eye blink artifacts
Fs = L.demo_samplerate;     % EEG sample rate
mask = L.demo_mask;         % Example marking of artifacts in y

%% Obtain a mask for the artifacts in y.
% You can use the mwf_getmask function to manually select artifact segments
% in the EEG data y. Running the function will open an eegplot view where
% you can click-and-drag over artifacts to mark them. You can also scroll
% temporally through the data using the << and >> keys. Clicking the SAVE
% MARKS button will close the plot and save your mask.
%
% Using mwf_getmask is optional: you can use a different method to detect
% artifacts in the EEG data (e.g. based on a threshold). The MWF requires a
% mask vector of the same length as the EEG with ones where artifacts are,
% and zeroes everywhere else.

your_mask = mwf_getmask(y, Fs);
% mask = your_mask; % uncomment to use your own created mask.

%% Select MWF parameters
% In order to compute a MWF for estimating the artifacts targetted by your
% mask, you will need to provide the mask and some parameters to the
% mwf_compute function.
%
% Two important parameters should be considered: the amount of delays
% included in the filter and the rank or the artifact filter. Both of these
% can be chosen easily based on the results of [1]:
%   - More delays = better performance, however there are diminishing
%     returns. Also, computation time increases for more delays. A good
%     starting value would be 5 or 10 (default: 0).
%   - Rank: best performance is achieved when reducing the filter to a rank
%     such that only positive eigenvalues are included. This option is
%     labeled 'poseig' and is default.
%
% Use the mwf_params function to create a parameter struct as desired:

params = mwf_params('rank', 'poseig', 'delay', 5);

%% Compute the MWF
% This can be done using the mwf_compute function. Note that params is an
% optional input: if it is not provided the default parameters of 0 delays
% and 'poseig' rank will be used.

W = mwf_compute(y, mask, params);

%% Apply the MWF to the EEG data
% This is done using the mwf_apply function. This function returns both the
% clean EEG data n and the artifact estimate d. They both add up to y, i.e.
% y = d + n.

[n, d] = mwf_apply(y, W);

% Let's have a look at the estimated artifact in channel 1 near the eyes:
t = linspace(0, size(y,2)/Fs, size(y,2));
hd = figure;
hold on;
plot(t, y(1,:),'b', t, d(1,:),'r');
legend('Raw EEG data', 'Artifact Estimate')
ylabel('Amplitude [uV]')
xlabel('Time [s]')

% And the clean EEG data after artifact removal:
hn = figure;
hold on;
plot(t, y(1,:),'b', t, n(1,:),'g');
legend('Raw EEG data', 'Clean EEG data after MWF')
ylabel('Amplitude [uV]')
xlabel('Time [s]')

%% Evaluate filter performance (optional)
% In [1], two performance measures were used to assess artifact removal
% quality:
%   - the Signal-to-Error Ratio (SER) is a measure for distortion of EEG
%     outside of artifact segments. Expressed in dB. Higher is better.
%   - the Artifact-to-Residue Ratio (ARR) is a measure for artifact
%     estimation quality. Expressed in dB. Higher is better.
% The mwf_performance function computes these measures based on the
% original EEG data, the artifact estimate and the artifact mask.

[SER, ARR] = mwf_performance(y, d, mask);

%% Using the entire MWF in one function
% The above processing can also be summarized by using mwf_process. This
% function is the most user-friendly: just provide it with the raw EEG
% data, a mask, and the amount of delays you want (the rank is
% chosen optimally).

delay = 5;
[n, d, W, SER, ARR, params] = mwf_process(y, mask, delay);

% This function is more convenient to use instead of using all mwf_params,
% mwf_compute, mwf_apply, etc. For an example usage, let's see what happens
% if we increase the number of delays from 0 to 6 samples:

delays = 0:6;
SER_t = zeros(size(delays)); ARR_t = SER_t;
for idx = 1:numel(delays)
    [~, ~, ~, SER_t(idx), ARR_t(idx), ~] = mwf_process(y, mask, delays(idx));
end; clear idx;

hp = figure; hold on;
subplot(2,1,1)
plot(delays, SER_t, 'b*:', 'LineWidth', 3)
title('SER as function of MWF delays'); xlabel('Maximum delay used'); ylabel('SER [dB]')
subplot(2,1,2)
plot(delays, ARR_t, 'r*:', 'LineWidth', 3)
title('ARR as function of MWF delays'); xlabel('Maximum delay used'); ylabel('ARR [dB]')
