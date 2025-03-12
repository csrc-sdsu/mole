# MATLAB API Documentation

The **MATLAB API** for MOLE provides access to mimetic operators, solvers, and pre-processing routines within MATLAB. This API allows MATLAB users to leverage the computational power of C++-based mimetic operators while working in a familiar MATLAB environment.

## Key Functions

- **Divergence**: Computes the divergence of a vector field.
- **Gradient**: Computes the gradient of a scalar field.
- **Laplacian**: Computes the Laplacian of a field.
- **Boundary Conditions**: Set boundary conditions directly in MATLAB scripts.

## Reference Documentation

The MATLAB API documentation is generated using Doxygen and provides detailed information about all functions, classes, and methods available in the MATLAB interface.

```{eval-rst}
.. note::
   For the complete MATLAB API reference, please visit the :doc:`MATLAB API Reference <matlab_api_full>` page.
```

```{eval-rst}
.. raw:: html

   <a href="../../../../../doc/doxygen/matlab/index.html" class="btn btn-primary btn-lg" style="background-color: #2980b9; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-weight: bold; display: inline-block; margin: 20px 0;" target="_blank" rel="noopener noreferrer">Access MATLAB API Documentation</a>
```

## Usage Examples

### Computing Divergence

```matlab
% Create a 2D grid
nx = 10; ny = 10;
x = linspace(0, 1, nx);
y = linspace(0, 1, ny);

% Create a vector field
[X, Y] = meshgrid(x, y);
u = sin(2*pi*X) .* cos(2*pi*Y);
v = cos(2*pi*X) .* sin(2*pi*Y);

% Compute the divergence
div = divergence(u, v, x, y);
```

### Setting Boundary Conditions

```matlab
% Create a grid
nx = 20; ny = 20;
x = linspace(0, 1, nx);
y = linspace(0, 1, ny);

% Create a Laplacian operator with Dirichlet boundary conditions
L = laplacian2d(nx, ny, 'dirichlet');

% Solve a Poisson equation
f = ones(nx*ny, 1);  % Right-hand side
u = L \ f;           % Solution
```
