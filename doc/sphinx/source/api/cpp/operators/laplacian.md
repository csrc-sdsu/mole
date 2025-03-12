# Laplacian Operator

The Laplacian operator computes the Laplacian of a field.

```{eval-rst}
.. note::
   For complete API details of the ``Laplacian`` class, see the :cpp:class:`Laplacian` class in the Class Reference.
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
    
    // Create Laplacian operator
    mole::Laplacian lap(grid);
    
    // Compute Laplacian
    std::vector<double> result = lap.apply(f);
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygenclass:: mole::Laplacian
   :members:
   :project: MoleCpp
``` 