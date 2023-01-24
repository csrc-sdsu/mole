function I = interpolNodesToStaggered1D(k, m)
% interpolation operator from nodal coordinates to staggered centers
% m is the number of cells in the logical x-axis
% nodal logical coordinates are [1:1:m]
% staggered logical coordinates [1,1.5:m-0.5,m]

    I = interpolFacesToStaggeredG1D(k, m);
end