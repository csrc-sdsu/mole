# Curl Operator

The curl operator computes the curl of a vector field.

```{eval-rst}
.. note::
   For complete API details of the ``Curl`` class, see the :cpp:class:`Curl` class in the Class Reference.
```

## Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 3D grid
    mole::Grid3D grid(0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 20, 20, 20);
    
    // Create vector field (u, v, w)
    std::vector<double> u(grid.size());
    std::vector<double> v(grid.size());
    std::vector<double> w(grid.size());
    
    // Initialize vector field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            for (int k = 0; k < grid.nz(); ++k) {
                int idx = i + j * grid.nx() + k * grid.nx() * grid.ny();
                double x = grid.x(i);
                double y = grid.y(j);
                double z = grid.z(k);
                
                u[idx] = y * z;
                v[idx] = x * z;
                w[idx] = x * y;
            }
        }
    }
    
    // Create curl operator
    mole::Curl curl(grid);
    
    // Compute curl
    std::vector<double> curl_x, curl_y, curl_z;
    curl.apply(u, v, w, curl_x, curl_y, curl_z);
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygenclass:: mole::Curl
   :members:
   :project: MoleCpp
``` 