function [SER, ARR] = filter_performance(y,d,blinks)

% PERFORMANCE takes a set of eeg data (y), and the artifacts estimates for
% that set (d), and computes the performance parameters SER and SEAC based
% on those. Furthermore, the function needs a single channel (blink_segments)
% which indicates the artifact free- and corrupted regions.

M = size(y,1); % number of channels

% Separation of data (0 = no artifacts, 1 = corrupted)
clean_d = d(:,blinks==0);
clean_y = y(:,blinks==0);
dirty_d = d(:,blinks==1);
dirty_y = y(:,blinks==1);

p = var(dirty_y.')-var(clean_y.');
p(p < 0) = 0;

% SER = Signal-to-Error Ratio
% Measured in parts without artifacts
% WEIGHTED ACCORDING TO ARTIFACT POWER

SER = 0;
for j = 1:M
    SER = SER + p(j)*10*log10( var(clean_y(j,:))/var(clean_d(j,:)) );
end
SER = SER/sum(p);

% ARR = Artifact-to-Residu Ratio
% Measured in parts with artifacts
% WEIGHTED ACCORDING TO ARTIFACT POWER

ARR = 0;
for j = 1:M;
    ARR = ARR + p(j)*10*log10( var(dirty_y(j,:))/var(dirty_y(j,:)-dirty_d(j,:)) );
end
ARR = ARR/sum(p);

end

