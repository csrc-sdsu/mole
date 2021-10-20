function idx = boundaryIdx2D(m, n)
% Returns the indices of the nodes that lie on the boundary of a 2D nodal
% grid
%
% Parameters:
%           m : Number of nodes along x-axis
%           n : Number of nodes along y-axis

    idx = zeros(2*m+2*(n-2), 1);
    
    idx(1:m) = 1:m;
    idx(end-m+1:end) = m*n-m+1:m*n;
    
    k = m+1;
    for i = m+1:m:m*n-m
        idx(k) = i;
        idx(k+1) = i+m-1;
        k = k+2;
    end
end
