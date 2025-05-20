### Elliptic1D

Solves the 1D Poisson equation with Robin boundary conditions.

$$
\nabla^2 u(x) = f(x)
$$

with $x\in[0,1]$, and $f(x) =e^x$. The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

with $a=1$, $b=1$, and $g=0$, and

$$
au(0) + b\frac{du(0)}{dx} = 0
$$

$$
au(1) + b\frac{du(1)}{dx} = 2e
$$

This corresponds to the call to robinBC2D of `robinBC2D(k, m, dx, a, b)`.

---

This example is implemented in:
- [MATLAB](../../../examples/matlab/elliptic1D.m)
- [C++](../../../examples/cpp/elliptic1D.cpp)

Additional MATLAB variants of this example with different boundary conditions:
- [Homogeneous Dirichlet](../../../../../../examples/matlab/elliptic1DHomogeneousDirichlet.m)
- [Non-Homogeneous Dirichlet](../../../../../../examples/matlab/elliptic1DNonHomogeneousDirichlet.m)
- [Left Dirichlet, Right Neumann](../../../../../../examples/matlab/elliptic1DLeftDirichletRightNeumann.m)
- [Left Dirichlet, Right Robin](../../../../../../examples/matlab/elliptic1DLeftDirichletRightRobin.m)
- [Left Neumann, Right Neumann](../../../../../../examples/matlab/elliptic1DLeftNeumannRightNeumann.m)
- [Left Neumann, Right Robin]../../../../../../examples/matlab/elliptic1DLeftNeumannRightRobin.m)
- [Left Robin, Right Robin](../../../../../../examples/matlab/elliptic1DLeftRobinRightRobin.m)
- [Periodic Boundary Conditions](../../../../../../examples/matlab/elliptic1DPeriodicBC.m)
- [Non-Periodic Boundary Conditions](../../../../../../examples/matlab/elliptic1DNonPeriodicBC.m)