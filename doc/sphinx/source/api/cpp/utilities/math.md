# Math Utilities

The MOLE library provides various mathematical utility functions for numerical operations.

```{eval-rst}
.. note::
   For complete API details of the math utilities, see the :cpp:class:`Utils` class in the Class Reference.
```

## Usage Example

```cpp
#include <mole/utils.h>
#include <Eigen/Sparse>
#include <vector>

int main() {
    // Create sparse matrices
    Eigen::SparseMatrix<double> A(10, 10);
    Eigen::VectorXd b(10);
    
    // Fill matrices with values
    // ...
    
    // Solve the system Ax = b
    Eigen::VectorXd x = mole::Utils::spsolve_eigen(A, b);
    
    return 0;
}
```

## Vector and Matrix Operations

```cpp
#include <mole/math.h>
#include <vector>
#include <iostream>

int main() {
    // Create vectors
    std::vector<double> a = {1.0, 2.0, 3.0};
    std::vector<double> b = {4.0, 5.0, 6.0};
    
    // Compute dot product
    double dot = mole::math::dot(a, b);
    std::cout << "Dot product: " << dot << std::endl;
    
    // Compute norm
    double norm = mole::math::norm(a);
    std::cout << "Norm: " << norm << std::endl;
    
    // Create matrices
    mole::Matrix A(3, 3);
    mole::Matrix B(3, 3);
    
    // Fill matrices
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            A(i, j) = i + j;
            B(i, j) = i * j;
        }
    }
    
    // Matrix operations
    mole::Matrix C = A * B;
    mole::Matrix D = A + B;
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygennamespace:: mole::math
   :members:
   :project: MoleCpp
``` 