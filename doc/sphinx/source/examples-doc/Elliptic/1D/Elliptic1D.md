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
- [MATLAB](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1D.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/Elliptic/1D/elliptic1D.cpp)

Additional MATLAB variants of this example with different boundary conditions:
- [Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DHomogeneousDirichlet.m)
- [Non-Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DNonHomogeneousDirichlet.m)
- [Left Dirichlet, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DLeftDirichletRightNeumann.m)
- [Left Dirichlet, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DLeftDirichletRightRobin.m)
- [Left Neumann, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DLeftNeumannRightNeumann.m)
- [Left Neumann, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DLeftNeumannRightRobin.m)
- [Left Robin, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DLeftRobinRightRobin.m)
- [Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DPeriodicBC.m)
- [Non-Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/Elliptic/1D/elliptic1DNonPeriodicBC.m)