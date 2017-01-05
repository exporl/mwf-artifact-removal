% Remove specified artifact type 'artifact' from EEG measurement of subject
% 'name'. Returns data y, artifact estimate d, clean data v, SER and ARR.

function [y, d, v, w, SER, ARR] = remove_artifacts(name, artifact, params)

[y, ~, ~]   = get_data(name, artifact);
mask        = get_artifact_mask(name, artifact);
[w]         = filter_compute(y, mask, params);
[v, d]      = filter_apply(y, w);
[SER, ARR]  = filter_performance(y, d, mask);

end
