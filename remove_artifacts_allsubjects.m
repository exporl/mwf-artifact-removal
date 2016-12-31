% Process all files for a certain artifact type (e.g. all eye blink
% measurements for all subjects)
% 
% Available artifact types for given dataset are:
% 'eyeblink', 'muscle' ,'speech', 'movement', 'mix'

function [SER, ARR] = remove_artifacts_allsubjects(artifact_type, params)

N_data = 10;
SER = zeros(N_data, 1);
ARR = zeros(N_data, 1);

for i = 1 : N_data;
    [~ ,~ ,~ ,SER(i), ARR(i)] = remove_artifacts(i, artifact_type, params);
end

end
