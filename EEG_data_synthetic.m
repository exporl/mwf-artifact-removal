% Create synthetic EEG data corrupted with eye blink artifacts
%
% Synthetic data is created from the eye blink artifact measurements. The
% data is cleaned of eye blink artifacts using the GEVD-MWF. Eye blink
% artifact templates are then added across the channels with a realistic
% spatial distribution. The synthetic data and the mask are saved.
% 
% INPUT: name (or index) of EEG data subject.
%
% OUTPUT: EEG data as channels x samples, saved in the EEG_data_synthetic
% folder in the format <name>_synthetic.mat. 
%
% Also saves the working sample rate Fs and measurement duration.

function EEG_data_synthetic(name)
settings = mwfgui_localsettings;

if (isa(name,'double'))
    name = get_name(name);
end

% Get clean EEG data
[~, Fs, duration] = get_data(name,'eyeblink');
params = filter_params('rank', 'poseig', 'delay', 10);
[~, d, v] = remove_artifacts(name, 'eyeblink', params);

% get normalized spatial distribution estimate of blink
mask = get_artifact_mask(name, 'eyeblink');
spatialdist = std(d(:,mask==1),[],2);
spatialdist = spatialdist./max(spatialdist);

% load eye blink artifact template
blink = getfield(load('blink_template.mat'), 'blink');

% create channel full of eye blinks spaced about 5 seconds apart
blinkchannel = zeros(1, size(v,2));
mask = blinkchannel;
L_blink = size(blink,2);
S = 5; % an eyeblink is inserted on average every S seconds
minscale = 0.8; % minimum eyeblink scaling
maxscale = 1.5; % maximum eyeblink scaling

pos = 0.5*S*Fs;
while pos < size(v,2) - L_blink - 0.5*S*Fs
    pos = round(pos - 0.5*S*Fs + S*Fs*rand); % randomly shift the blink between [-0.5*S , 0.5*S]
    blinkfactor = minscale + (maxscale-minscale)*rand; % randomly scale blink amplitude
    blinkchannel(1,pos:pos+L_blink-1) = blink*blinkfactor;
    mask(1,pos:pos+L_blink-1) = 1;
    pos = pos + S*Fs;
end

% mix artifacts over channels
eeg_data = v;
eeg_data = eeg_data + spatialdist*blinkchannel;

% Save synthetic data and mask to a mat-file
save(fullfile(settings.syntheticpath,[name '_synthetic.mat']), ...
    'eeg_data','mask','blinkchannel','spatialdist','Fs','duration','mask');

end


