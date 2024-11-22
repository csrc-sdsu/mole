function I = interpolNodesToCenters2D(k, m, n)
% interpolation operator from nodal coordinates to staggered centers
% m, n, are the number of cells in the logical x-, y- axes
% nodal logical coordinates are [1:1:m]x[1:1:n]
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]

    I1 = interpolFacesToCentersG1D(k, m);
    I2 = interpolFacesToCentersG1D(k, n);

    I = kron(I2, I1);
end