# Integration1D.m

## Ricker Wavelet Propagation using Mimetic Quadrature Weights

 This program solves the 1D acoustic wave equation using *mimetic operators*.
 The governing equation:

$$
      \frac{\partial^2 u}{\partial t^2} = c^2\frac{\partial^2 u}{\partial x^2} + f(t)
$$

 where:
- $u(x,t)$ = wavefield (displacement or pressure)
- $c$      = wave propagation speed (can be constant or spatially varying)
- $f(t)$   = source term (Ricker wavelet in time)

 The Ricker wavelet source is defined as:

$$
        f(t) = (1 - 2\pi^2f_0^2(t - t_0)^2) * exp(-\pi^2f_0^2(t - t_0)^2)
$$

where $f_0$ is the dominant frequency and $t_0$ is the source time delay.

---

## MIMETIC DISCRETIZATION

In the mimetic framework, spatial derivatives are represented by discrete
gradient (G) and divergence (D) operators that satisfy a discrete analogue
of the integration-by-parts identity:

$$
       <v, D u>_Q + <G v, u>_P = boundary_terms
$$

 where $<a,b>_Q = a^T Q b$ defines an inner product weighted by $Q$.

 Here:
   - Q: Diagonal matrix of quadrature weights at *cell centers*
   - P: Diagonal matrix of quadrature weights at *cell faces*

 Both Q and P are positive definite diagonal matrices. Their dimensions are
 chosen so that the following operations are valid:

       Q * D        (divergence operator in cell-centered space)
       P * G        (gradient operator in face-centered space)
       G' * P       (adjoint of P*G, equivalent to -D for closed boundaries)

 The *mimetic boundary operator* is defined as:

       B = Q * D + G' * P

 This ensures that the discrete operators exactly satisfy conservation laws
 and reproduce the divergence theorem on the computational grid.

 ---

 ## NUMERICAL INTEGRATION

 The second spatial derivative (∂²u/∂x²) is obtained through the mimetic Laplacian:

       L = D * (P⁻¹ * G)

 so that the discrete form of the wave equation becomes:

       Q * (d²u/dt²) = c² * Q * L * u + Q * f

 Since Q is diagonal, it acts as a discrete mass matrix that defines the
 quadrature weights for integration over the computational domain.

 In this implementation, we use the weights from Q explicitly for the
 numerical integration step. P and G are still conceptually part of the
 mimetic framework but are not directly required for this reduced problem.

 ---

## ALGORITHM OVERVIEW

 1. Define grid spacing and boundary conditions.
 2. Construct mimetic operators D, G, and the weight matrix Q.
 3. Initialize the wavefield u(x, t=0) = 0 and velocity = 0.
 4. Apply the Ricker source term f(t) at a chosen grid location.
 5. Time-step the system using central finite differences:

        u_tt = c² * L * u + f
        u(t+Δt) = 2u(t) - u(t-Δt) + Δt² * Q⁻¹ * (c² Q L u + Q f)

 6. Record and visualize the wavefield evolution.


This example is implemented in:
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/lock_exchange.m)