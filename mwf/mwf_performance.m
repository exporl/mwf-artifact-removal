% Compute artifact removal performance measures SER and ARR. 
% If the real, ground truth artifact is known and given as 4th argument, 
% the real ARR can be computed. Otherwise, the artifact is approximated by
% the raw data. SER and ARR are expressed in dB.
%
% Good artifact removal is indicated by high SER and high ARR
%
% INPUTS:
%   y       raw EEG data (channels x samples)
%   d       estimated artifacts in every channel (channels x samples)
%   mask    markings of artifacts in y (1 x samples)
%   d_real  [optional] ground truth artifact signal (channels x samples)
%
% OUTPUTS: 
%   SER     Signal to Error Ratio, measures clean EEG distortion
%   ARR     Artifact to Residue Ratio, measures artifact estimation
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [SER, ARR] = mwf_performance(y, d, mask, d_real)

mwf_utils.check_dimensions(size(y));

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

