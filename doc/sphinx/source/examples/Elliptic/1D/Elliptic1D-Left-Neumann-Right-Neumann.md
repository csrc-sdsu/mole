### Elliptic1D Pure Neumann Boundary Conditions

Solves the 1D Poisson boundary value problem with Neumann boundary conditions.

$$
-\nabla^2 u(x) = x - \frac{1}{2}
$$

with $x\in[0,1]$.

The boundary conditions are given by

$$
au + b\frac{du}{dx} = g
$$

with the left hand side boundary condition (Neumann) satisfying

$$
0u(0) + 1\frac{du(0)}{dx} = 0
$$

and the right hand boundary condition (Neumann) satisfying

$$
0u(1) + 1\frac{du(1)}{dx} = 0
$$

This corresponds to the call to addScalarBC1D of `addScalarBC1D(A,b,k,m,dx,dc,nc,v)`, where `dc`, `nc`, and `vc` are vectors which hold the coefficients for $a$, $b$, and $g$ in the above system of equations. $a=[0,0]$, $b=[1,1]$ and $g=[0,0]$. 
Substituting these values in gives:

$$
\frac{du(0)}{dx} = 0
$$

$$
\frac{du(1)}{dx} = 0
$$

The exact solution ( with constant $C$ ) is:

$$
u(x) = C + \frac{x^2}{4} - \frac{x^3}{6}
$$

---

This example is implemented in:
- [MATLAB/ OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightNeumann.m)

Additional MATLAB/ OCTAVE variants of this example with different boundary conditions:
- [Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DHomogeneousDirichlet.m)
- [Non-Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonHomogeneousDirichlet.m)
- [Left Dirichlet, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightNeumann.m)
- [Left Dirichlet, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightRobin.m)
- [Left Neumann, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightRobin.m)
- [Left Robin, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftRobinRightRobin.m)
- [Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DPeriodicBC.m)
- [Non-Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonPeriodicBC.m)
