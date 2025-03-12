# Utilities

This section documents the utility classes and functions provided by the MOLE library. For complete API details, see the Complete Class Reference section in the C++ API documentation.

## Grid and Math Utilities

The `Utils` class provides various utility functions for working with grids, sparse matrices, and vectors.

```{eval-rst}
.. note::
   For complete API details of the ``Utils`` class, see the :cpp:class:`Utils` class in the Class Reference.
```

### Grid Usage Example

```cpp
#include <mole/grid.h>
#include <iostream>

int main() {
    // Create a 1D grid
    mole::Grid1D grid1d(0.0, 1.0, 100);
    
    // Print grid information
    std::cout << "1D Grid points: " << grid1d.size() << std::endl;
    std::cout << "1D Grid spacing: " << grid1d.spacing() << std::endl;
    
    // Create a 2D grid
    mole::Grid2D grid2d(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Print grid information
    std::cout << "2D Grid points: " << grid2d.size() << std::endl;
    std::cout << "2D Grid x-spacing: " << grid2d.dx() << std::endl;
    std::cout << "2D Grid y-spacing: " << grid2d.dy() << std::endl;
    
    // Create a 3D grid
    mole::Grid3D grid3d(0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 20, 20, 20);
    
    // Print grid information
    std::cout << "3D Grid points: " << grid3d.size() << std::endl;
    
    return 0;
}
```

### Math Utilities Example

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

## I/O Utilities

Input/output utility functions.

```{eval-rst}
.. note::
   For complete API details of the I/O utilities, see the ``io`` namespace in the Class Reference.
```

### Usage Example

```cpp
#include <mole/io.h>
#include <vector>
#include <string>

int main() {
    // Create a field
    std::vector<double> field = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0};
    
    // Save field to file
    mole::io::saveToFile(field, "field.dat");
    
    // Load field from file
    std::vector<double> loaded_field;
    mole::io::loadFromFile("field.dat", loaded_field);
    
    // Save field in VTK format for visualization
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 3, 3);
    mole::io::saveVTK(grid, field, "field.vtk", "field");
    
    return 0;
}
```

## Sparse Matrix Utilities Example

```cpp
#include <mole/utils.h>
#include <armadillo>

int main() {
    // Create sparse matrices
    arma::sp_mat A(10, 10);
    arma::sp_mat B(10, 10);
    
    // Fill matrices
    for (int i = 0; i < 10; ++i) {
        A(i, i) = 1.0;
        B(i, i) = 2.0;
    }
    
    // Use utility functions
    arma::sp_mat C = Utils::spkron(A, B);
    arma::sp_mat D = Utils::spjoin_rows(A, B);
    arma::sp_mat E = Utils::spjoin_cols(A, B);
    
    // Create a vector
    arma::vec b(10, arma::fill::ones);
    
    // Solve linear system
    arma::vec x = Utils::spsolve_eigen(A, b);
    
    return 0;
} 