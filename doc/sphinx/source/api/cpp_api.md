# C++ API Documentation

The **MOLE C++ API** provides low-level access to the mimetic operators and boundary condition functions. This section describes the core classes, functions, and examples for utilizing the API in your C++ applications.

## Overview

MOLE's C++ API is organized into several key components:

- **Operators**: Core mimetic operators for numerical computations
- **Boundary Conditions**: Tools for managing boundary conditions
- **Utilities**: Helper functions and utilities
- **Examples**: Usage examples and tutorials

The library provides a set of mimetic operators that preserve important mathematical properties of the continuous operators they approximate. These operators can be used to solve various partial differential equations (PDEs) with high accuracy.

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