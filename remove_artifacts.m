% Remove specified artifact type 'artifact' from EEG measurement of subject
% 'name'. Returns data y, artifact estimate d, clean data v, SER and ARR.

function [y, d, n, W, SER, ARR] = remove_artifacts(name, artifact, params)

[y, ~, ~]   = get_data(name, artifact);
mask        = get_artifact_mask(name, artifact);
[W]         = filter_compute(y, mask, params);
[n, d]      = filter_apply(y, W);
[SER, ARR]  = filter_performance(y, d, mask);

end
