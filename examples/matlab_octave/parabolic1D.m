% Solves the 1D Heat equation with Dirichlet boundary conditions

clc
close all

addpath('../../src/matlab_octave')

is_Octave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

alpha = 1; % Thermal diffusivity
west = 0; % Domain's limits
east = 1;

k = 2; % Operator's order of accuracy
m = 2*k+1; % Minimum number of cells to attain the desired accuracy
dx = (east-west)/m;

t = 1; % Simulation time
dt = dx^2/(3*alpha); % von Neumann stability criterion for explicit scheme, if k > 2 then /(4*alpha)

L = lap(k, m, dx); % 1D Mimetic laplacian operator

% IC
U = zeros(m+2, 1);
% BC
U(1) = 100;
U(end) = 100;

% 1D Staggered grid
grid = [west west+dx/2: dx :east-dx/2 east];

explicit = 1; % 0 = Implicit scheme

if explicit
    tic
    % Explicit
    L = alpha*dt*L + speye(size(L));
    
    % Time integration loop
    for i = 0 : t/dt+1
        plot(grid, U, 'o-')
        axis([0 1 0 105])
        str = sprintf('Explicit \t t = %.2f', i*dt);
        title(str)
        xlabel('x')
        ylabel('T')
        pause(0.01)
        U = L*U; % Apply the operator
    end
    toc
else
    tic
    % Implicit
    L = -alpha*dt*L + speye(size(L));
    %
    if ( is_Octave )
        dL = L; % no pre-decomposition in Octave.
    else
        % This precomputes the LU decomposition of L and stores it as a
        % decomposition object. Because it's being stored as a decomposition
        % object, MATLAB knows not to bother with LU factorizing L every time we
        % run \, which means that solving the system is sped up. This is 
        % only available in MATLAB.
        dL=decomposition(L);
    end
    %
    for i = 0 : t/dt+1
        plot(grid, U, 'o-')
        axis([0 1 0 105])
        str = sprintf('Implicit \t t = %.2f', i*dt);
        title(str)
        xlabel('x')
        ylabel('T')
        pause(0.01)
        U = dL\U; 
    end
    toc
end
