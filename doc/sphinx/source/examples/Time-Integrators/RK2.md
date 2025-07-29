# Second-Order Runge-Kutta Method (RK2)

This example demonstrates the second-order Runge-Kutta (RK2) method for solving ordinary differential equations (ODEs). The method is implemented to solve a first-order ODE of the form:

$$
\frac{dy}{dt} = f(t,y) = \sin^2(t) \cdot y
$$

with initial condition $y(0) = 2.0$ over the time interval $[0,5]$.

## Method Description

The RK2 method (also known as the midpoint method) uses two stages to compute each time step:

1. First stage (slope at the beginning):
   $$
   k_1 = f(t_i, y_i)
   $$

2. Second stage (slope at midpoint):
   $$
   k_2 = f(t_i + \frac{h}{2}, y_i + \frac{h}{2}k_1)
   $$

3. Solution update:
   $$
   y_{i+1} = y_i + h \cdot k_2
   $$

where:
- $h$ is the step size (set to 0.1 in the examples)
- $t_i$ is the current time
- $y_i$ is the solution at time $t_i$

This example is implemented in:
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/RK2.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/RK2.cpp)

Both implementations include visualization of the solution using plotting tools (MATLAB's built-in plot function and GNUplot for C++). 
