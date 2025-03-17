# Operators

MOLE provides a comprehensive set of mimetic operators for numerical computations. These operators are designed to preserve important mathematical properties of the continuous operators they approximate.

## Gradient Operator

The Gradient operator computes the gradient of a scalar field in the MOLE library.

<!-- ### Mathematical Background -->

<!-- TODO: Add mathematical background, principles, and mimetic properties -->

### API Reference

```{doxygenclass} Gradient
:project: MoleCpp
:members:
:undoc-members:
```

## Divergence Operator

The Divergence operator computes the divergence of a vector field in the MOLE library.

<!-- ### Mathematical Background -->

<!-- TODO: Add mathematical background, principles, and mimetic properties -->

### API Reference

```{doxygenclass} Divergence
:project: MoleCpp
:members:
:undoc-members:
```

## Laplacian Operator

The Laplacian operator computes the Laplacian of a scalar field in the MOLE library.

<!-- ### Mathematical Background -->

<!-- TODO: Add mathematical background, principles, and mimetic properties -->

### API Reference

```{doxygenclass} Laplacian
:project: MoleCpp
:members:
:undoc-members:
```

## Interpolation Operator

The Interpol class performs interpolation operations in the MOLE library.

<!-- ### Mathematical Background -->

<!-- TODO: Add mathematical background, principles, and mimetic properties -->

### API Reference

```{doxygenclass} Interpol
:project: MoleCpp
:members:
:undoc-members:
```

## Usage Examples

The operators can be used in various ways:

```cpp
// Create a 4th order accurate 1D gradient operator with 50 grid points and step size 0.1
Gradient G(4, 50, 0.1);

// Create a vector to operate on
vec u(50);
// ... fill u with values ...

// Apply the gradient operator
vec grad_u = G * u;

// Create a 4th order accurate 2D Laplacian operator
Laplacian L(4, 50, 0.1, 50, 0.1);

// Apply the Laplacian operator
vec lap_u = L * u;
```

## Notes and Considerations

<!-- TODO: Add important notes and considerations for using these operators --> 