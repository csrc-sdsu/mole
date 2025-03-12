# Gradient Operator

The gradient operator computes the gradient of a scalar field.

```{eval-rst}
.. note::
   For complete API details of the ``Gradient`` class, see the :cpp:class:`Gradient` class in the Class Reference.
```

## Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create scalar field
    std::vector<double> f(grid.size());
    
    // Initialize scalar field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            f[idx] = x*x + y*y;
        }
    }
    
    // Create gradient operator
    mole::Gradient grad(grid);
    
    // Compute gradient
    std::vector<double> grad_x, grad_y;
    grad.apply(f, grad_x, grad_y);
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygenclass:: mole::Gradient
   :members:
   :project: MoleCpp
``` 