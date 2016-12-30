function [eigvect_out, eigval_out] = sort_evd(eigvect_in, eigval_in)
% Sort a set of eigenvectors and eigenvalues in descending order
%
% The eigenvectors and eigenvalues are permutated in the same way to ensure
% corresponding eigenvalues/eigenvectors correspond in the sorted result

[~, permutation] = sort(diag(eigval_in),'descend');
eigvect_out = eigvect_in(:,permutation);
eigval_out = eigval_in(permutation,permutation);

end

