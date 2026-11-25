### Elliptic2D X-Periodic Y-Periodic

Solves the 2D Poisson equation with periodic boundary conditions in both the x- and y-directions.

$$
\nabla^2 u(x,y) = e^{-10(x^2+y^2)}
$$

with

$$
-1 < x < 1,\qquad -1 < y < 1.
$$

The boundary conditions are periodic:

$$
u(-1,y)=u(1,y)
$$

and

$$
u(x,-1)=u(x,1).
$$

The source term is:

$$
f(x,y)=e^{-10(x^2+y^2)}.
$$

This corresponds to the call to `addScalarBC2D(A,b,k,m,dx,n,dy,dc,nc,v)`,
with

$$
dc=[0,0,0,0], \qquad nc=[0,0,0,0],
$$

and periodic boundary conditions specified for all four edges. The grid
uses interior cell-center points without duplicating the endpoints.

No analytical solution is provided for this example, so no error value is reported.

The example produces plots of the approximate solution and the source term.

This example is implemented in:

- [Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/octave/elliptic2DXPeriodicYPeriodic.m)