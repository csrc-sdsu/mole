# Utilities

This section documents the utility functions provided by the MOLE library. For complete API details, see the Complete Class Reference section in the C++ API documentation.

## Available Utilities

MOLE provides several utility functions for numerical simulations:

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Utility
     - Description
   * - :doc:`Grid <utilities/grid>`
     - Utilities for creating and manipulating grids
   * - :doc:`Sparse Matrix <utilities/sparse>`
     - Utilities for working with sparse matrices
   * - :doc:`Math <utilities/math>`
     - Mathematical utility functions
   * - :doc:`I/O <utilities/io>`
     - Input/output utility functions
```

## Detailed Documentation

```{toctree}
:maxdepth: 1

utilities/grid.md
utilities/sparse.md
utilities/math.md
utilities/io.md
```

For complete API details of all utility functions, see the Class Reference section in the C++ API documentation.

```{eval-rst}
.. raw:: html

   <div class="on-this-page">
     <div class="on-this-page-title">On This Page</div>
     <ul>
       <li><a href="#grid-utilities">Grid Utilities</a></li>
       <li><a href="#math-utilities">Math Utilities</a></li>
       <li><a href="#io-utilities">I/O Utilities</a></li>
       <li><a href="#utility-functions">Utility Functions</a></li>
     </ul>
   </div>

   <style>
     .on-this-page {
       position: sticky;
       top: 20px;
       float: right;
       width: 200px;
       padding: 10px;
       margin-left: 20px;
       background-color: #f8f9fa;
       border: 1px solid #e1e4e5;
       border-radius: 5px;
     }
     
     .on-this-page-title {
       font-weight: bold;
       margin-bottom: 10px;
     }
     
     .on-this-page ul {
       list-style-type: none;
       padding-left: 10px;
       margin: 0;
     }
     
     .on-this-page li {
       margin-bottom: 5px;
     }
     
     .on-this-page a {
       text-decoration: none;
     }
     
     .collapsible-section {
       margin-bottom: 20px;
     }
     
     .collapsible-header {
       background-color: #f6f6f6;
       padding: 10px;
       cursor: pointer;
       border: 1px solid #e1e4e5;
       border-radius: 5px 5px 0 0;
       font-weight: bold;
     }
     
     .collapsible-content {
       border: 1px solid #e1e4e5;
       border-top: none;
       padding: 10px;
       border-radius: 0 0 5px 5px;
       display: none;
     }
     
     .collapsible-header.active {
       background-color: #e1e4e5;
     }
     
     .collapsible-header.active + .collapsible-content {
       display: block;
     }
   </style>

   <script>
     document.addEventListener('DOMContentLoaded', function() {
       const headers = document.querySelectorAll('.collapsible-header');
       
       headers.forEach(header => {
         header.addEventListener('click', function() {
           this.classList.toggle('active');
           const content = this.nextElementSibling;
           if (content.style.display === 'block') {
             content.style.display = 'none';
           } else {
             content.style.display = 'block';
           }
         });
       });
     });
   </script>
```

## Grid Utilities

The MOLE library provides various utility functions for working with grids and meshes.

```{eval-rst}
.. note::
   For complete API details of the ``Utils`` class, see the :cpp:class:`Utils` class in the Class Reference.
```

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

```cpp
#include <mole/utils.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create a meshgrid
    std::vector<double> X, Y;
    mole::Utils::meshgrid(grid.x(), grid.y(), X, Y);
    
    // Use the meshgrid to initialize a field
    std::vector<double> field(grid.size());
    for (size_t i = 0; i < field.size(); ++i) {
        field[i] = std::sin(2 * M_PI * X[i]) * std::cos(2 * M_PI * Y[i]);
    }
    
    return 0;
}
```

```{eval-rst}
.. raw:: html

     </div>
   </div>

   <div class="collapsible-section">
     <div class="collapsible-header">API Details</div>
     <div class="collapsible-content">
```

```{eval-rst}
.. doxygenclass:: mole::Utils
   :members:
   :project: MoleCpp
```

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## Math Utilities

The MOLE library provides various mathematical utility functions for numerical operations.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

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

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## I/O Utilities

The MOLE library provides utility functions for input and output operations.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

```cpp
#include <mole/utils.h>
#include <mole/grid.h>
#include <vector>
#include <string>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create a field
    std::vector<double> field(grid.size());
    for (size_t i = 0; i < field.size(); ++i) {
        field[i] = /* some value */;
    }
    
    // Save the field to a file
    std::string filename = "field_data.txt";
    mole::Utils::saveField(field, grid, filename);
    
    // Load the field from a file
    std::vector<double> loaded_field;
    mole::Utils::loadField(loaded_field, grid, filename);
    
    return 0;
}
```

```{eval-rst}
.. raw:: html

     </div>
   </div>
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