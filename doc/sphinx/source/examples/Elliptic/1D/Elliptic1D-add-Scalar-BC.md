### Elliptic1D Add Scalar Boundary Conditions

Solves the 1D Poisson equation with Robin boundary conditions. This is the exact same problem as [elliptic1D.m](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1D.m), with `addScalarBC1D` used instead of `addRobinBC`. The equation to solve is

$$
-\nabla^2 u(x) = e^x
$$

with $x\in[0,1]$. The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

with 

$$
1u(0) + 1\frac{du(0)}{dx} = 0
$$

$$
1u(1) + 1\frac{du(1)}{dx} = 2e
$$

This corresponds to the call to addScalarBC1D of `addScalarBC1D(A,b,k,m,dx,dc,nc,v)`, where `dc`, `nc`, and `vc` are vectors which hold the coefficients for $a$, $b$, and $g$ in the above system of equations. $a=[1,1]$, $b=[1,1]$ and $g=[0,2e]$. Substituting these values in gives:

$$
u(0) +\frac{du(0)}{dx} = 0
$$ 

$$
u(1) + \frac{du(1)}{dx} = 2e
$$

The key difference is the implementation of the boundary condition operators. In [elliptic1D](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1D.m), the RHS of the Robin operator is included on lines 26-28, yet in this example, the boundary conditions are set via the `addScalarBC1D` operator.

The true solution is

$$
u(x) = e^x
$$
---

This example is implemented in:
- [MATLAB/ OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DaddScalarBC.m)

Additional MATLAB/ OCTAVE variants of this example with different boundary conditions:
- [Non-Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonHomogeneousDirichlet.m)
- [Left Dirichlet, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightNeumann.m)
- [Left Dirichlet, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightRobin.m)
- [Left Neumann, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightNeumann.m)
- [Left Neumann, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightRobin.m)
- [Left Robin, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftRobinRightRobin.m)
- [Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DPeriodicBC.m)
- [Non-Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonPeriodicBC.m)
