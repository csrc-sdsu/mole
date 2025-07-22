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

### Elliptic Problem with Mixed Boundary Conditions
```{literalinclude} ../../../../../examples/cpp/elliptic1D.cpp
:language: cpp
:linenos:
:caption: Elliptic 1D Example with Mixed Boundary Conditions (examples/cpp/elliptic1D.cpp)
```

### Complex Problem with Advanced Boundary Handling
```{literalinclude} ../../../../../examples/cpp/convection_diffusion3D.cpp
:language: cpp
:linenos:
:caption: 3D Convection-Diffusion Example with Complex Boundary Conditions (examples/cpp/convection_diffusion3D.cpp)
```

```{admonition} Importance of Boundary Conditions
:class: important
Boundary conditions are critical for ensuring that differential equation solutions are unique and physically meaningful. They specify constraints at the boundaries of the computational domain.
```

<!-- ## Notes and Considerations -->

<!-- TODO: Add important notes and considerations for using these boundary conditions --> 
