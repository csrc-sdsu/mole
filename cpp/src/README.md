<!--
====================================================================
=                           MOLE 2.0 - C++                         =
====================================================================
 SPDX-License-Identifier: GPL-3.0-or-later
 Copyright (c) 2008-2024 San Diego State University Research 
 Foundation (SDSURF).
 See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
--------------------------------------------------------------------
File created: 06-24-2026
====================================================================


 -->

# Subdirectory of Source Files for the MOLE 2.0 C++ Implementation

Subdirectory and Pathname: **mole/cpp/src**

## Purpose

This is the top subdirectory for the MOLE 2.0 C++ files containing
the source code implementations of MOLE's core functionalities. The
declarations of public functions implemented in this subdirectory are
in a header files inside the mole/cpp/src/include subdirectory.

## Structure of the MOLE C++ 2.0 Source Implementations' Subdirectory

```text
mole/
├── cpp/
|   │── src
|   │   ├── boundaries
|   │   └── grids
|   │   └── operators
|   │   └── sys
|   |   └── time_integrators
|   │   └── utils
```

## MOLE 2.0 C++ Files and Subdirectories in this subdirectory

+ subdirectory **grids**: contains functional implementations of the
 MOLE grids classes and required data structures.
+ subdirectory **operators**: contains functional implementations of
the MOLE operators, including grid interpolators.
+ subdirectory **sys**: contains functional implementations of MOLE
computational support like the error handling mechanisms
+ file **README.md** this file
