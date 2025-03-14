.. _Introduction:

Introduction
**************************************

The Mimetic Operators Library Enhanced (MOLE) is a C++ library that provides high-order mimetic operators for numerical simulations of partial differential equations.

What are Mimetic Operators?
======================================

Mimetic operators are discrete analogs of continuous differential operators that preserve or "mimic" important mathematical and physical properties of the continuous operators. This preservation of properties makes mimetic methods particularly well-suited for solving partial differential equations in complex domains or with complex physics.

Key features of mimetic operators include:

* Conservation of physical quantities
* Preservation of important vector calculus identities (e.g., curl of gradient is zero)
* Support for complex geometries and boundary conditions
* High-order accuracy
* Robust handling of discontinuities

MOLE Library Features
======================================

The MOLE library provides:

* High-order mimetic operators (gradient, divergence, curl, laplacian)
* Support for 1D, 2D, and 3D problems
* Various boundary condition implementations
* Efficient sparse matrix storage and operations
* Utility functions for common tasks 