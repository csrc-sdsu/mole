---
title: 'MOLE: Mimetic Operators Library Enhanced'
tags:
  - Mimetic
  - PDE
  - Discrete vector calculus
  - High-order
  - Conservative
authors:
  - name: Johnny Corbino^[Corresponding author.]
    orcid: 0000-0002-2638-9216
    affiliation: 1
  - name: Jose E. Castillo
    affiliation: 1
affiliations:
 - name: Computational Science Research Center, San Diego State University, 5500 Campanile Dr, San Diego, California, 92182.
   index: 1
date: 29 December 2020
bibliography: paper.bib
---

# Summary

MOLE is a high quality (C++ & MATLAB) library that implements high-order mimetic operators to solve partial differential equations. It provides discrete analogs of the most common vector calculus operators: Gradient, Divergence, Laplacian and Curl. These operators (matrices) act on staggered grids (uniform and nonuniform) and they satisfy local and global conservation laws.

The mathematics is based on the work of [@Corbino]. However the user may find useful previous publications such as [@Castillo], in which similar operators are derived using a matrix analysis approach.

# Mimetic operators

All linear transformations can be represented by a matrix multiplication, integration and differentiation are linear transformations. Mimetic operators are essentially matrices that when applied to discrete scalar or vector fields produce high-order approximations that are faithful to the physics.

The basis of higher-dimensional operators, as well of more sophisticated operators such as the Laplacian or the Biharmonic operator are the one-dimensional mimetic gradient and divergence operators.

# The library

MOLE was designed to be an intuitive software package to numerically solve partial differential equations using mimetic methods. MOLE is implemented in C++ and in MATLAB scripting language (these are two independent flavors) and every single function in MOLE returns a sparse matrix of the requested mimetic operator. For information on the installation or usage of the library, please read the [User's Manual](https://github.com/jcorbino/mole/blob/master/MOLE%20User's%20Manual%20(MATLAB%20version).pdf) which is included in the repository.

# References
