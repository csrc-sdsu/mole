# Curl Operator

The curl operator computes the curl of a vector field.

## Usage Example

```cpp
#include <vector>
#include <cmath>

int main() {
    // Create a 3D grid
    u32 m = 20; // cells in x-direction
    u32 n = 20; // cells in y-direction
    u32 o = 20; // cells in z-direction
    Real dx = 0.05;
    Real dy = 0.05;
    Real dz = 0.05;
    
    // Create curl operator
    u16 k = 4; // Order of accuracy
    Curl curl(k, m, dx, n, dy, o, dz);
    
    // Create vector field components
    std::vector<double> u(m*n*o);
    std::vector<double> v(m*n*o);
    std::vector<double> w(m*n*o);
    
    // Initialize vector field
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            for (u32 k = 0; k < o; ++k) {
                u32 idx = i + j*m + k*m*n;
                double x = i * dx;
                double y = j * dy;
                double z = k * dz;
                
                u[idx] = std::sin(x) * std::cos(y) * std::cos(z);
                v[idx] = std::cos(x) * std::sin(y) * std::cos(z);
                w[idx] = std::cos(x) * std::cos(y) * std::sin(z);
            }
        }
    }
    
    // Compute curl
    std::vector<double> curl_x, curl_y, curl_z;
    curl.apply(u, v, w, curl_x, curl_y, curl_z);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the Curl class in the source code. 