# Gradient Operator

The gradient operator computes the gradient of a scalar field.

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
    
    // Create gradient operator
    u16 k = 4; // Order of accuracy
    Gradient grad(k, m, dx, n, dy);
    
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
    
    // Compute gradient
    std::vector<double> grad_x, grad_y;
    grad.apply(f, grad_x, grad_y);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the Gradient class in the source code. 