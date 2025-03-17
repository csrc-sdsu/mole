# MATLAB API Documentation

Welcome to the MATLAB API documentation for the Mimetic Operators Library Enhanced (MOLE). This section provides detailed information about using MOLE from MATLAB.

```{admonition} MATLAB Integration
:class: note
MOLE provides a complete MATLAB interface that allows you to use all the mimetic operators directly from your MATLAB scripts and functions.
```

## Overview

```{mermaid}
graph TD
    User[MATLAB User Code] -->|calls| OP[MOLE Operators]
    OP --> G["Gradient (grad, grad2D, grad3D)"]
    OP --> D["Divergence (div, div2D, div3D)"]
    OP --> L["Laplacian (lap, lap2D, lap3D)"]
    OP --> I["Interpolation (interpol, interpol2D, interpol3D)"]
    OP --> C["Curvilinear (grad2DCurv, div2DCurv)"]
    User -->|applies| BC[Boundary Conditions]
    BC --> M["Mixed BC (mixedbc)"]
    BC --> R["Robin BC (robinBC, robinBC2D, robinBC3D)"]
    User -->|utilizes| U[Utility Functions]
    U --> W["Weights (weightsP, weightsQ)"]
    U --> N["Nodal (nodal, nodal2D, nodal3D)"]
    U --> J["Jacobian (jacobian2D, jacobian3D)"]
    U --> G2["Grid Generation (gridGen, tfi)"]
```

## Components

<div class="component-box">
<h3>Operators</h3>
<ul>
<li><strong>Gradient</strong>: 
  <ul>
    <li><code>grad</code> - 1D gradient (order k)</li>
    <li><code>grad2D</code> - 2D gradient on uniform grid</li>
    <li><code>grad3D</code> - 3D gradient on uniform grid</li>
    <li><code>gradNonUniform</code> - 1D gradient on non-uniform grid</li>
    <li><code>grad2DNonUniform</code> - 2D gradient on non-uniform grid</li>
    <li><code>grad3DNonUniform</code> - 3D gradient on non-uniform grid</li>
    <li><code>grad2DCurv</code> - 2D gradient on curvilinear grid</li>
    <li><code>grad3DCurv</code> - 3D gradient on curvilinear grid</li>
  </ul>
</li>
<li><strong>Divergence</strong>: 
  <ul>
    <li><code>div</code> - 1D divergence (order k)</li>
    <li><code>div2D</code> - 2D divergence on uniform grid</li>
    <li><code>div3D</code> - 3D divergence on uniform grid</li>
    <li><code>divNonUniform</code> - 1D divergence on non-uniform grid</li>
    <li><code>div2DNonUniform</code> - 2D divergence on non-uniform grid</li>
    <li><code>div3DNonUniform</code> - 3D divergence on non-uniform grid</li>
    <li><code>div2DCurv</code> - 2D divergence on curvilinear grid</li>
    <li><code>div3DCurv</code> - 3D divergence on curvilinear grid</li>
  </ul>
</li>
<li><strong>Laplacian</strong>: 
  <ul>
    <li><code>lap</code> - 1D Laplacian (order k)</li>
    <li><code>lap2D</code> - 2D Laplacian on uniform grid</li>
    <li><code>lap3D</code> - 3D Laplacian on uniform grid</li>
  </ul>
</li>
<li><strong>Curl</strong>: 
  <ul>
    <li><code>curl2D</code> - 2D curl operator</li>
  </ul>
</li>
<li><strong>Interpolation</strong>: 
  <ul>
    <li><code>interpol</code> - 1D interpolation</li>
    <li><code>interpol2D</code> - 2D interpolation</li>
    <li><code>interpol3D</code> - 3D interpolation</li>
    <li><code>interpolD</code>, <code>interpolD2D</code>, <code>interpolD3D</code> - Dual interpolation variants</li>
  </ul>
</li>
</ul>
</div>

<div class="component-box">
<h3>Boundary Conditions</h3>
<ul>
<li><strong>Mixed Boundary Conditions</strong>: 
  <ul>
    <li><code>mixedbc</code> - Mixed boundary conditions (Dirichlet, Neumann, Robin)</li>
  </ul>
</li>
<li><strong>Robin Boundary Conditions</strong>: 
  <ul>
    <li><code>robinBC</code> - 1D Robin boundary conditions</li>
    <li><code>robinBC2D</code> - 2D Robin boundary conditions</li>
    <li><code>robinBC3D</code> - 3D Robin boundary conditions</li>
  </ul>
</li>
<li><strong>Boundary Operators</strong>: 
  <ul>
    <li><code>mimeticB</code> - Mimetic boundary operator</li>
  </ul>
</li>
</ul>
</div>

<div class="component-box">
<h3>Utility Functions</h3>
<ul>
<li><strong>Grid Management</strong>: 
  <ul>
    <li><code>nodal</code>, <code>nodal2D</code>, <code>nodal3D</code> - Nodal operators</li>
    <li><code>jacobian2D</code>, <code>jacobian3D</code> - Jacobian calculation</li>
    <li><code>gridGen</code> - Grid generation utility</li>
    <li><code>tfi</code> - Transfinite interpolation for grid generation</li>
  </ul>
</li>
<li><strong>Weight Functions</strong>: 
  <ul>
    <li><code>weightsP</code>, <code>weightsP2D</code> - Weights for the P operator</li>
    <li><code>weightsQ</code>, <code>weightsQ2D</code> - Weights for the Q operator</li>
  </ul>
</li>
<li><strong>Tensor Operations</strong>: 
  <ul>
    <li><code>tensorGrad2D</code> - Tensor gradient in 2D</li>
    <li><code>ttm</code> - Tensor times matrix</li>
  </ul>
</li>
<li><strong>Integration</strong>: 
  <ul>
    <li><code>GI1</code>, <code>GI13</code>, <code>GI2</code> - Integration methods</li>
    <li><code>DI2</code>, <code>DI3</code> - Divergence integration methods</li>
  </ul>
</li>
</ul>
</div>

## Quick Examples

```matlab
% 2D Poisson equation with mixed boundary conditions
% Set up the grid
m = 50; n = 50;
dx = 1/(m-1); dy = 1/(n-1);
k = 4;  % 4th order accuracy

% Create the Laplacian operator
L = lap2D(k, m, dx, n, dy);

% Define boundary conditions
% Dirichlet on left and right, Neumann on top and bottom
left = 'Dirichlet'; coeffs_left = [1];
right = 'Dirichlet'; coeffs_right = [1];
bottom = 'Neumann'; coeffs_bottom = [0];
top = 'Neumann'; coeffs_top = [0];

% Create boundary operator
BC = mixedbc(k, m, n, dx, dy, left, coeffs_left, right, coeffs_right, ...
              bottom, coeffs_bottom, top, coeffs_top);

% Create right-hand side
f = ones(m*n, 1);
b = -f;

% Solve the system
A = L + BC;
u = A\b;

% Reshape and visualize
U = reshape(u, m, n);
surf(U);
```

## Complete API Reference

<div class="component-box" style="text-align: center;">
<h3>Full MATLAB API Documentation</h3>
<p>Access the complete MATLAB API documentation with detailed function references</p>
<a href="matlab_api_full.html" class="btn btn-primary">View Full Documentation</a></div>

```{toctree}
:maxdepth: 1

matlab_api_full
```

```{admonition} Advanced Usage
:class: tip
For optimal performance, vectorize your operations and use the sparse matrices directly in your MATLAB code.
``` 