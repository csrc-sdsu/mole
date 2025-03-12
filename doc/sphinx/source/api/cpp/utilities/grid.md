# Grid Utilities

The MOLE library provides various utility functions for working with grids and meshes.

```{eval-rst}
.. note::
   For complete API details of the grid utilities, see the :cpp:class:`Utils` class in the Class Reference.
```

## Usage Example

```cpp
#include <mole/utils.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create a meshgrid
    std::vector<double> X, Y;
    mole::Utils::meshgrid(grid.x(), grid.y(), X, Y);
    
    // Use the meshgrid to initialize a field
    std::vector<double> field(grid.size());
    for (size_t i = 0; i < field.size(); ++i) {
        field[i] = std::sin(2 * M_PI * X[i]) * std::cos(2 * M_PI * Y[i]);
    }
    
    return 0;
}
```

## Grid Creation Examples

```cpp
#include <mole/grid.h>
#include <iostream>

int main() {
    // Create a 1D grid
    mole::Grid1D grid1d(0.0, 1.0, 100);
    
    // Print grid information
    std::cout << "1D Grid points: " << grid1d.size() << std::endl;
    std::cout << "1D Grid spacing: " << grid1d.spacing() << std::endl;
    
    // Create a 2D grid
    mole::Grid2D grid2d(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Print grid information
    std::cout << "2D Grid points: " << grid2d.size() << std::endl;
    std::cout << "2D Grid x-spacing: " << grid2d.dx() << std::endl;
    std::cout << "2D Grid y-spacing: " << grid2d.dy() << std::endl;
    
    // Create a 3D grid
    mole::Grid3D grid3d(0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 20, 20, 20);
    
    // Print grid information
    std::cout << "3D Grid points: " << grid3d.size() << std::endl;
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygenclass:: mole::Grid1D
   :members:
   :project: MoleCpp

.. doxygenclass:: mole::Grid2D
   :members:
   :project: MoleCpp

.. doxygenclass:: mole::Grid3D
   :members:
   :project: MoleCpp
``` 