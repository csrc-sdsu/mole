# Sparse Matrix Utilities

The MOLE library provides utility functions for working with sparse matrices.

```{eval-rst}
.. note::
   For complete API details of the sparse matrix utilities, see the :cpp:class:`Utils` class in the Class Reference.
```

## Usage Example

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
    arma::sp_mat C = mole::Utils::spkron(A, B);
    arma::sp_mat D = mole::Utils::spjoin_rows(A, B);
    arma::sp_mat E = mole::Utils::spjoin_cols(A, B);
    
    // Create a vector
    arma::vec b(10, arma::fill::ones);
    
    // Solve linear system
    arma::vec x = mole::Utils::spsolve_eigen(A, b);
    
    return 0;
}
```

## Sparse Matrix Operations

```cpp
#include <mole/utils.h>
#include <Eigen/Sparse>
#include <iostream>

int main() {
    // Create sparse matrices using Eigen
    Eigen::SparseMatrix<double> A(10, 10);
    Eigen::SparseMatrix<double> B(10, 10);
    
    // Fill matrices
    for (int i = 0; i < 10; ++i) {
        A.coeffRef(i, i) = 1.0;
        B.coeffRef(i, i) = 2.0;
    }
    
    // Create right-hand side vector
    Eigen::VectorXd b = Eigen::VectorXd::Ones(10);
    
    // Solve linear system
    Eigen::VectorXd x = mole::Utils::spsolve_eigen(A, b);
    
    // Print solution
    std::cout << "Solution: " << std::endl << x << std::endl;
    
    return 0;
}
```

## API Details

```{eval-rst}
.. doxygenfunction:: mole::Utils::spkron
   :project: MoleCpp

.. doxygenfunction:: mole::Utils::spjoin_rows
   :project: MoleCpp

.. doxygenfunction:: mole::Utils::spjoin_cols
   :project: MoleCpp

.. doxygenfunction:: mole::Utils::spsolve_eigen
   :project: MoleCpp
``` 