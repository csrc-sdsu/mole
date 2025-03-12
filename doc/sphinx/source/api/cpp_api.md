# C++ API Documentation

The **MOLE C++ API** provides low-level access to the mimetic operators and boundary condition functions. This section describes the core classes, functions, and examples for utilizing the API in your C++ applications.

## Overview

MOLE's C++ API is organized into several key components:

- **Operators**: Core mimetic operators for numerical computations
- **Boundary Conditions**: Tools for managing boundary conditions
- **Utilities**: Helper functions and utilities
- **Examples**: Usage examples and tutorials

## API Components

```{toctree}
:maxdepth: 2
:caption: C++ API Reference

cpp/operators.md
cpp/boundary_conditions.md
cpp/utilities.md
cpp/examples.md
```

## Complete Class Reference

For a complete reference of all classes and functions in the MOLE C++ API, see the alphabetical class listing below:

```{eval-rst}
.. doxygenindex::
   :project: MoleCpp
```

## Operator Classes

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Class
     - Description
   * - :cpp:class:`Divergence`
     - Computes the divergence of a vector field
   * - :cpp:class:`Gradient`
     - Computes the gradient of a scalar field
   * - :cpp:class:`Laplacian`
     - Computes the Laplacian of a field
   * - :cpp:class:`Interpol`
     - Performs interpolation operations
```

## Boundary Condition Classes

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Class
     - Description
   * - :cpp:class:`RobinBC`
     - Implements Robin boundary conditions
   * - :cpp:class:`MixedBC`
     - Implements mixed boundary conditions
```

## Utility Classes

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Class
     - Description
   * - :cpp:class:`Utils`
     - Provides utility functions for numerical operations
``` 