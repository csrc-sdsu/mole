### Elliptic1D Non-Homogenous Dirichlet Boundary Conditions

Solves the 1D Poisson equation with non-homogeneous Dirichlet boundary conditions.

$$
-\nabla^2 u(x) = 1
$$

with $x\in[0,1]$. The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

with 

$$
1u(0) + 0\frac{du(0)}{dx} = \frac{1}{2}
$$

$$
1u(1) + 0\frac{du(1)}{dx} = \frac{1}{2}
$$

This corresponds to the call to addScalarBC1D of `addScalarBC1D(A,b,k,m,dx,dc,nc,v)`, where `dc`, `nc`, and `vc` are vectors which hold the coefficients for $a$, $b$, and $g$ in the above system of equations. $a=[1,1]$, $b=[0,0]$ and $g=[1/2, 1/2]$. Substituting these values in gives:

$$
u(0) = \frac{1}{2}
$$ 

$$
u(1) = \frac{1}{2}
$$

The true solution is

$$
u(x) = \frac{-x^2 + x + 1}{2}
$$
---

This example is implemented in:
- [MATLAB/ OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonHomogeneousDirichlet.m)

Additional MATLAB/ OCTAVE variants of this example with different boundary conditions:
- [Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DHomogeneousDirichlet.m)
- [Left Dirichlet, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightNeumann.m)
- [Left Dirichlet, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightRobin.m)
- [Left Neumann, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightNeumann.m)
- [Left Neumann, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightRobin.m)
- [Left Robin, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftRobinRightRobin.m)
- [Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DPeriodicBC.m)
- [Non-Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonPeriodicBC.m)
