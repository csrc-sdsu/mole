# Mimetic Discretization of the Integration by Parts Formula

The divergence theorem states that

$$
  \int_{\Omega} (\nabla \cdot \mathbf{u}) \, q \, dV
  = \int_{\partial \Omega} q \, (\mathbf{u} \cdot \mathbf{n}) \, ds
  - \int_{\Omega} \mathbf{u} \cdot \nabla q \, dV \qquad \qquad (1)
$$

where the boundary integral represents the flux through $\partial \Omega$.


In one dimension, this reduces to the familiar integration by parts (IBP) formula:

$$
  \int_a^b u'(x)\, q(x)\, dx
  = \big[ u(x)\, q(x) \big]_a^b - \int_a^b u(x)\, q'(x)\, dx \qquad \qquad (2)
$$

where the boundary term is $\big[ u(x)\, q(x) \big]_a^b = u(b)q(b) - u(a)q(a)$.  

If the boundary term vanishes (e.g., homogeneous Dirichlet or periodic boundary conditions), we obtain the following

$$
  \int_a^b u'(x)\, q(x)\, dx
  = - \int_a^b u(x)\, q'(x)\, dx \qquad \qquad (3)
$$

and let

$$
  u_h \in \mathcal{F}_h,
  \qquad
  q_h \in \mathcal{C}_h
$$

be discrete fields, where $\mathcal{F}_h$ denotes the discrete space associated with face-centered (vector) quantities, and $\mathcal{C}_h$ the space associated with cell-centered (scalar) quantities.

Define the one-dimensional mimetic operators ***divergence*** and ***gradient***:

$$
  D: \mathcal{F}_h \to \mathcal{C}_h,
  \qquad
  G: \mathcal{C}_h \to \mathcal{F}_h
$$

The weighted inner products on $\mathcal{F}_h$ and $\mathcal{C}_h$ are induced by diagonal, positive-definite matrices $P$ and $Q$, respectively.

Then, the discrete analog of (3) is given by

$$
  \langle D u_h, q_h \rangle_{Q}
  = - \langle u_h, G q_h \rangle_{P},
  \qquad \forall\, u_h, q_h
$$

or, in matrix form,

$$
  (D u_h)^{T} Q\, q_h = -\, u_h^{T} P\, (G q_h)
$$

The example [integration1D.m](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/integration1D.m) illustrates how the weight matrix $Q$ can be used to approximate the integral of a Ricker wavelet.