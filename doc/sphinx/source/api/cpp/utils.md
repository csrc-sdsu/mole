# Utilities

MOLE provides a set of utility functions and classes to simplify common tasks when working with mimetic operators and boundary conditions.

<!-- ### Mathematical Background -->

<!-- TODO: Add mathematical background and principles where applicable -->

### API Reference

```{doxygenclass} Utils
:project: MoleCpp
:members:
:undoc-members:
```

## Usage Examples

Here's a simple example of using utility functions:

```cpp
// Create a uniform grid with 100 points from 0 to 1
auto grid = Utils::createUniformGrid(0.0, 1.0, 100);

// Create a non-uniform grid with clustering near boundaries
auto clusteredGrid = Utils::createClusteredGrid(0.0, 1.0, 100, 2.0);

// Compute the integral of a function over a grid
vec values(100);
// ... fill values with function evaluations ...
double integral = Utils::integrate(values, grid);
```

<!-- ## Notes and Considerations -->

<!-- TODO: Add important notes and considerations for using these utilities --> 