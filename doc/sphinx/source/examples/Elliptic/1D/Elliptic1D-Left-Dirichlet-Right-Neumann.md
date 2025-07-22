### Elliptic1D Left Dirichlet and Right Neumann Boundary Conditions

Solves the 1D Poisson equation with left Dirichlet and right Neumann boundary conditions.

$$
-\nabla^2 u(x) = 1
$$

with $x\in[0,1]$. The boundary conditions are given by

$$
a_nu + b_n\frac{du}{dx} = g_n
$$

with the left hand side boundary condition (Neumann) satisfying

$$
0u(0) + 1\frac{du(0)}{dx} = 0
$$

and the right hand boundary condition (Dirichlet) satisfying

$$
1u(1) + 0\frac{du(1)}{dx} = 0
$$

This corresponds to the call to addScalarBC1D of `addScalarBC1D(A,b,k,m,dx,dc,nc,v)`, where `dc`, `nc`, and `vc` are vectors which hold the coefficients for $a$, $b$, and $g$ in the above system of equations. $a=[0,1]$, $b=[1,0]$ and $g=[0,0]$. Substituting these values in gives:

$$
\frac{du(0)}{dx} = 0
$$ 

$$
u(1) = 0
$$

The true solution is:

$$
u(x) = \frac{1-x^2}{2}
$$

---

This example is implemented in:
- [MATLAB/ OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightNeumann.m)

Additional MATLAB/ OCTAVE variants of this example with different boundary conditions:
- [Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DHomogeneousDirichlet.m)
- [Non-Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonHomogeneousDirichlet.m)
- [Left Dirichlet, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightRobin.m)
- [Left Neumann, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightNeumann.m)
- [Left Neumann, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightRobin.m)
- [Left Robin, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftRobinRightRobin.m)
- [Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DPeriodicBC.m)
- [Non-Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonPeriodicBC.m)
