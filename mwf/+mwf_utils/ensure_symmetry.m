% Force a matrix X to be symmetric by averaging with its transpose.
% Eliminates issues caused by covariance matrices that are non-symmetric
% due to rounding errors.
%
% INPUTS:
%   X       Matrix to be forced to be symmetric
%
% OUTPUTS: 
%   X       Symmetric matrix
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function X = ensure_symmetry(X)

if ~issymmetric(X)
    X = (X.' + X) / 2;
end

end

