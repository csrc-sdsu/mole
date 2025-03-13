# Math Utilities

The MOLE library provides various mathematical utility functions for numerical operations.

```{eval-rst}
.. note::
   For complete API details of the math utilities, see the :cpp:class:`Utils` class in the Class Reference.
```

## Usage Example

```cpp
#include <vector>
#include <cmath>

int main() {
    // Example of using math utilities
    
    // Create vectors
    std::vector<double> a = {1.0, 2.0, 3.0};
    std::vector<double> b = {4.0, 5.0, 6.0};
    
    // Vector operations
    std::vector<double> c(a.size());
    
    // Element-wise addition
    for (size_t i = 0; i < a.size(); ++i) {
        c[i] = a[i] + b[i];
    }
    
    // Element-wise multiplication
    for (size_t i = 0; i < a.size(); ++i) {
        c[i] = a[i] * b[i];
    }
    
    // Dot product
    double dot = 0.0;
    for (size_t i = 0; i < a.size(); ++i) {
        dot += a[i] * b[i];
    }
    
    // Norm calculation
    double norm = 0.0;
    for (size_t i = 0; i < a.size(); ++i) {
        norm += a[i] * a[i];
    }
    norm = std::sqrt(norm);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the math utility functions in the source code. 