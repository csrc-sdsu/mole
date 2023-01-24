function I = interpolNodesToStaggered3D(k, m, n, o)
% interpolation operator from nodal coordinates to staggered centers
% m, n, o, are the number of cells in the logical x-, y-, z- axes
% nodal logical coordinates are [1:1:m]x[1:1:n]x[1:1:o]
% staggered logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]x[1,1.5:o-0.5,o]

    I1 = interpolFacesToStaggered1D(k, m);
    I2 = interpolFacesToStaggered1D(k, n);
    I3 = interpolFacesToStaggered1D(k, o);

    I = kron(I3, kron(I2, I1));
end