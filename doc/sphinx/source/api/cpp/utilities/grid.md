# Grid Utilities

The MOLE library provides utilities for creating and manipulating grids in 1D, 2D, and 3D.

## Usage Example

```cpp
#include <vector>

int main() {
    // Create a 1D grid
    u32 m = 100; // Number of cells
    Real dx = 0.01; // Cell width
    
    // Create a 2D grid
    u32 n = 50; // Number of cells in y-direction
    Real dy = 0.02; // Cell width in y-direction
    
    // Create a 3D grid
    u32 o = 25; // Number of cells in z-direction
    Real dz = 0.04; // Cell width in z-direction
    
    // Access grid points
    for (u32 i = 0; i < m; ++i) {
        double x = i * dx; // x-coordinate
        
        // Do something with x
    }
    
    // Access 2D grid points
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            double x = i * dx; // x-coordinate
            double y = j * dy; // y-coordinate
            
            // Do something with x, y
        }
    }
    
    // Access 3D grid points
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            for (u32 k = 0; k < o; ++k) {
                double x = i * dx; // x-coordinate
                double y = j * dy; // y-coordinate
                double z = k * dz; // z-coordinate
                
                // Do something with x, y, z
            }
        }
    }
    
    return 0;
}
```

## API Details

For complete API details, please refer to the grid utility classes in the source code. 