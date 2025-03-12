# Divergence Operator

The divergence operator computes the divergence of a vector field.

```{eval-rst}
.. note::
   For complete API details of the ``Divergence`` class, see the :cpp:class:`Divergence` class in the Class Reference.
```

## Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create vector field (u, v)
    std::vector<double> u(grid.size());
    std::vector<double> v(grid.size());
    
    // Initialize vector field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            u[idx] = x * y;
            v[idx] = x * x + y * y;
        }
    }
    
    // Create divergence operator
    mole::Divergence div(grid);
    
    // Compute divergence
    std::vector<double> result = div.apply(u, v);
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygenclass:: mole::Divergence
   :members:
   :project: MoleCpp
``` 