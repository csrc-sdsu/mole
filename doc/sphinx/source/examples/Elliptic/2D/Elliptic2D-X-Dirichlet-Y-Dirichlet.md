### Elliptic2D X-Dirichlet Y-Dirichlet

Solves the 2D Laplace equation with Dirichlet boundary conditions on all four sides of a square domain.

$$
\nabla^2 u(x,y) = 0
$$

with

$$
0 < x < \pi,\qquad 0 < y < \pi.
$$

The boundary conditions are

$$
u(x,0) = e^x,
$$

$$
u(x,\pi) = -e^x,
$$

$$
u(0,y) = \cos(y),
$$

and

$$
u(\pi,y) = e^\pi\cos(y).
$$

This corresponds to the call to `addScalarBC2D(A,b,k,m,dx,n,dy,dc,nc,v)`, with

$$
dc=[1,1,1,1], \qquad nc=[0,0,0,0],
$$

applying Dirichlet boundary conditions on all four edges.

The exact solution is

$$
u(x,y) = e^x\cos(y).
$$

Using the parameters in the example, the computed solution has:

- Maximum error: \(0.0003\)
- Relative error: \(0.0006\%\)

This example is implemented in:

- [Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/octave/elliptic2DXDirichletYDirichlet.m)
