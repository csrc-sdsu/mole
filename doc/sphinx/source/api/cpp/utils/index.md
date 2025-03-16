# Utilities

MOLE provides a set of utility functions and classes to simplify common tasks when working with mimetic operators and boundary conditions.

## Available Utilities

```{toctree}
:maxdepth: 1

utils
```

## Overview

The utilities module contains helper functions for:

1. **Grid Management**: Functions for creating and manipulating computational grids
2. **Linear Algebra**: Specialized linear algebra operations optimized for mimetic operators
3. **Data Structures**: Efficient data structures for handling multi-dimensional data
4. **I/O Operations**: Functions for reading and writing data

## Key Features

- **Efficiency**: Optimized implementations for common operations
- **Ease of use**: Simplified interfaces for complex tasks
- **Integration**: Seamless integration with the rest of the MOLE library

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

For more detailed examples, see the individual utility documentation pages. 