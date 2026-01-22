function [L2_error, dx, u_num_centers, x_centers] = wave1d_solver(m)
% WAVE1D_SOLVER Solves the 1D Wave Equation using Mimetic Finite Differences.
%
%   formulation: d2u/dt2 = c^2 * div(grad(u))
%   scheme:      Spatial: 2nd Order Mimetic Operators (MOLE library)
%                Temporal: Velocity Verlet (Leapfrog)
%
%   Input:
%       m : Number of cells in the spatial grid.
%
%   Outputs:
%       L2_error      : Discrete L2 norm error against exact solution.
%       dx            : Grid spacing.
%       u_num_centers : Numerical solution vector (interior points).
%       x_centers     : Coordinate vector of cell centers.

    % =========================================================================
    % 1. Physical Parameters and Grid Configuration
    % =========================================================================
    k = 2;              % Spatial order of accuracy
    a = 0; b = 1;       % Domain boundaries [0, 1]
    dx = (b-a)/m;       % Grid spacing
    c = 2;              % Wave speed
    T_final = 0.5;      % Simulation duration

    % Time step setup (CFL condition for stability)
    dt = dx / (4*c);
    Nt = ceil(T_final/dt);
    dt = T_final / Nt;

    % Coordinate system: Cell centers (staggered grid)
    % Used for evaluating initial functions on the interior nodes.
    x_centers = (a + dx/2 : dx : b - dx/2)'; % Column vector of size m

    % =========================================================================
    % 2. Mimetic Operators Setup
    % =========================================================================
    % Initialize Mimetic Laplacian operator
    % Size is (m+2) x (m+2) to accommodate boundary values (ghost points)
    L = lap(k, m, dx);

    % Impose Boundary Conditions on the operator matrix (Dirichlet u=0)
    % This ensures the operator behaves correctly at the edges.
    L(1, :) = 0; L(1, 1) = 1;       % Left boundary (Identity row)
    L(end, :) = 0; L(end, end) = 1; % Right boundary (Identity row)

    % Define the Force Function (RHS)
    % F = c^2 * Laplacian * u
    F_op = @(u) (c^2) * (L * u);

    % =========================================================================
    % 3. Initial Conditions (Augmented Vector)
    % =========================================================================
    % Initialize state vector 'u' with size m+2 (includes boundaries)
    u = zeros(m+2, 1);

    % Populate interior nodes (indices 2 to m+1)
    ICU = @(x) sin(pi*x) + sin(2*pi*x);
    u(2:end-1) = ICU(x_centers);

    % Enforce Boundary Conditions (indices 1 and m+2)
    u(1) = 0;
    u(end) = 0;

    % Initialize velocity vector 'v' (du/dt = 0 initially)
    v = zeros(m+2, 1);

    % =========================================================================
    % 4. Time Integration (Velocity Verlet / Leapfrog)
    % =========================================================================

    % Calculate initial acceleration
    acc = F_op(u);

    % Enforce zero acceleration at boundaries to maintain strict Dirichlet BCs
    acc(1) = 0; acc(end) = 0;

    for t = 1:Nt
        % a) Half-step velocity update
        v = v + 0.5 * dt * acc;

        % b) Full-step position update
        u = u + dt * v;

        % c) Recalculate forces (acceleration) based on new position
        acc = F_op(u);

        acc(1) = 0; acc(end) = 0;

        % d) Full-step velocity update
        v = v + 0.5 * dt * acc;
    end

    % =========================================================================
    % 5. Error Analysis
    % =========================================================================
    % Analytical solution evaluated at cell centers
    u_exact_centers = sin(pi*x_centers)*cos(pi*c*T_final) + ...
                      sin(2*pi*x_centers)*cos(2*pi*c*T_final);

    % Extract the interior of the numerical solution for comparison
    u_num_centers = u(2:end-1);

    % Compute discrete L2 Error Norm
    diff = u_num_centers - u_exact_centers;
    L2_error = sqrt(sum(diff.^2) * dx);
end
