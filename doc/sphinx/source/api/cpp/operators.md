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

### Transport Example (Gradient & Divergence)
```{literalinclude} ../../../../../examples/cpp/transport1D.cpp
:language: cpp
:linenos:
:caption: Transport 1D Example using Gradient and Divergence (examples/cpp/transport1D.cpp)
```

### Elliptic Example (Laplacian)
```{literalinclude} ../../../../../examples/cpp/elliptic2D.cpp
:language: cpp
:linenos:
:caption: Elliptic 2D Example using Laplacian (examples/cpp/elliptic2D.cpp)
```

### Schrödinger Example (Complex Operators)
```{literalinclude} ../../../../../examples/cpp/schrodinger1D.cpp
:language: cpp
:linenos:
:caption: Schrödinger 1D Example (examples/cpp/schrodinger1D.cpp)
```

## Notes and Considerations

<!-- TODO: Add important notes and considerations for using these operators --> 
