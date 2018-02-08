% Use MWF to process EEG data corresponding to the given name/artifact 
% inputs with the given processing parameters. 
%
% INPUTS:
%   name        subject identifier (string)
%   artifact    artifact type specifier (string)
%   params      MWF parameter struct
%
% OUTPUTS: 
%   y       raw EEG data (channels x samples)
%   d       estimated artifacts in every channel (channels x samples)
%   n       filtered EEG data (channels x samples)
%   W       multi-channel Wiener filter (size depends on number of delays)
%   SER     Signal to Error Ratio, measures clean EEG distortion
%   ARR     Artifact to Residue Ratio, measures artifact estimation
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [y, d, n, W, SER, ARR] = remove_artifacts(name, artifact, params)

[y, ~, ~]   = get_artifact_data(name, artifact);
mask        = get_artifact_mask(name, artifact);
[W]         = mwf_compute(y, mask, params);
[n, d]      = mwf_apply(y, W);
[SER, ARR]  = mwf_performance(y, d, mask);

end
