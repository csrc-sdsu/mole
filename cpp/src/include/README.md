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

# Include subdirectory for MOLE 2.0.0 C++ support system files

Subdirectory and Pathname: **mole/cpp/src/sys**

## Purpose

All header files (.h) for the different MOLE 2.0 C++ functionality
are contain in this directory. MOLE examples and tests have their own
include subdirectories.
Header files contain public declarations of the MOLE C++ API, which
is the MOLE collection of functionalities available to MOLE users.

## MOLE Modules and Header Files (alphabetical order)

+ **flat2DArray.h**: a flat 2D double array implementation
+ **flat3DArray.h**: a flat 3D double array implementation
+ **MOLE_Errors.h**: a MOLE error handling, tracking and reporting
mechanism for the library. Users have full control on how to handle
exceptions, the MOLE library only reports them and does not cause an
application's execution to stop.
+ **MOLE_grids.h**: MOLE grid classes implementation, including error
handling and reporting
