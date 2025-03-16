# Boundary Conditions

MOLE supports a variety of boundary conditions for solving PDEs with different physical constraints.

## Available Boundary Conditions

```{toctree}
:maxdepth: 1

mixedbc
robinbc
```

## Overview

Boundary conditions are essential for properly defining and solving partial differential equations. MOLE provides several types of boundary conditions that can be easily applied to differential operators.

### Key Features

- **Flexible boundary specification**: Apply different boundary types at each boundary
- **High-order accuracy**: Boundary conditions maintain the order of accuracy of the operators
- **Easy integration with operators**: Simple interface for applying boundary conditions

## Usage Examples

Here's a simple example of applying mixed boundary conditions to a Laplacian operator:

```cpp
// Create a 4th order accurate 2D Laplacian operator
Laplacian L(4, 50, 0.1, 50, 0.1);

// Create mixed boundary conditions
MixedBC bc;

// Set Dirichlet boundary condition at the left boundary (x=0)
bc.setLeftDirichlet();

// Set Neumann boundary condition at the right boundary (x=1)
bc.setRightNeumann();

// Set Dirichlet boundary condition at the bottom boundary (y=0)
bc.setBottomDirichlet();

// Set Neumann boundary condition at the top boundary (y=1)
bc.setTopNeumann();

// Apply boundary conditions to the Laplacian operator
L.setBC(bc);
```

For more detailed examples, see the individual boundary condition documentation pages.

```{admonition} Importance of Boundary Conditions
:class: important
Boundary conditions are critical for ensuring that differential equation solutions are unique and physically meaningful. They specify constraints at the boundaries of the computational domain.
```

## Common Features

All boundary condition implementations in MOLE:

* **High-order accuracy**: Maintain the same order of accuracy as the operators
* **Mimetic properties preservation**: Respect conservation laws at boundaries
* **Flexible specification**: Support for different conditions at different boundaries
* **Seamless integration**: Work directly with the mimetic operators 