# Divergence Operator

The divergence operator computes the divergence of a vector field.

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
    
    // Create divergence operator
    u16 k = 4; // Order of accuracy
    Divergence div(k, m, dx, n, dy);
    
    // Create vector field components
    std::vector<double> u(m*n);
    std::vector<double> v(m*n);
    
    // Initialize vector field
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            u32 idx = i + j*m;
            double x = i * dx;
            double y = j * dy;
            
            u[idx] = std::sin(x) * std::cos(y);
            v[idx] = std::cos(x) * std::sin(y);
        }
    }
    
    // Compute divergence
    std::vector<double> result = div.apply(u, v);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the Divergence class in the source code. 