### Transport1D

Solves the 1D advection-reaction-dispersion equation:

$$
\frac{\partial C}{\partial t} + v\frac{\partial C}{\partial x} = D\frac{\partial^2 C}{\partial x^2}
$$

where $C$ is the concentration, $v$ is the pore-water flow velocity, and $D$ is the dispersion coefficient.

---

This example is implemented in:
- [C++ Source Code (transport1D.cpp)](https://github.com/csrc-sdsu/mole/blob/main/examples/cpp/Hyperbolic/1D/transport1D.cpp)

```{literalinclude} ../../../../../examples/cpp/Hyperbolic/1D/transport1D.cpp
:language: cpp
:lines: 1-10
:caption: Preview of Transport 1D Example
```