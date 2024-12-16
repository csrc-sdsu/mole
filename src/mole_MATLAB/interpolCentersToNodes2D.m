function I = interpolCentersToNodes2D(k, m, n)
% interpolation operator from staggered to nodes
% m, n, are the number of cells in the logical x-, y- axes
% nodal logical coordinates are [1:1:m]x[1:1:n]
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]

    I1 = interpolCentersToFacesD1D(k, m);
    I2 = interpolCentersToFacesD1D(k, n);

    I = kron(I2, I1);
end