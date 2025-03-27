# Non-Uniform Gradient and Divergence Operators

> **Author:** Miguel A. Dumett  
> **Date:** 2025-03-23  
> **Abstract:** This document provides formulas for the mimetic difference gradient
> and divergence operators for non-uniform one-dimensional meshes.

---

## Introduction

On an interval $[a,b]$, consider $n$ equal size subintervals, each of
length $h = \frac{b-a}{n}$. 

Then

-   the uniform node grid (with $n+1$ points) is given by

$$X_N^u = \{ a, a+h, \cdots, b-h, b \},$$

-   the uniform center grid (with $n+2$ points) is given by

$$X_C^u = \{ a, a+\frac{h}{2}, a+\frac{3h}{2}, \cdots, b-\frac{3h}{2}, b-\frac{h}{2}, b \}$$

Suppose a non-uniform grid on interval $[a,b]$, with $n$ non-equal
subintervals, is given by

-   the set of $n+1$ nodes of the non-uniform grid,

$$X_N = \{ x_0 = a < x_1 < x_2 < \cdots < x_{n-1} < x_n = b \},$$

-   and the corresponding $n+2$ non-uniform centers,

$$X_C = \{ y_0 = a < y_1 < y_2 < \cdots < y_n < y_{n+1} = b \}, \qquad y_i = (x_i + x_{i-1})/2, \quad i = 1,\cdots,n.$$

Then

1.  In 1D, the non-uniform gradient $G_{nu}$ in terms of the uniform
    gradient $G_u$ is given by
    
    $$G_{nu} = \text{diag}((G_u X_C)^{-1}) \, G_u,$$

2.  and the 1D non-uniform divergence $D_{nu}$ in terms of the uniform
    divergence $D_u$ is given by
    
    $$D_{nu} = \text{diag}((D_u X_N)^{-1}) \, D_u.$$

    Since the first and last rows of $D_u$ are zero then the vector
    $D_u X_N$ will have zeros in its first and last component and hence
    it will not be possible to compute the inverses of both components.
    To avoid these infinity values, one substitutes the first and last
    components of $D_u X_N$ by ones.
