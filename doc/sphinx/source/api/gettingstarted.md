# Getting Started

Welcome to the getting started guide for MOLE (Mimetic Operators Library Enhanced). This guide will help you set up and run your first MOLE project.

```{include} ../../../../README.md
:start-after: "3: Installation"
:end-before: "4: Running Examples & Tests"
:name: installation-section-include
```

## Quick Start Examples

Here are some simple examples to help you get started with MOLE:

### C++ Example

```cpp
#include "mole.h"
#include <iostream>

int main() {
    // Create a 1D grid with 100 cells and spacing of 0.01
    u32 m = 100;
    Real dx = 0.01;
    
    // Create operators (4th order of accuracy)
    u16 k = 4;
    Gradient G(k, m, dx);      // Gradient operator
    Divergence D(k, m, dx);    // Divergence operator
    Laplacian L(k, m, dx);     // Laplacian operator
    
    // Create vectors for input and output
    vec f(m);
    vec df(m);
    
    // Initialize input vector with a sine wave
    for (u32 i = 0; i < m; ++i) {
        Real x = i * dx;
        f(i) = sin(x);
    }
    
    // Apply operators
    df = G * f;        // Compute gradient
    df = D * f;        // Compute divergence
    df = L * f;        // Compute Laplacian
    
    return 0;
}
```

### MATLAB Example

```matlab
% Create a 1D grid
m = 100;
dx = 0.01;

% Create operators (4th order)
k = 4;
G = gradient(k, m, dx);
D = divergence(k, m, dx);
L = laplacian(k, m, dx);

% Create and initialize input vector
x = (0:m-1) * dx;
f = sin(x);

% Apply operators
df_dx = G * f';       % Gradient
div_f = D * f';       % Divergence
lap_f = L * f';       % Laplacian
```

```{include} ../../../../README.md
:start-after: "4: Running Examples & Tests"
:end-before: "5: Documentation"
:name: examples-tests-section-include
```

## Next Steps

- Check out more complex examples in the examples directory
- Join our community and [contribute](../api/contributing_wrapper.md)

```{include} ../../../../README.md
:start-after: "**NOTE:**"
:end-before: "6: Community Guidelines"
:name: note-section-include
``` 