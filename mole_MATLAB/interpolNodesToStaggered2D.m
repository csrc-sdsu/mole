function I = interpolNodesToStaggered2D(k, m, n)
% interpolation operator from nodal coordinates to staggered centers
% m, o, are the number of cells in the logical x-, y- axes
% nodal logical coordinates are [1:1:m]x[1:1:n]
% staggered logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]

    I1 = interpolFacesToStaggered1D(k, m);
    I2 = interpolFacesToStaggered1D(k, n);

    I = kron(I2, I1);
end