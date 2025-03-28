# 1D Poisson Equation

This example solves the 1D Poisson equation:
```{math}
    - \frac{d^2 C}{d x^2} = f(x)
```

with Robin boundary conditions: 
```{math}
    a \, u + b \, \frac{du}{dx} = g
```


The equation is discretized using mimetic operators.
