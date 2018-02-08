% Create hybrid EEG data containing artificial eye blink artifacts 
% corresponding to the given name input, and with specified artifact SNR.
%
% The hybrid data is created from the eye blink artifact measurements. The
% data is cleaned of eye blink artifacts using the GEVD-MWF. Eye blink
% artifact templates are then added across the channels with a realistic
% spatial distribution derived from real measurements. The hybrid data and 
% the ground truth artifact information are to cache and optionally
% returned as output.
%
% The cache directory to write is set by mwfgui_localsettings.m
%
% INPUTS:
%   name    subject identifier (string)
%   SNR     artifact SNR of resulting hybrid data
%
% OUTPUTS: 
%   T       [optional] struct containing ground truth information about
%           artificial eye blink artifacts added to EEG data.
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function T = EEG_data_synthetic(name, SNR)

if (nargin < 2); SNR = 0; end

settings = mwfgui_localsettings;

if (isa(name,'double'))
    name = get_name_from_id(name);
end

% Get clean EEG data
[~, Fs, duration] = get_artifact_data(name,'eyeblink');
params = mwf_params('rank', 'poseig', 'delay', 5);
[~, d, n] = remove_artifacts(name, 'eyeblink', params);

% get normalized spatial distribution estimate of blink
mask = get_artifact_mask(name, 'eyeblink');
spatialdist = std(d(:,mask==1),[],2);
spatialdist = spatialdist./max(spatialdist);

% load eye blink artifact template
blink = getfield(load('blink_template.mat'), 'blink');

% create channel full of eye blinks spaced about 5 seconds apart
blinkchannel = zeros(1, size(n,2));
mask = blinkchannel;
L_blink = size(blink,2);
S = 5; % an eyeblink is inserted on average every S seconds
minscale = 0.8; % minimum eyeblink scaling
maxscale = 1.5; % maximum eyeblink scaling

rng(0);
pos = 0.5*S*Fs;
while pos < size(n,2) - L_blink - 0.5*S*Fs
    pos = round(pos - 0.5*S*Fs + S*Fs*rand); % randomly shift the blink between [-0.5*S , 0.5*S]
    blinkfactor = minscale + (maxscale-minscale)*rand; % randomly scale blink amplitude
    blinkchannel(1,pos:pos+L_blink-1) = blink*blinkfactor;
    mask(1,pos:pos+L_blink-1) = 1;
    pos = pos + S*Fs;
end

% Generate artifacial artifact signal
d_art = spatialdist * blinkchannel;

% Scale template such that SNR = 0 for gamma = 1
En2 = mean(n(1,:).^2); % average noise power in channel 1
SNRfactor = 1/sqrt(mean(d_art(1,:).^2) / En2);

% scaling factor gamma will be multiplied with blinks to achieve SNR as defined in paper
gamma = sqrt((10^(SNR/10)) / (mean((SNRfactor * d_art(1,:)).^2) / En2));

if (nargin < 2) % use realistic amplitudes
    factor = 1;
else % scale amplitude to reach given SNR
    factor = SNRfactor * gamma;
end

% mix artifacts over channels
eeg_data = n;
eeg_data = eeg_data + d_art * factor;

% check that 
assert(abs(10*log10(mean((d_art(1,:) * factor).^2) / En2) - SNR) < 10^-3) ;

% keep the approximate SNR of the real data processed at the start
SNR_realdata = 10*log10(mean(d(1,:).^2) / En2);

% Save synthetic data and mask to a mat-file (only for realistic SNR)
if (nargin < 2)
    save(fullfile(settings.syntheticpath,[name '_synthetic.mat']), ...
        'eeg_data','mask','blinkchannel','spatialdist','Fs','duration','mask');
end

% define output if requested
if nargout > 0;
    T = struct;
    T.eeg_data = eeg_data;
    T.mask = mask;
    T.blinkchannel = blinkchannel;
    T.spatialdist = spatialdist;
    T.Fs = Fs;
    T.duration = duration;
    T.mask = mask;
    T.artifact = spatialdist * blinkchannel * factor;
    T.realisticSNR = SNR_realdata;
end

end


