### Elliptic2D X-Periodic Y-Dirichlet

Solves the 2D Poisson equation with periodic boundary conditions in the x-direction and Dirichlet boundary conditions in the y-direction.

$$
-\left(u_{xx}+u_{yy}\right)
=
2\sin(2\pi x)\left(1+2\pi^2y(1-y)\right)
$$

with

$$
0 < x < 1,\qquad 0 < y < 1.
$$

The boundary conditions are periodic in the x-direction:

$$
u(0,y)=u(1,y),
$$

and homogeneous Dirichlet conditions are applied on the boundaries $y=0$ and $y=1$:

$$
u(x,0)=0,\qquad u(x,1)=0.
$$

This corresponds to the call to `addScalarBC2D(A,b,k,m,dx,n,dy,dc,nc,v)`, with

$$
dc=[0,0,1,1], \qquad nc=[0,0,0,0],
$$

specifying periodic conditions on the left and right edges and Dirichlet conditions on the bottom and top edges.

The exact solution is

$$
u(x,y)=y(1-y)\sin(2\pi x).
$$

The example produces plots of the approximate solution and the exact solution.

This example is implemented in:

- [Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/octave/elliptic2DXPerYDirichlet.m)