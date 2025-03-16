# Operators

MOLE provides a comprehensive set of mimetic operators for numerical computations. These operators are designed to preserve important mathematical properties of the continuous operators they approximate.

## Available Operators

```{toctree}
:maxdepth: 1

gradient
divergence
laplacian
interpol
operators
```

## Operator Properties

The mimetic operators in MOLE are designed to satisfy the following properties:

1. **High-order accuracy**: Operators can achieve arbitrary order of accuracy
2. **Local conservation**: The discrete operators conserve quantities locally
3. **Global conservation**: The discrete operators conserve quantities globally
4. **Mimetic properties**: The discrete operators mimic properties of the continuous operators, such as the adjoint relationship between gradient and divergence

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

For more detailed examples, see the individual operator documentation pages. 