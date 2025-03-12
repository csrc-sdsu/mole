# Boundary Conditions

This section documents the boundary condition classes and functions provided by the MOLE library. For complete API details, see the Complete Class Reference section in the C++ API documentation.

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

Robin boundary conditions specify a linear combination of the value and normal derivative of the solution on the boundary.

```{eval-rst}
.. note::
   For complete API details of the ``RobinBC`` class, see the :cpp:class:`RobinBC` class in the Class Reference.
```

### Usage Example

```cpp
#include <mole/boundary_conditions.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 50, 50);
    
    // Create Robin boundary conditions with coefficients a and b
    // a*u + b*du/dn = g
    double a = 1.0;
    double b = 0.5;
    mole::RobinBC bc(grid, a, b);
    
    // Set boundary function g using a function
    bc.setValues([](double x, double y) { 
        return x + y; 
    });
    
    // Apply boundary conditions to a field
    std::vector<double> field(grid.size());
    bc.apply(field);
    
    return 0;
}
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