# Laplacian Operator

The Laplacian operator computes the Laplacian of a scalar field.

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
    
    // Create Laplacian operator
    u16 k = 4; // Order of accuracy
    Laplacian lap(k, m, dx, n, dy);
    
    // Create scalar field
    std::vector<double> f(m*n);
    
    // Initialize scalar field
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            u32 idx = i + j*m;
            double x = i * dx;
            double y = j * dy;
            
            f[idx] = std::sin(M_PI * x) * std::sin(M_PI * y);
        }
    }
    
    // Compute Laplacian
    std::vector<double> result = lap.apply(f);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the Laplacian class in the source code. 