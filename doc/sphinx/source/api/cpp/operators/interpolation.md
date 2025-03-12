# Interpolation Operator

The interpolation operator performs interpolation operations on fields.

```{eval-rst}
.. note::
   For complete API details of the ``Interpol`` class, see the :cpp:class:`Interpol` class in the Class Reference.
```

## Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create a field
    std::vector<double> field(grid.size());
    
    // Initialize field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            field[idx] = x*x + y*y;
        }
    }
    
    // Create interpolation operator with coefficient c = 0.5
    double c = 0.5;
    mole::Interpol interp(grid.nx(), grid.ny(), c, c);
    
    // Apply interpolation
    std::vector<double> result = interp.apply(field);
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygenclass:: mole::Interpol
   :members:
   :project: MoleCpp
``` 