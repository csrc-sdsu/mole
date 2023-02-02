function I = interpolFacesToCentersG2D(k, m, n)
% 2D interpolation from faces to centers
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]
% m, n, are the number of cells in the logical x- and y- axes

    Ix = interpolFacesToStaggeredG1D(k, m);
    Iy = interpolFacesToStaggeredG1D(k, n);

    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);

    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);

    Sx = kron(In, Ix);
    Sy = kron(Iy, Im);

    I = sparse(2*(n+2)*(m+2), n*(m+1)+(n+1)*m);
    
    I(1:(n+2)*(m+2), 1:n*(m+1)) = Sx; 
    I((n+2)*(m+2)+1:end, n*(m+1)+1:end) = Sy;  
end