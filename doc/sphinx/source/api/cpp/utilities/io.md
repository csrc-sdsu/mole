# I/O Utilities

The MOLE library provides utility functions for input and output operations.

```{eval-rst}
.. note::
   For complete API details of the I/O utilities, see the ``io`` namespace in the Class Reference.
```

## Usage Example

```cpp
#include <mole/utils.h>
#include <mole/grid.h>
#include <vector>
#include <string>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create a field
    std::vector<double> field(grid.size());
    for (size_t i = 0; i < field.size(); ++i) {
        field[i] = /* some value */;
    }
    
    // Save the field to a file
    std::string filename = "field_data.txt";
    mole::Utils::saveField(field, grid, filename);
    
    // Load the field from a file
    std::vector<double> loaded_field;
    mole::Utils::loadField(loaded_field, grid, filename);
    
    return 0;
}
```

## VTK Output Example

```cpp
#include <mole/io.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create a field
    std::vector<double> field(grid.size());
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            field[idx] = x*x + y*y;
        }
    }
    
    // Save field in VTK format for visualization
    mole::io::saveVTK(grid, field, "field.vtk", "field");
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygennamespace:: mole::io
   :members:
   :project: MoleCpp
``` 