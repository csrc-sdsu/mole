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
 - name: Computational Science Research Center, San Diego State University, San Diego State University, 5500 Campanile Dr, San Diego, California, 92182
   index: 1
date: 29 December 2020
bibliography: paper.bib
---

# Summary

MOLE is a high quality (C++ & MATLAB) library that implements high-order mimetic operators to solve partial differential equations. It provides discrete analogs of the most common vector calculus operators: Gradient, Divergence, Laplacian and Curl. These operators (matrices) act on staggered grids (uniform and nonuniform) and they satisfy local and global conservation laws.

The mathematics is based on the work of [@Corbino]. However the user may find useful previous publications such as [@Castillo], in which similar operators are derived using a matrix analysis approach.

# References
