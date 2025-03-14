# Boundary Conditions

This section documents the boundary condition implementations provided by the MOLE library. For complete API details, see the Complete Class Reference section in the C++ API documentation.

## Available Boundary Conditions

MOLE provides several boundary condition types for numerical simulations:

```{eval-rst}
.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Boundary Condition
     - Description
   * - Dirichlet
     - Specifies the value of the solution on the boundary
   * - Neumann
     - Specifies the normal derivative of the solution on the boundary
   * - Robin
     - Specifies a linear combination of the value and normal derivative
   * - Mixed
     - Allows different types of boundary conditions on different parts of the boundary
   * - Periodic
     - Implements periodic boundary conditions
```

## Implementation Details

The MOLE library implements boundary conditions using sparse matrices that can be applied to operators or directly to solution vectors. The boundary condition implementations include:

### MixedBC Class

The `MixedBC` class allows you to specify different types of boundary conditions (Dirichlet, Neumann, or Robin) on different parts of the domain boundary. It supports 1D, 2D, and 3D domains.

### RobinBC Class

The `RobinBC` class implements Robin boundary conditions, which are a linear combination of Dirichlet and Neumann conditions. It supports 1D, 2D, and 3D domains.

## Usage Examples

### Dirichlet Boundary Conditions

Dirichlet boundary conditions specify the value of the solution on the boundary.

```cpp
// Example of applying Dirichlet boundary conditions using MixedBC
#include <vector>
#include <string>

int main() {
    // Create a 1D grid with 100 cells
    u32 m = 100;
    Real dx = 0.01;
    
    // Create Dirichlet boundary conditions on both ends
    std::string left = "Dirichlet";
    std::vector<Real> coeffs_left = {1.0}; // Coefficient for Dirichlet condition
    std::string right = "Dirichlet";
    std::vector<Real> coeffs_right = {1.0}; // Coefficient for Dirichlet condition
    
    // Create the boundary condition operator
    MixedBC bc(4, m, dx, left, coeffs_left, right, coeffs_right);
    
    // Use the boundary condition in your simulation
    // ...
    
    return 0;
}
```

### Neumann Boundary Conditions

Neumann boundary conditions specify the normal derivative of the solution on the boundary.

```cpp
// Example of applying Neumann boundary conditions using MixedBC
#include <vector>
#include <string>

int main() {
    // Create a 1D grid with 100 cells
    u32 m = 100;
    Real dx = 0.01;
    
    // Create Neumann boundary conditions on both ends
    std::string left = "Neumann";
    std::vector<Real> coeffs_left = {1.0}; // Coefficient for Neumann condition
    std::string right = "Neumann";
    std::vector<Real> coeffs_right = {1.0}; // Coefficient for Neumann condition
    
    // Create the boundary condition operator
    MixedBC bc(4, m, dx, left, coeffs_left, right, coeffs_right);
    
    // Use the boundary condition in your simulation
    // ...
    
    return 0;
}
```

### Robin Boundary Conditions

Robin boundary conditions are a linear combination of Dirichlet and Neumann conditions.

```cpp
// Example of applying Robin boundary conditions
#include <vector>

int main() {
    // Create a 1D grid with 100 cells
    u32 m = 100;
    Real dx = 0.01;
    
    // Create Robin boundary conditions
    // α * u + β * ∂u/∂n = γ
    Real alpha = 1.0;
    Real beta = 0.5;
    
    // Create the boundary condition operator
    RobinBC robin(4, m, dx, alpha, beta);
    
    // Use the boundary condition in your simulation
    // ...
    
    return 0;
}
```

### Mixed Boundary Conditions in 2D

For 2D problems, you can specify different boundary conditions on each side of the domain.

```cpp
// Example of applying mixed boundary conditions in 2D
#include <vector>
#include <string>

int main() {
    // Create a 2D grid
    u32 m = 50; // cells in x-direction
    u32 n = 50; // cells in y-direction
    Real dx = 0.02;
    Real dy = 0.02;
    
    // Specify boundary conditions for each side
    std::string left = "Dirichlet";
    std::vector<Real> coeffs_left = {1.0};
    
    std::string right = "Neumann";
    std::vector<Real> coeffs_right = {0.0};
    
    std::string bottom = "Dirichlet";
    std::vector<Real> coeffs_bottom = {1.0};
    
    std::string top = "Robin";
    std::vector<Real> coeffs_top = {0.5, 0.5};
    
    // Create the boundary condition operator
    MixedBC bc(4, m, dx, n, dy, left, coeffs_left, right, coeffs_right, 
               bottom, coeffs_bottom, top, coeffs_top);
    
    // Use the boundary condition in your simulation
    // ...
    
    return 0;
}
```

For more details on implementing boundary conditions in your simulations, please refer to the examples in the `examples` directory of the MOLE source code.

```{eval-rst}
.. raw:: html

   <div class="on-this-page">
     <div class="on-this-page-title">On This Page</div>
     <ul>
       <li><a href="#robin-boundary-conditions">Robin Boundary Conditions</a></li>
       <li><a href="#dirichlet-boundary-conditions">Dirichlet Boundary Conditions</a></li>
       <li><a href="#neumann-boundary-conditions">Neumann Boundary Conditions</a></li>
       <li><a href="#mixed-boundary-conditions">Mixed Boundary Conditions</a></li>
       <li><a href="#periodic-boundary-conditions">Periodic Boundary Conditions</a></li>
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

## Dirichlet Boundary Conditions

Dirichlet boundary conditions specify the value of the solution on the boundary.

```{eval-rst}
.. note::
   For complete API details of the ``DirichletBC`` class, see the :cpp:class:`DirichletBC` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/boundary_conditions.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create Dirichlet boundary conditions
    mole::DirichletBC bc(grid);
    
    // Set boundary values using a function
    bc.setValues([](double x, double y) { 
        return x*x + y*y; 
    });
    
    // Apply boundary conditions to a field
    std::vector<double> field(grid.size());
    bc.apply(field);
    
    return 0;
}
```

## Neumann Boundary Conditions

Neumann boundary conditions specify the value of the normal derivative of the solution on the boundary.

```{eval-rst}
.. note::
   For complete API details of the ``NeumannBC`` class, see the :cpp:class:`NeumannBC` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/boundary_conditions.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create Neumann boundary conditions
    mole::NeumannBC bc(grid);
    
    // Set boundary derivative values using a function
    bc.setValues([](double x, double y) { 
        return 2*x + 2*y; 
    });
    
    // Apply boundary conditions to a field
    std::vector<double> field(grid.size());
    bc.apply(field);
    
    return 0;
}
```

## Robin Boundary Conditions

Robin boundary conditions are a type of boundary condition that combines aspects of both Dirichlet and Neumann boundary conditions.

```{eval-rst}
.. note::
   For complete API details of the ``RobinBC`` class, see the :cpp:class:`RobinBC` class in the Class Reference.
```

```{eval-rst}
.. raw:: html

   <div class="collapsible-section">
     <div class="collapsible-header">Usage Example</div>
     <div class="collapsible-content">
```

```cpp
#include <mole/boundary_conditions.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create Robin boundary condition
    // α * u + β * ∂u/∂n = γ
    double alpha = 1.0;
    double beta = 0.5;
    double gamma = 0.0;
    
    mole::RobinBC robin(grid, alpha, beta, gamma);
    
    // Apply boundary condition to a field
    std::vector<double> field(grid.size());
    // Initialize field...
    
    robin.apply(field);
    
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

```{note}
The Robin boundary condition (RobinBC) class is planned for future implementation but is not yet available in the MOLE library.
```

```{eval-rst}
```

```{note}
The RobinBC class is planned for future implementation but is not yet available in the codebase.
```

```{eval-rst}
.. raw:: html

     </div>
   </div>
```

## Mixed Boundary Conditions

Mixed boundary conditions allow different types of boundary conditions on different parts of the boundary.

```{eval-rst}
.. note::
   For complete API details of the ``MixedBC`` class, see the :cpp:class:`MixedBC` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/boundary_conditions.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Define boundary condition types
    std::string left = "dirichlet";
    std::string right = "neumann";
    std::string bottom = "dirichlet";
    std::string top = "robin";
    
    // Define boundary condition coefficients
    std::vector<double> coeffs_left = {1.0};
    std::vector<double> coeffs_right = {0.0};
    std::vector<double> coeffs_bottom = {0.0};
    std::vector<double> coeffs_top = {1.0, 0.5};
    
    // Create mixed boundary conditions
    mole::MixedBC bc(2, grid.nx(), grid.dx(), grid.ny(), grid.dy(),
                    left, coeffs_left, right, coeffs_right,
                    bottom, coeffs_bottom, top, coeffs_top);
    
    // Apply boundary conditions to a field
    std::vector<double> field(grid.size());
    bc.apply(field);
    
    return 0;
}
```

## Boundary Condition Utilities

Utility functions for working with boundary conditions.

```{eval-rst}
.. note::
   For complete API details of the boundary condition utilities, see the ``bc`` namespace in the Class Reference.
```

### Usage Example

```cpp
#include <mole/boundary_conditions.h>
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
    
    // Apply boundary extraction
    std::vector<double> boundary_values;
    mole::bc::extractBoundary(grid, field, boundary_values);
    
    // Apply boundary injection
    std::vector<double> new_boundary_values(boundary_values.size());
    for (size_t i = 0; i < new_boundary_values.size(); ++i) {
        new_boundary_values[i] = 2.0 * boundary_values[i];
    }
    mole::bc::injectBoundary(grid, new_boundary_values, field);
    
    return 0;
} 