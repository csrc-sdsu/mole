# Interpolation Operator

The interpolation operator interpolates values from one grid to another.

## Usage Example

```cpp
#include <vector>
#include <cmath>

int main() {
    // Create a 2D grid
    u32 m = 50; // cells in x-direction
    u32 n = 50; // cells in y-direction
    Real dx = 0.02;
    Real dy = 0.02;
    
    // Create interpolation operator
    u16 k = 4; // Order of accuracy
    Interpol interp(k, m, dx, n, dy);
    
    // Create scalar field
    std::vector<double> f(m*n);
    
    // Initialize scalar field
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            u32 idx = i + j*m;
            double x = i * dx;
            double y = j * dy;
            
            f[idx] = std::sin(x) * std::cos(y);
        }
    }
    
    // Interpolate to cell centers
    std::vector<double> result = interp.apply(f);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the Interpol class in the source code. 