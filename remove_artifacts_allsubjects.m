% Use MWF to process EEG data corresponding to the given artifact input 
% with the given processing parameters, for all subjects sequentially. 
%
% INPUTS:
%   artifact    artifact type specifier (string)
%   params      MWF parameter struct
%
% OUTPUTS: 
%   SER     Signal to Error Ratio, measures clean EEG distortion, per subject
%   ARR     Artifact to Residue Ratio, measures artifact estimation, per subject
%   t       computation time (seconds), per subject
%   pctkept  percentage of eigenvalues retained, per subject
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [SER, ARR, t, pctkept] = remove_artifacts_allsubjects(artifact, params)

N_data = 10;
SER = zeros(N_data, 1);
ARR = zeros(N_data, 1);
t = zeros(N_data, 1);
pctkept = zeros(N_data, 1);

for i = 1 : N_data;
    if (strcmp(artifact,'eyeblink') && (i == 8))
        continue
    end
    tic
    [~ ,~ ,~ , W, SER(i), ARR(i)] = remove_artifacts(i, artifact, params);
    t(i) = toc;
    pctkept(i) = rank(W)/size(W,1);
end

end
