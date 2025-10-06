# Tutorial: Comparing Finite Difference and Mimetic Difference Operators  
### Solving the 1D Two-Way Wave Equation

This tutorial demonstrates how to solve the **1D two-way wave equation** using both **standard finite differences (FD)** and **mimetic finite differences (MD)**.  
We will use three main functions:

1. [`finite_diff_two_way_wave_eq`](#finite_diff_two_way_wave_eq)
2. [`mimetic_diff_two_way_wave_eq`](#mimetic_diff_two_way_wave_eq)
3. [`comparison_two_way_wave_md_vs_fd`](#comparison_two_way_wave_md_vs_fd)

The goal is to understand the **differences in accuracy, stability, and numerical properties** between traditional and mimetic operators. The two numerical functions have been created to be as similar as possible, so that only the changes necessary for mimetic difference operators are visible.

While each code can be run independanlty, the easiest way to compare the two methods is with `comparison_two_way_wave_md_vs_fd`

---

## Overview

The **1D two-way wave equation** is given by:

$$
\frac{\partial^2 u}{\partial t^2} = c^2 \frac{\partial^2 u}{\partial x^2}, \quad x \in [-2, 2] \qquad \qquad \qquad (1)
$$

Both solvers use a **centered-in-time, centered-in-space (CTCS)** scheme, which is **second-order accurate in both time and space**.

We assume no boundary effects (large domain), allowing a clean comparison of the spatial discretization methods. Here is a little bit more information about the two seperate functions.

---

## 1. `finite_diff_two_way_wave_eq`

**Purpose:** This function solves the the wave equation using **standard finite differences (FD)**.

**Time-stepping scheme (CTCS):**
If we discretize the equation with standard centered second order finite differences, Equation(1) turn into 

$$
\frac{U^{k-1}_i - 2U^{k}_i + U^{k+1}_i}{\Delta t^2} = c^2\frac{U_{i+1}^k - 2U_{i}^k + U_{i+1}^k}{\Delta x^2}
$$

Rearranging the equation for the unknown value $U^{k+1}_i$ we get:

$$
U^{k+1}_i = 2U^k_i - U^{k-1}_i + \frac{c^2\Delta t^2}{\Delta x^2}\Big(U^k_{i-1} - 2U^k_{i} + U^k_{i+1} \Big)
$$

Which can be expressed as a matrix $D_{fd}$ times the vector ${U^k}$

$$
U^{k+1} = 2U^k - U^{k-1} + D_{fd}U^k
$$


The matrix is written out in the code using sparse matrix operations and is equivalent to:

$$
D_{fd} = \frac{c^2\Delta t^2}{\Delta x^2}
\begin{bmatrix}
-2 & 1 & 0 & \cdots \\
1 & -2 & 1 & \cdots \\
0 & 1 & -2 & \cdots \\
\vdots & \vdots & \vdots & \ddots
\end{bmatrix}
$$

The new values are updated each time step with values from the previous two time steps (k, k-1).

$$
U^{k+1} = 2U^k - U^{k-1} + D_{fd}U^k
$$

### Function Outputs
| Variable | Description |
|-----------|--------------|
| `U2_fd` | Final solution at the last time step |
| `error_fd` | Norm of error vs. analytic/reference solution |
| `walltime_fd` | Wall-clock time (seconds) |
| `flops_fd` | Estimated floating-point operation count |

### Notes
We are using an explicit two-step scheme (leapfrog). The CFL condition must be satisfied: $ c \Delta t^2 / \Delta x^2 \le 1 $. If you change the stepping, or increase the number of cells, be sure to change this value. No boundary conditions are applied, the domain is large enough to avoid reflection effects. This is to test just the spacial scheme without any boundary considerations.

---

## 2. `mimetic_diff_two_way_wave_eq`

**Purpose:** Solve the wave equation using **mimetic difference operators (MD)**.

The mimetic Laplacian operator `L` replaces the explicit finite-difference stencil, automatically enforcing discrete analogs of conservation and symmetry properties.

**Time-stepping scheme:**
The mimetic operator directly takes the place fo the second derivative (Laplacian), therefore we only need to discretize the time derivative. Doing so to Equation (1) yields:

$$
\frac{U^{k-1}_i - 2U^{k}_i + U^{k+1}_i}{\Delta t^2} = c^2 L\,(U^k)
$$

Here, `L` is constructed from mimetic gradient (`G`) and divergence (`D`) operators such that:

$$
L = D \, G
$$

ensuring energy and flux consistency at the discrete level. The mimetic library Laplacian operator is just DG under the hood.

Rearranging our equation for the unknown value $U^{k+1}$ leads us to:

$$
U^{k+1}_i = 2U^k_i - U^{k-1}_i + c^2\Delta t^2 L(U^k) 
$$

To save computations in the code, `L` is premultiplied by $C^2\Delta t^2$ before the computation loop.

### Outputs
| Variable | Description |
|-----------|--------------|
| `U2_md` | Final solution at the last time step |
| `error_md` | Norm of error vs. analytic/reference solution |
| `walltime_md` | Wall-clock time (seconds) |
| `flops_md` | Estimated floating-point operation count |

### Notes
This uses the same CTCS time integration scheme as FD. The **order of accuracy** can be increased by adjusting the `k` parameter (e.g. `k=2`, `k=4`, etc.). Mimetic operators preserve **discrete conservation laws**, often improving numerical stability and physical fidelity. If you change the number of cells, be sure to change the time step, to conform to the CFL condition.

---

## 3. `comparison_two_way_wave_md_vs_fd`

**Purpose:** Compare **mimetic** and **finite difference** results for the same PDE setup.

This script runs both solvers and measures differences in:
- Numerical accuracy
- Computational cost
- Wall-clock time
- Error convergence rate

Assorted plots are generated showing differences between the two methods.


## Grid Comparison

The key difference between FD and MD methods lies in the spatial grid. Here is a slightly more involved explanation to help the user understand the difference in grids.

### Finite Difference Grid (Uniform)

Each cell is the same width Δx between **A** and **B**, with points at cell boundaries (0,1,2,...N-1,N,N+1):
```
A                                                                 B
 <-----dx-----> <-----dx----->  ...  <-----dx-----> <-----dx----->
|----cell 1----|----cell 2----| ... |----cell N-1--|----cell N----|
0              1              2 ... N-1             N             N+1
```

For example, from 0 to 1 with 5 cells has six values (x0,x1,x2,x3,x4,x5) each 0.2 away from each other:
```
0.0   0.2   0.4   0.6   0.8   1.0
 o-----o-----o-----o-----o-----o
 x0    x1    x2    x3    x4    x5
```
### Mimetic Difference Grid (Staggered)

Mimetic operators use a staggered grid—half-step offsets at boundaries improve conservation and symmetry. Here, note that **cell 1** and **cell N** are not the sam size as the internal cells, and that there are now **N+2** points.
```
A                                                         B
 <--dx/2--> <-----dx----->  ...  <-----dx-----> <--dx/2-->
|--cell 1--|----cell 2----| ... |----cell N-1--|--cell N--|
0          1              2 ... N             N+1        N+2
```

For the same interval (0–1) with 5 cells, a staggered grid will have smaller dt/s at the beginning and end, and also one mroe point (x0,x1,x2,x3,x4,x5,x6):
```
0.0   0.1   0.3   0.5   0.7   0.9   1.0
 o-----o-----o-----o-----o-----o-----o
 x0    x1    x2    x3    x4    x5    x6
```

This staggered layout provides **better discrete analogs** of differential operators, leading to improved conservation and often reduced numerical dispersion.

---

## Convergence and Accuracy

Both FD and MD methods use a **second-order accurate** CTCS scheme in time.  
The mimetic method, however, allows **higher-order spatial accuracy** by increasing the mimetic operator order `k`.

| Scheme | Spatial Order | Time Order | Conservation | Grid Type |
|---------|----------------|-------------|---------------|------------|
| Finite Difference | 2 | 2 | Approximate | Uniform |
| Mimetic Difference | 2 (or higher) | 2 | Exact (discrete) | Staggered |

---

## Practical Notes

- This setup isolates **spatial discretization effects**—no boundary reflections or external forcing.  
- Increasing `N` refines the grid and reduces spatial error.  
- For fair comparison, both solvers should use the same `dt`, `dx`, and runtime length.  
- The mimetic operator’s flexibility allows easy order-of-accuracy experiments by simply changing `k` in `mimetic_diff_two_way_wave_eq.m`.

---

## Summary

| Feature | Finite Difference | Mimetic Difference |
|----------|------------------|--------------------|
| Grid | Uniform | Staggered |
| Operator | Explicit stencil | Discrete mimetic operator |
| Conservation | Approximate | Exact (discrete) |
| Flexibility | Fixed 2nd order | Adjustable order (k) |
| Accuracy | 2nd order | ≥ 2nd order |
| Ease of implementation | Simple | Slightly more complex |
| Best use case | Quick prototyping | Physically consistent PDE solvers |

---

## References
- Castillo, J. E., *Mimetic Methods for Partial Differential Equations*. Cambridge University Press, 2008.  
- LeVeque, R. J., *Finite Difference Methods for Ordinary and Partial Differential Equations*. SIAM, 2007.