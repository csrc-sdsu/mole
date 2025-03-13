# Operators

This section documents the mimetic operators provided by the MOLE library. For complete API details, see the Complete Class Reference section in the C++ API documentation.

## Available Operators

MOLE provides several mimetic operators for numerical simulations:

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Operator
     - Description
   * - :doc:`Gradient <operators/gradient>`
     - Computes the gradient of a scalar field
   * - :doc:`Divergence <operators/divergence>`
     - Computes the divergence of a vector field
   * - :doc:`Curl <operators/curl>`
     - Computes the curl of a vector field
   * - :doc:`Laplacian <operators/laplacian>`
     - Computes the Laplacian of a scalar field
   * - :doc:`Interpolation <operators/interpolation>`
     - Performs interpolation operations
```

## Detailed Documentation

```{toctree}
:maxdepth: 1

operators/gradient.md
operators/divergence.md
operators/curl.md
operators/laplacian.md
operators/interpolation.md
```

For complete API details of all operators, see the Class Reference section in the C++ API documentation.

## Gradient Operator

The gradient operator computes the gradient of a scalar field.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

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

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## Divergence Operator

The divergence operator computes the divergence of a vector field.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

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

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## Curl Operator

The curl operator computes the curl of a vector field.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

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

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## Laplacian Operator

The Laplacian operator computes the Laplacian of a scalar field.

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

```cpp
#include <vector>
#include <cmath>

int main() {
    // Create a 2D grid
    u32 m = 50; // cells in x-direction
    u32 n = 50; // cells in y-direction
    Real dx = 0.02;
    Real dy = 0.02;
    
    // Create Laplacian operator
    u16 k = 4; // Order of accuracy
    Laplacian lap(k, m, dx, n, dy);
    
    // Create scalar field
    std::vector<double> f(m*n);
    
    // Initialize scalar field
    for (u32 i = 0; i < m; ++i) {
        for (u32 j = 0; j < n; ++j) {
            u32 idx = i + j*m;
            double x = i * dx;
            double y = j * dy;
            
            f[idx] = std::sin(M_PI * x) * std::sin(M_PI * y);
        }
    }
    
    // Compute Laplacian
    std::vector<double> result = lap.apply(f);
    
    return 0;
}
```

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

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