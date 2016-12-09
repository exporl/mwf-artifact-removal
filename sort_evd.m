function [ eigvect_out, eigval_out ] = sort_evd(eigvect_in, eigval_in)

[~, permutation] = sort(diag(eigval_in));
eigvect_out = eigvect_in(:,permutation);
eigval_out = eigval_in(permutation,permutation);

end

