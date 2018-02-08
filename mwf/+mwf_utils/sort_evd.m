% Sort a set of eigenvectors and eigenvalues in descending order.
%
% The eigenvectors and eigenvalues are permutated in the same way to ensure
% corresponding eigenvalues/eigenvectors correspond in the sorted result.
%
% INPUTS:
%   eigvect_in      input eigenvectors
%   eigval_in       input eigenvalues
%
% OUTPUTS: 
%   eigvect_out     output eigenvectors, permutated according to eigval_out
%   eigval_out      output eigenvalues, sorted in descending order
%
% Author: Ben Somers, KU Leuven, Department of Neurosciences, ExpORL
% Correspondence: ben.somers@med.kuleuven.be

function [eigvect_out, eigval_out] = sort_evd(eigvect_in, eigval_in)

[~, permutation] = sort(diag(eigval_in),'descend');
eigvect_out = eigvect_in(:,permutation);
eigval_out = eigval_in(permutation,permutation);

end

