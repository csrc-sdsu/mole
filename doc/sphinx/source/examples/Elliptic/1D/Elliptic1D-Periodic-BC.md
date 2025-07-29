### Elliptic1D Periodic Dirichlet Boundary Conditions

Solves the 1D Poisson equation with periodic  boundary conditions.

$$
-\nabla^2 u(x) = 4\pi^2 \sin( 2\pi x )
$$

with $x\in[0,1]$. The boundary conditions here are a special case, and periodicity is all that is required. Mathematically,

$$
u(0) = u(1)
$$

and

$$
\frac{du(0)}{dx} = \frac{du(1)}{dx}
$$

This corresponds to the call to addScalarBC1D of `addScalarBC1D(A,b,k,m,dx,dc,nc,v)`, where `dc`, `nc`, and `vc` are vectors which hold the coefficients for $a$, $b$, and $g$ in the above system of equations. To request periodicity, the values must be all zeros. $a=[0,0]$, $b=[0,0]$ and $g=[0,0]$. 

This tells the MOLE library to build a 1D periodic boundary operator. This same logic is extended to 2 and 3 dimensions. A periodic boundary operator is returned if ALL of the values for the appropriate boundary vector values `a,b,g` are zero.


The true solution ( where $C$ is a constant ) is

$$
u(x) = \sin(2\pi x) + C
$$

---

This example is implemented in:
- [MATLAB/ OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DPeriodicBC.m)

Additional MATLAB/ OCTAVE variants of this example with different boundary conditions:
- [Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DHomogeneousDirichlet.m)
- [Non-Homogeneous Dirichlet](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonHomogeneousDirichlet.m)
- [Left Dirichlet, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightNeumann.m)
- [Left Dirichlet, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftDirichletRightRobin.m)
- [Left Neumann, Right Neumann](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightNeumann.m)
- [Left Neumann, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftNeumannRightRobin.m)
- [Left Robin, Right Robin](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DLeftRobinRightRobin.m)
- [Non-Periodic Boundary Conditions](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/elliptic1DNonPeriodicBC.m)
