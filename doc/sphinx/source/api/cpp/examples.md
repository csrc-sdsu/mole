# C++ Examples

This section provides examples of how to use the MOLE C++ API for various numerical computations.

## Basic Usage

### Creating a Grid

```cpp
#include <mole/grid.h>

int main() {
    // Create a 1D grid with 100 points
    mole::Grid1D grid(0.0, 1.0, 100);
    
    // Print grid information
    std::cout << "Grid points: " << grid.size() << std::endl;
    std::cout << "Grid spacing: " << grid.spacing() << std::endl;
    
    return 0;
}
```

### Computing Divergence

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

## Advanced Examples

### Solving Poisson's Equation

```cpp
#include <mole/operators.h>
#include <mole/solvers.h>
#include <mole/grid.h>
#include <vector>

int main() {
    // Create a 2D grid
    mole::Grid2D grid(0.0, 1.0, 0.0, 1.0, 100, 100);
    
    // Create Laplacian operator
    mole::Laplacian laplacian(grid);
    
    // Create right-hand side function (f = -2(x^2 + y^2))
    std::vector<double> f(grid.size());
    for (int i = 0; i < grid.nx(); ++i) {
        for (int j = 0; j < grid.ny(); ++j) {
            int idx = i + j * grid.nx();
            double x = grid.x(i);
            double y = grid.y(j);
            
            f[idx] = -2.0 * (x*x + y*y);
        }
    }
    
    // Set Dirichlet boundary conditions
    mole::DirichletBC bc(grid);
    bc.setValues([](double x, double y) { return x*x + y*y; });
    
    // Solve Poisson's equation
    mole::PoissonSolver solver(grid, laplacian, bc);
    std::vector<double> solution = solver.solve(f);
    
    return 0;
}
```

For more examples, please refer to the `examples` directory in the MOLE source code. 