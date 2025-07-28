# Getting Started

Welcome to the getting started guide for MOLE (Mimetic Operators Library Enhanced). This guide will help you set up and run your first MOLE project.

```{include} ../../../../README.md
:start-after: "## Installation"
:end-before: "## Documentation"
:name: installation-and-examples+test-section-include
```

## Quick Start Examples

Here are some simple examples to help you get started with MOLE:

:::::{tab-set}

::::{tab-item} C++
```cpp
// transport1D.cpp - 1D advection-reaction-dispersion equation

#include "mole.h"
#include <iostream>

int main() {
  int k = 2;             // Operators' order of accuracy
  Real a = 0;            // Left boundary
  Real b = 130;          // Right boundary
  int m = 26;            // Number of cells
  Real dx = (b - a) / m; // Cell's width [m]
  
  // Get 1D mimetic operators
  Gradient G(k, m, dx);
  Divergence D(k, m, dx);
  Interpol I(m, 0.5);

  // Allocate fields
  vec C(m + 2); // Scalar field (concentrations)
  vec V(m + 1); // Vector field (velocities)

  // Time integration loop (simplified)
  for (int i = 0; i <= iter; i++) {
    // First-order forward-time scheme
    C += dt * (D * (dis * (G * C)) - D * (V % (I * C)));
  }

  cout << C;
  return 0;
}
```
::::

::::{tab-item} MATLAB/Octave
```matlab
% elliptic1D.m - 1D Poisson's equation with Robin boundary conditions

addpath('../../src/matlab_octave')

west = 0;  % Domain's limits
east = 1;

k = 6;     % Operator's order of accuracy
m = 2*k+1; % Minimum number of cells for desired accuracy
dx = (east-west)/m;  % Step length

L = lap(k, m, dx);  % 1D Mimetic laplacian operator

% Impose Robin BC on laplacian operator
a = 1;
b = 1;
L = L + robinBC(k, m, dx, a, b);

% 1D Staggered grid
grid = [west west+dx/2 : dx : east-dx/2 east];

% RHS
U = exp(grid)';
U(1) = 0;      % West BC
U(end) = 2*exp(1);  % East BC

U = L\U;  % Solve a linear system of equations

% Plot result
plot(grid, U, 'o')
hold on
plot(grid, exp(grid))
```
::::

:::::

For full examples, see:
- C++: [transport1D.cpp](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/transport1D.cpp)
- MATLAB: [elliptic1D.m](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1D.m)

## Next Steps

- Check out more C++ examples in the [examples/cpp/](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp) directory
- Explore the MATLAB/Octave examples in the [examples/matlab/](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab) directory
- Join our community and [contribute](https://github.com/csrc-sdsu/mole/blob/main/CONTRIBUTING.md)

```{include} ../../../../README.md
:start-after: "**Important Note:**"
:end-before: "## Community Guidelines"
:name: note-section-include
``` 
