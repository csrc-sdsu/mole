### Backward Euler Method

This example solves the first-order ordinary differential equation using the backward euler method.

$$
\frac{dy}{dt} = \sin^2(t) \cdot y
$$

with initial condition $y(0) = 0$ over the time interval $[0,5]$.

#### Mathematical Background

The backward euler method is an implicit method for solving first-order differential equations where we are evaluating the function at the next point in time $y_{i+1}$.

$$
y_{i+1} = y_i + h \cdot f(t_{i+1}, y_{i+1})
$$

where:
- $h$ is the step-size
- $t_i$ is the current time
- $y_i$ is the solution at time $t_i$
- $y_{i+1}$ is the solution at the next time step $t_{i+1}$
- $f(t_{i+1}, y_{i+1})$ is the function at time step $t_{i+1}$ and $y_{i+1}$

#### Implementation Details

Note that $f(t_{i+1}, y_{i+1})$ is not known due to $y_{i+1}$ being on both the left and right hand side. Therefore, we can solve for $y_{i+1}$ by finding the root:
$$
y_{i+1} - y_i + h \cdot f(t_{i+1}, y_{i+1}) = 0
$$

In the C++ example, we used the fixed-point iteration method for rootfinding due to it's simpler nature.

#### Results

![Backward Euler gnuplot](../../_images/backward_euler.png)

---

This example is implemented in:
- [MATLAB/Octave](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab_octave/backward_euler.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/backward_euler.cpp) *(if available)*
