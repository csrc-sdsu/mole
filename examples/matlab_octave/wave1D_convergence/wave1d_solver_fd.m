function [L2_error, dx, u_num_centers, x_centers] = wave1d_solver_fd(m,dt)
% WAVE1D_SOLVER_FD Solves the 1D Wave Equation using Standard Finite Differences.
%
%   formulation: d2u/dt2 = c^2 * d2u/dx2
%   scheme:      Spatial: Standard Central Differences (3-point stencil)
%                Temporal: Velocity Verlet (Leapfrog)
%   context:     Acts as a baseline to validate/compare Mimetic methods.
%
%   Input:
%       m : Number of cells in the spatial grid.
%
%   Outputs:
%       L2_error      : Discrete L2 norm error against exact solution.
%       dx            : Grid spacing.
%       u_num : Numerical solution vector
%

    % =========================================================================
    % 1. Physical Parameters and Grid Configuration
    % =========================================================================
    a = 0; b = 1;       % Domain boundaries
    dx = (b-a)/m;       % Grid spacing
    c = 2;              % Wave speed
    T_final = 0.5;      % Simulation duration
    Nt = ceil(T_final/dt);
    % Comparison: Mimetic uses m cells. FD uses m+2 nodes to cover same domain.
    N = m + 2;
    x_nodes = linspace(a, b, N)';
    dx = x_nodes(2) - x_nodes(1); % Exact nodal spacing

    % =========================================================================
    % 2. Standard Finite Difference Operator (Tridiagonal Matrix)
    % =========================================================================

    e = ones(N, 1);

    % Construct sparse tridiagonal matrix with diagonals [1, -2, 1]
    % -1: Lower diagonal
    %  0: Main diagonal
    % +1: Upper diagonal
    L = spdiags([e -2*e e], -1:1, N, N);
    L = L / dx^2;

    % Boundary Conditions (Explicit Dirichlet u=0)
    % We zero out the first and last rows to prevent the stencil from
    % evolving the boundary nodes. They remain fixed at 0.
    L(1, :) = 0; L(1, 1) = 0;
    L(end, :) = 0; L(end, end) = 0;

    % Define the Force Function (RHS)
    F_op = @(u) (c^2) * (L * u);

    % =========================================================================
    % 3. Initial Conditions
    % =========================================================================
    u = zeros(N, 1);

    % Initialize interior points
    ICU = @(x) sin(pi*x) + sin(2*pi*x);
    u = ICU(x_nodes);

    % Initialize velocity (du/dt = 0)
    v = zeros(N, 1);

    % =========================================================================
    % 4. Time Integration (Velocity Verlet)
    % =========================================================================
    acc = F_op(u);

    for t = 1:Nt
        % a) Half-step velocity update
        v = v + 0.5 * dt * acc;

        % b) Full-step position update
        u = u + dt * v;

        % c) Recalculate acceleration
        acc = F_op(u);

        % d) Full-step velocity update
        v = v + 0.5 * dt * acc;
    end

    % =========================================================================
    % 5. Error Analysis
    % =========================================================================
    % Analytical solution evaluated at nodes
    u_exact_all = sin(pi*x_nodes)*cos(pi*c*T_final) + sin(2*pi*x_nodes)*cos(2*pi*c*T_final);

    u_num_internal = u(2:end-1);
    u_exact_internal = u_exact_all(2:end-1);

    diff = u_num_internal - u_exact_internal;
    L2_error = sqrt(sum(diff.^2) * dx);
end
