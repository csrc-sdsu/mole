# MATLAB/Octave API Documentation

Welcome to the MATLAB/Octave API documentation for the Mimetic Operators Library Enhanced (MOLE). This section provides detailed information about using MOLE from MATLAB.


## Overview

The MOLE MATLAB/Octave API provides the following main components:

### Operators

#### Gradient
- `grad` - 1D gradient (order k)
- `grad2D` - 2D gradient on uniform grid
- `grad3D` - 3D gradient on uniform grid
- `gradNonUniform` - 1D gradient on non-uniform grid
- `grad2DNonUniform` - 2D gradient on non-uniform grid
- `grad3DNonUniform` - 3D gradient on non-uniform grid
- `grad2DCurv` - 2D gradient on curvilinear grid
- `grad3DCurv` - 3D gradient on curvilinear grid

#### Divergence
- `div` - 1D divergence (order k)
- `div2D` - 2D divergence on uniform grid
- `div3D` - 3D divergence on uniform grid
- `divNonUniform` - 1D divergence on non-uniform grid
- `div2DNonUniform` - 2D divergence on non-uniform grid
- `div3DNonUniform` - 3D divergence on non-uniform grid
- `div2DCurv` - 2D divergence on curvilinear grid
- `div3DCurv` - 3D divergence on curvilinear grid

#### Laplacian
- `lap` - 1D Laplacian (order k)
- `lap2D` - 2D Laplacian on uniform grid
- `lap3D` - 3D Laplacian on uniform grid

#### Curl
- `curl2D` - 2D curl operator

#### Interpolation
- `interpol` - 1D interpolation
- `interpol2D` - 2D interpolation
- `interpol3D` - 3D interpolation
- `interpolD`, `interpolD2D`, `interpolD3D` - Dual interpolation variants

### Boundary Conditions

#### Mixed Boundary Conditions
- `mixedbc` - Mixed boundary conditions (Dirichlet, Neumann, Robin)

#### Robin Boundary Conditions
- `robinBC` - 1D Robin boundary conditions
- `robinBC2D` - 2D Robin boundary conditions
- `robinBC3D` - 3D Robin boundary conditions

#### Boundary Operators
- `mimeticB` - Mimetic boundary operator

### Utility Functions

#### Grid Management
- `nodal`, `nodal2D`, `nodal3D` - Nodal operators
- `jacobian2D`, `jacobian3D` - Jacobian calculation
- `gridGen` - Grid generation utility
- `tfi` - Transfinite interpolation for grid generation

#### Weight Functions
- `weightsP`, `weightsP2D` - Weights for the P operator
- `weightsQ`, `weightsQ2D` - Weights for the Q operator

#### Tensor Operations
- `tensorGrad2D` - Tensor gradient in 2D
- `ttm` - Tensor times matrix

#### Integration
- `GI1`, `GI13`, `GI2` - Integration methods
- `DI2`, `DI3` - Divergence integration methods

## Quick Examples

```{literalinclude} ../../../../../examples/matlab/minimal_poisson2D.m
:language: matlab
:linenos:
:caption: Minimal 2D Poisson Example (examples/matlab/minimal_poisson2D.m)
```

## Complete API Reference

### Full MATLAB/Octave API Documentation

Access the complete MATLAB/Octave API documentation with detailed function references:

```{toctree}
:maxdepth: 1

View Full Documentation <matlab_api_full>
```

```{admonition} Performance Tip
:class: tip

For optimal performance, vectorize your operations and use the sparse matrices directly in your MATLAB/Octave code.
```