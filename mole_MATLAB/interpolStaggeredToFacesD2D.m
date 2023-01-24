function I = interpolStaggeredToFacesD2D(k, m, n)
% 2D interpolation from centers to faces. 
% m and n are the number of cells in the logic x-axis and y-axis

    Ix = interpolStaggeredToFacesD1D(k, m);
    Iy = interpolStaggeredToFacesD1D(k, n);

    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);

    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);

    Sx = kron(In', Ix);
    Sy = kron(Iy, Im');

    I = sparse(n*(m+1)+(n+1)*m, 2*(n+2)*(m+2));
    
    I(1:n*(m+1), 1:(n+2)*(m+2)) = Sx; 
    I(n*(m+1)+1:end, (n+2)*(m+2)+1:end) = Sy;  
end