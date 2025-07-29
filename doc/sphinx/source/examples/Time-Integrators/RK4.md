# 4th-Order Runge-Kutta Method (RK4)

This example demonstrates the classic 4th-order Runge-Kutta method (RK4) for solving ordinary differential equations (ODEs). The RK4 method is a widely used numerical integration technique that provides a good balance of accuracy, stability, and computational efficiency.

## Mathematical Background

The RK4 method solves initial value problems of the form:

$$\frac{dy}{dt} = f(t, y),\quad y(t_0) = y_0$$

The method advances the solution from $t_n$ to $t_{n+1} = t_n + h$ using the formula:

$$y_{n+1} = y_n + \frac{h}{6}(k_1 + 2k_2 + 2k_3 + k_4)$$

where:

$$\begin{align}
k_1 &= f(t_n, y_n) \\
k_2 &= f(t_n + \frac{h}{2}, y_n + \frac{h}{2}k_1) \\
k_3 &= f(t_n + \frac{h}{2}, y_n + \frac{h}{2}k_2) \\
k_4 &= f(t_n + h, y_n + hk_3)
\end{align}$$

The method is 4th-order accurate, meaning the local truncation error is $O(h^5)$, and the global error is $O(h^4)$.

## Example Problem

In this example, we solve the ODE:

$$\frac{dy}{dt} = \sin^2(t) \cdot y,\quad y(0) = 2$$

This is a linear ODE with a time-varying coefficient. The exact solution can be found by separation of variables:

$$y(t) = y_0 \exp\left(\int_0^t \sin^2(s) ds\right) = y_0 \exp\left(\frac{t}{2} - \frac{\sin(2t)}{4}\right)$$

---

This example is implemented in:
- [MATLAB/OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/RK4.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/RK4.cpp)

## Properties of RK4

The RK4 method has several important properties:

1. **Accuracy**: 4th-order convergence means that halving the step size reduces the error by a factor of approximately 16.

2. **Stability**: The RK4 method has a relatively large stability region, making it suitable for many non-stiff problems.

3. **Self-starting**: Unlike multi-step methods, RK4 doesn't require special starting procedures or values from previous steps.

4. **Function Evaluations**: RK4 requires four function evaluations per step, which is more expensive than simpler methods like Euler's method but often justified by the improved accuracy.

## Applications in PDE Solving

While this example demonstrates RK4 for an ODE, the method is often used in the time integration of PDEs after spatial discretization (method of lines). In the MOLE library, RK4 can be combined with mimetic operators for spatial discretization to create high-order accurate PDE solvers. 
