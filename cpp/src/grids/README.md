<!--
====================================================================
=                       MOLE 2.0 - C++                         =
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

# Subdirectory for MOLE 2.0 C++ grid classes and their functionality

Subdirectory and Pathname: **mole/cpp/src/grids/**

## Purpose

Subdirectory containing source implementations of MOLE grid classes
and member functions, also flat 2D and 3D arrays to avoid the
construction of multidimensional arrays using the C++ vector class.

## List of Files in This Subdirectory (in alphabetical order)

+ **flat2DArray.cpp**: a C++ implementation of flat 2D array class
+ **flat3DArray.cpp**: a C++ implementation of flat 3D array class
+ **MOLE_grids.cpp**: C++ implementation of MOLE 1D, 2D, and 3D grid
classes. It also contains data structures that support the classes, 
and custom wrappers to the MOLE error handling mechanisms.
+ **README.md**: (this file)
