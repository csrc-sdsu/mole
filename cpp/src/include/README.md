<!--
====================================================================
=                       MOLE v 2.0.0 - C++                         =
====================================================================
 SPDX-License-Identifier: GPL-3.0-or-later
 Copyright (c) 2008-2024 San Diego State University Research 
 Foundation (SDSURF).
 See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for 
 details.
--------------------------------------------------------------------
File created: 06-24-2026
====================================================================
 -->

# Subdirectory for MOLE 2.0 C++ Header Files

Subdirectory and Pathname: **mole/cpp/src/include**

## Purpose

All header files (.h) for the different MOLE 2.0 C++ functionality
are contain in this directory. MOLE examples and tests have their own
include subdirectories.

Header files contain public declarations of the MOLE C++ API, which
is the MOLE collection of functionalities available to MOLE users.

## MOLE Modules and Header Files (alphabetical order)

+ **MOLE_arrays.h**: MOLE arrays that interface with data structures
from other numerical libraries. The current implementation works with
Armadillo's matrices, vectors and cubes.
+ **MOLE_errors.h**: a MOLE error handling, tracking and reporting
mechanism for the library. Users have full control on how to handle
exceptions, the MOLE library only reports them and does not cause an
application's execution to stop.
+ **MOLE_grids.h**: MOLE grid classes implementation, including error
handling and reportingo
+ **README.md**: (this file)
+ **utilis.h**: header file for all MOLE utility functions, which
include implementations that support the MOLE library operations.
