# Jacobian

> **Author:** Miguel A. Dumett  
> **Abstract:** This document presents mimetic differences gradient and divergence
> operators in structured curvilinear geometries. It uses mimetic
> interpolation operators to move quantities among the staggered grids
> of the mesh.

---

## Introduction

Suppose a PDE is given on a physical spatial domain $\mathcal P$ in
three-dimensions (3D), with coordinates $x,y,z$. Suppose $\mathcal P$ is
the result of a bijective smooth map $\mathcal X$ given by

$$\begin{aligned}
x & = & x(\xi,\eta,\kappa) \\
y & = & y(\xi,\eta,\kappa) \\
z & = & z(\xi,\eta,\kappa),
\end{aligned}$$

and that the inverse map of $\mathcal X$ is $\Theta$ which is given by

$$\begin{aligned}
\xi & = & \xi(x,y,z) \\
\eta & = & \eta(x,y,z) \\
\kappa & = & \kappa(x,y,z),
\end{aligned}$$

and it maps $\mathcal P$ onto a 3D logical Cartesian domain
$\mathcal L$. If one defines a staggered grid on $\mathcal L$, composed
of faces $F$ and centers/boundaries $C$, then $\mathcal X(C \cup F)$ is
an structured grid on $\mathcal P$, with centers/boundaries
$\mathcal C = \mathcal X(C)$ and faces $\mathcal F = \mathcal X(F)$.

The Jacobian of the transformation $\mathcal X$ is given by

$$J = \frac{\partial(x,y,z)}{\partial(\xi,\eta,\kappa)} = \left[ \begin{array}{ccc}  x_\xi & x_\eta & x_\kappa \\ y_\xi & y_\eta & y_\kappa \\ z_\xi & z_\eta & z_\kappa \end{array} \right].$$

For $u:\mathcal X \to \mathbb R$, with
$u = u(x,y,z) = u(x(\xi,\eta,\kappa),y(\xi,\eta,\kappa),z(\xi,\eta,\kappa))$
and hence $u = u(\xi,\theta,\kappa)$, the chain rule implies

$$
\begin{aligned}
u_\xi &= u_x x_\xi + u_y y_\xi + u_z z_\xi \\
u_\eta &= u_x x_\eta + u_y y_\xi + u_z z_\eta \\
u_\kappa &= u_x x_\kappa + u_y y_\xi + u_z z_\kappa
\end{aligned}
$$

or equivalently, 

$$\begin{aligned}
\left[ \begin{array}{c} u_\xi \\ u_\eta \\ u_\kappa \end{array} \right] = \left[ \begin{array}{ccc} x_\xi & y_\xi & z_\xi \\ x_\eta & y_\eta & z_\eta \\ x_\kappa & y_\kappa & z_\kappa \end{array} \right] \left[ \begin{array}{c} u_x \\ u_y \\ u_z \end{array} \right] = J^T \left[ \begin{array}{c} u_x \\ u_y \\ u_z \end{array} \right]
\end{aligned}$$

Hence

$$\left[ \begin{array}{c} u_x \\ u_y \\ u_z \end{array} \right] = (J^T)^{-1} \left[ \begin{array}{c} u_\xi \\ u_\eta \\ u_\kappa\end{array} \right].$$

Since

$$\left[ \begin{array}{ccc} a & b & c \\ d & e & f \\ g & h & i \end{array} \right]^{-1} = \frac{1}{\Delta} \left[ \begin{array}{ccc} ei - fh & ch-bi & bf - ce \\ fg - di & ai - cg & cd - af \\ dh - eg & bg - ah & ac - bd \end{array} \right],$$

where 

$\Delta = a(ei-fh) - b(di-fg) + c(dh-eg)$.

If one denotes

$$
J^T = \begin{pmatrix}
(1) = x_\xi & (2) = y_\xi & (3) = z_\xi \\
(4) = x_\eta & (5) = y_\eta & (6) = z_\eta \\
(7) = x_\kappa & (8) = y_\kappa & (9) = z_\kappa
\end{pmatrix}
$$

then 

$$
(J^T)^{-1} = \frac{1}{\Delta} \begin{pmatrix}
(5)(9) - (6)(8) & (3)(8) - (2)(9) & (2)(6) - (3)(5) \\
(6)(7) - (4)(9) & (1)(9) - (3)(7) & (3)(4) - (1)(6) \\
(4)(8) - (5)(7) & (2)(7) - (1)(8) & (1)(5) - (2)(4)
\end{pmatrix}
$$

with

$\Delta = (1) ((5)(9) - (6)(8)) - (2)((4)(9) - (6)(7)) + (3)((4)(8) - (5)(7)).$

If one uses the gradient to approximate the partial derivatives of the
Jacobian, then

$$
J_G^T = I_{xyz}^{F \to C} {\tilde G}_{\xi \eta \kappa}
$$

where ${\tilde G}_{xyz}$ is the same as $G_{xyz}$ with ${\hat I}_p$
replaced by $I_{p+2}$, the identity matrix of order $p+2$. If one
computes the Jacobian at the centers then the physical gradient is given
by

$$
G_{xyz} = I_{xyz}^{C \to F} (J_G^T)^{-1} I_{\xi \eta \kappa}^{F \to C} G_{\xi \eta \kappa}.
$$

Similarly, one can construct the Jacobian based on the divergence operator.


