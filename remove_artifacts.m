% Remove specified artifact type 'artifact' from EEG measurement of subject
% 'name'. Returns data y, artifact estimate d, clean data v, SER and ARR.
function [y, d, v, SER, ARR] = remove_artifacts(name, artifact, delay)

[y, ~, ~]   = get_data(name, artifact);
mask        = get_artifact_mask(name, artifact);
[v, d]      = filter_MWF(y, mask, delay);
[SER, ARR]  = filter_performance(y, d, mask);

end
