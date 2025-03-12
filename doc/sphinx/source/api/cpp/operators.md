# Mimetic Operators

This section documents the core mimetic operators provided by the MOLE library. For complete API details, see the Complete Class Reference section in the C++ API documentation.

## Available Operators

MOLE provides several mimetic operators for numerical computations:

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Operator
     - Description
   * - :doc:`Divergence <operators/divergence>`
     - Computes the divergence of a vector field
   * - :doc:`Gradient <operators/gradient>`
     - Computes the gradient of a scalar field
   * - :doc:`Curl <operators/curl>`
     - Computes the curl of a vector field
   * - :doc:`Laplacian <operators/laplacian>`
     - Computes the Laplacian of a field
   * - :doc:`Interpolation <operators/interpolation>`
     - Performs interpolation operations
```

## Detailed Documentation

```{toctree}
:maxdepth: 1

operators/divergence.md
operators/gradient.md
operators/curl.md
operators/laplacian.md
operators/interpolation.md
```

For complete API details of all operator classes, see the Class Reference section in the C++ API documentation.

```{eval-rst}
.. raw:: html

   <div class="on-this-page">
     <div class="on-this-page-title">On This Page</div>
     <ul>
       <li><a href="#divergence-operator">Divergence Operator</a></li>
       <li><a href="#gradient-operator">Gradient Operator</a></li>
       <li><a href="#curl-operator">Curl Operator</a></li>
       <li><a href="#laplacian-operator">Laplacian Operator</a></li>
       <li><a href="#interpolation-operator">Interpolation Operator</a></li>
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

## Divergence Operator

The divergence operator computes the divergence of a vector field.

```{eval-rst}
.. note::
   For complete API details of the ``Divergence`` class, see the :cpp:class:`Divergence` class in the Class Reference.
```

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create vector field (u, v)
    std::vector<double> u(grid.size());
    std::vector<double> v(grid.size());
    
    // Initialize vector field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            u[idx] = x * y;
            v[idx] = x * x + y * y;
        }
    }
    
    // Create divergence operator
    mole::Divergence div(grid);
    
    // Compute divergence
    std::vector<double> result = div.apply(u, v);
    
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
.. doxygenclass:: mole::Divergence
   :members:
   :project: MoleCpp
```

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## Gradient Operator

The gradient operator computes the gradient of a scalar field.

```{eval-rst}
.. note::
   For complete API details of the ``Gradient`` class, see the :cpp:class:`Gradient` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create scalar field
    std::vector<double> f(grid.size());
    
    // Initialize scalar field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            f[idx] = x*x + y*y;
        }
    }
    
    // Create gradient operator
    mole::Gradient grad(grid);
    
    // Compute gradient
    std::vector<double> grad_x, grad_y;
    grad.apply(f, grad_x, grad_y);
    
    return 0;
}
```

## Laplacian Operator

The Laplacian operator computes the Laplacian of a field.

```{eval-rst}
.. note::
   For complete API details of the ``Laplacian`` class, see the :cpp:class:`Laplacian` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create scalar field
    std::vector<double> f(grid.size());
    
    // Initialize scalar field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            f[idx] = x*x + y*y;
        }
    }
    
    // Create Laplacian operator
    mole::Laplacian lap(grid);
    
    // Compute Laplacian
    std::vector<double> result = lap.apply(f);
    
    return 0;
}
```

## Interpolation Operator

The interpolation operator performs interpolation operations on fields.

```{eval-rst}
.. note::
   For complete API details of the ``Interpol`` class, see the :cpp:class:`Interpol` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create a field
    std::vector<double> field(grid.size());
    
    // Initialize field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            field[idx] = x*x + y*y;
        }
    }
    
    // Create interpolation operator with coefficient c = 0.5
    double c = 0.5;
    mole::Interpol interp(grid.nx(), grid.ny(), c, c);
    
    // Apply interpolation
    std::vector<double> result = interp.apply(field);
    
    return 0;
}
```

## Curl Operator

The curl operator computes the curl of a vector field.

```{eval-rst}
.. note::
   For complete API details of the ``Curl`` class, see the :cpp:class:`Curl` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/operators.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 3D grid
    mole::Grid3D grid(0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 20, 20, 20);
    
    // Create vector field (u, v, w)
    std::vector<double> u(grid.size());
    std::vector<double> v(grid.size());
    std::vector<double> w(grid.size());
    
    // Initialize vector field
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            for (int k = 0; k < grid.nz(); ++k) {
                int idx = i + j * grid.nx() + k * grid.nx() * grid.ny();
                double x = grid.x(i);
                double y = grid.y(j);
                double z = grid.z(k);
                
                u[idx] = y * z;
                v[idx] = x * z;
                w[idx] = x * y;
            }
        }
    }
    
    // Create curl operator
    mole::Curl curl(grid);
    
    // Compute curl
    std::vector<double> curl_x, curl_y, curl_z;
    curl.apply(u, v, w, curl_x, curl_y, curl_z);
    
    return 0;
} 