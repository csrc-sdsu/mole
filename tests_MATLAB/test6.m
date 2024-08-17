% Consistency test for BCs operators (RobinBC and MixedBC)

addpath('../mole_MATLAB')

k = 4;
m = 50;
dx = 0.314;

% 1-D Case
RBC = robinBC(k, m, dx, 1, 0);
MBC = mixedBC(k, m, dx, 'Dirichlet', 1, 'Dirichlet', 1);

if nnz(RBC(1) - MBC(1)) || nnz(RBC(end) - MBC(end))
    fprintf("Test FAILED in 1-D case\n");
    return
end

RBC = robinBC(k, m, dx, 0, 2);
MBC = mixedBC(k, m, dx, 'Neumann', 2, 'Neumann', 2);

if nnz(RBC(1, :) - MBC(1, :)) || nnz(RBC(end, :) - MBC(end, :))
    fprintf("Test FAILED in 1-D case\n");
    return
end

RBC = robinBC(k, m, dx, 3, 4);
MBC = mixedBC(k, m, dx, 'Robin', [3, 4], 'Robin', [3, 4]);

if nnz(RBC(1, :) - MBC(1, :)) || nnz(RBC(end, :) - MBC(end, :))
    fprintf("Test FAILED in 1-D case\n");
    return
end

RBC2 = robinBC(k, m, dx, 5, 6);
MBC = mixedBC(k, m, dx, 'Robin', [3, 4], 'Robin', [5, 6]);

if nnz(RBC(1, :) - MBC(1, :)) || nnz(RBC2(end, :) - MBC(end, :))
    fprintf("Test FAILED in 1-D case\n");
    return
end

% 2-D Case
n = 73;
dy = 0.123;
RBC = robinBC2D(k, m, dx, n, dy, 3, 4);
MBC = mixedBC2D(k, m, dx, n, dy, 'Robin', [3, 4], 'Robin', [3, 4], 'Robin', [3, 4], 'Robin', [3, 4]);

if nnz(RBC - MBC)
    fprintf("Test FAILED in 2-D case\n");
    return
end

% 3-D Case
o = 18;
dz = 0.198;
RBC = robinBC3D(k, m, dx, n, dy, o, dz, 6, 7);
MBC = mixedBC3D(k, m, dx, n, dy, o, dz, 'Robin', [6, 7], 'Robin', [6, 7], 'Robin', [6, 7], 'Robin', [6, 7], 'Robin', [6, 7], 'Robin', [6, 7]);

if nnz(RBC - MBC)
    fprintf("Test FAILED in 3-D case\n");
    return
end

fprintf("Test PASSED!\n");
