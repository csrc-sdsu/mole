# I/O Utilities

The MOLE library provides utilities for input and output operations, such as saving and loading fields.

## Usage Example

```cpp
#include <vector>
#include <string>

int main() {
    // Create a 2D grid
    u32 m = 50; // cells in x-direction
    u32 n = 50; // cells in y-direction
    Real dx = 0.02;
    Real dy = 0.02;
    
    // Create a field
    std::vector<double> field(m*n);
    
    // Initialize field
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            u32 idx = i + j*m;
            double x = i * dx;
            double y = j * dy;
            
            field[idx] = x*x + y*y;
        }
    }
    
    // Save field to file
    std::string filename = "field.dat";
    // io::save_field(field, filename);
    
    // Load field from file
    std::vector<double> loaded_field;
    // io::load_field(loaded_field, filename);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the I/O utility functions in the source code. 