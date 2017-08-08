function [SER, ARR] = filter_performance(y, d, mask, d_real)

% filter_performance takes multichannel eeg data y, and the multichannel 
% artifact estimate d, and computes the performance parameters SER and ARR 
% based on those. Furthermore, the function needs the artifact mask to 
% compute the clean and corrupted regions.

% SER = Signal-to-Error Ratio
% Measures alteration of EEG signal in parts without artifact

% ARR = Artifact-to-Residu Ratio
% Measures artifact estimate in parts with artifacts. If the ground truth
% artifact signal (d_real) is not known, it is approximated by y.

% Good artifact removal is indicated by high SER and high ARR

% Segmentation of data using mask
y_clean     = y(:, mask==0).';
y_corrupt   = y(:, mask==1).';
d_clean     = d(:, mask==0).';
d_corrupt   = d(:, mask==1).';
if nargin > 3
    d_real_corrupt = d_real(:,mask==1).';
else
    d_real_corrupt = y_corrupt; % approximation for real data
end

% Compute weights [0..1] according to artifact power per channel
p = var(y_corrupt) - var(y_clean);
p(p < 0) = 0;
p = p / sum(p);

% SER
SER_pc = 10*log10(var(y_clean) ./ var(d_clean)); % SER per channel
SER_w = SER_pc .* p; % SER per channel (weighted)
SER = sum(SER_w); % Total SER (weighted average)

% ARR
ARR_pc = 10*log10(var(y_corrupt) ./ var(d_real_corrupt - d_corrupt)); % ARR per channel
ARR_w = ARR_pc .* p; % ARR per channel (weighted)
ARR = sum(ARR_w); % Total ARR (weighted average)

end

