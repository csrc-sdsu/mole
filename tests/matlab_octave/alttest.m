addpath ('../../src/matlab_octave')

west = 0;  % Domain's limits
east = 1;

ks = [2, 4, 6, 8];  % Different orders of accuracy
grid_sizes = [20, 40];  % Grid sizes to test

for k = ks

    errors = zeros(size(grid_sizes));

    for i = 1:numel(grid_sizes)
        m = grid_sizes(i);  % Number of cells
        dx = (east - west) / m;  % Step length

        L = lap(k, m, dx);  % 1D Mimetic Laplacian operator

        % Impose scalar boundary conditions on Laplacian operator
        a = 1;
        b = 1;
        dc = [a; a];
        nc = [b; b];

        % 1D Staggered grid
        grid = [west west+dx/2 : dx : east-dx/2 east];

        % RHS
        U = exp(grid)';
        vbc = [0; 2*exp(1)];
        [L, U] = addScalarBC1D(L, U, k, m, dx, dc, nc, vbc);

        % Solve a linear system of equations
        computed_solution = L\U;

        % Compute error using L2 norm
        analytical_solution = exp(grid);
        errors(i) = max(abs(computed_solution' - analytical_solution))
    end 

    % Compute order of accuracy
    order = zeros(2,1);%zeros(numel(errors) - 1, 1);
    for i = 1:numel(errors)-1
        order(i) = log2(errors(i) / errors(i + 1))

    end
end