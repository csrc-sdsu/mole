function idx = boundaryIdx2D(m, n)
% Returns the indices of the nodes that lie on the boundary of a 2D nodal
% grid
%
% Parameters:
%           m : Number of nodes along x-axis
%           n : Number of nodes along y-axis

    idx = zeros(m*n, 1);
    
    idx(1:m) = 1;
    idx(end-m+1:end) = 1;
    
    for i = m+1:m:m*n
        idx(i) = 1;
        idx(i+m-1) = 1;
    end
    
    idx = find(idx);
end
