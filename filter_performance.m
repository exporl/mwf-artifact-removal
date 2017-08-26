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
Y_c     = y(:, mask==0).'; % clean EEG segments
Y_a     = y(:, mask==1).'; % artifact EEG segments
D_c     = d(:, mask==0).'; % estimated artifact, clean segments
D_a     = d(:, mask==1).'; % estimated artifact, artifact segments
if nargin > 3
    D_a_real = d_real(:,mask==1).';
else
    D_a_real = Y_a; % approximation for real data
end

% Compute weights [0..1] according to artifact power per channel
p = var(Y_a) - var(Y_c);
p(p < 0) = 0;
p = p / sum(p);

% SER
SER_i = 10*log10(var(Y_c) ./ var(D_c)); % SER per channel
SER_w = SER_i .* p; % SER per channel (weighted)
SER = sum(SER_w); % Total SER (weighted average)

% ARR
ARR_i = 10*log10(var(D_a_real) ./ var(D_a_real - D_a)); % ARR per channel
ARR_w = ARR_i .* p; % ARR per channel (weighted)
ARR = sum(ARR_w); % Total ARR (weighted average)

end

