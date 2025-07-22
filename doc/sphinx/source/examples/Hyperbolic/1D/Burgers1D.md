### Burgers1D

This example deals with the conservative form of the inviscid Burgers equation in 1D.

$$
\frac{\partial U}{\partial t} + \frac{\partial}{\partial x}\Big(\frac{U^2}{2}\Big) = 0
$$

with $U = u(x,t)$ defined on the domain $x\in[-15,15]$, from time $t\in[0,10]$ and initial conditions

$$
u(x,0) = e^{\frac{-x^2}{50}}
$$

The wave is allowed to propagate across the domain while the area under the curve is calculated. 

---

This example is implemented in:
- [MATLAB/ OCTAVE](https://github.com/csrc-sdsu/mole/blob/main/examples/matlab/burgers1D.m)
- [C++](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/Burgers1D.cpp) 
