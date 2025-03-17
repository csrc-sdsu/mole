# Boundary Conditions

MOLE supports a variety of boundary conditions for solving PDEs with different physical constraints.

## Mixed Boundary Conditions

The MixedBC class implements mixed boundary conditions in the MOLE library.

<!-- ### Mathematical Background -->

<!-- TODO: Add mathematical background, principles, and mimetic properties -->

### API Reference

```{doxygenclass} MixedBC
:project: MoleCpp
:members:
:undoc-members:
```

## Robin Boundary Conditions

The RobinBC class implements Robin boundary conditions in the MOLE library.

<!-- ### Mathematical Background -->

<!-- TODO: Add mathematical background, principles, and mimetic properties -->

### API Reference

```{doxygenclass} RobinBC
:project: MoleCpp
:members:
:undoc-members:
```

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

```{admonition} Importance of Boundary Conditions
:class: important
Boundary conditions are critical for ensuring that differential equation solutions are unique and physically meaningful. They specify constraints at the boundaries of the computational domain.
```

<!-- ## Notes and Considerations -->

<!-- TODO: Add important notes and considerations for using these boundary conditions --> 