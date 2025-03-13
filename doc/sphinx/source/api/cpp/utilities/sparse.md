# Sparse Matrix Utilities

The MOLE library provides utilities for working with sparse matrices.

## Usage Example

```cpp
#include <vector>

int main() {
    // Example of using sparse matrix utilities
    
    // Create sparse matrices
    sp_mat A(10, 10);
    sp_mat B(10, 10);
    
    // Fill matrices with values
    // ...
    
    // Kronecker product of sparse matrices
    sp_mat C = Utils::spkron(A, B);
    
    // Join sparse matrices
    sp_mat D = Utils::spjoin_rows(A, B);
    sp_mat E = Utils::spjoin_cols(A, B);
    
    // Solve sparse system
    std::vector<double> b(10, 1.0);
    std::vector<double> x = Utils::spsolve_eigen(A, b);
    
    return 0;
}
```

## API Details

For complete API details, please refer to the sparse matrix utility functions in the source code. 