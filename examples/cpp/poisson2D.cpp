/**
 * Solving the 2D Poisson Equation with Robin Boundary Conditions
 * 
 * Equation: ∇²u = f(x, y)  (Poisson Equation)
 * Domain:   Defined on a (m+2) x (n+2) grid with spacing dx, dy
 * Boundary Conditions:
 *   - Bottom boundary (y = 0) has a Dirichlet condition: u = 100
 *   - Other boundaries are subject to Robin conditions as defined in RobinBC
 *
 * Solution is computed using a Mimetic Finite Difference Laplacian and solved via Armadillo's sparse solver.
 */

#include <armadillo>
#include "mole.h"
#include <iomanip>
#include <iostream>
#include <cmath> // For std::abs

using namespace arma;

int main() {
    constexpr uint16_t k = 2;  // Order of accuracy
    constexpr uint32_t m = 5;  // Vertical resolution
    constexpr uint32_t n = 6;  // Horizontal resolution
    constexpr double dx = 1.0, dy = 1.0; // Grid spacing

    // Construct the 2D Mimetic Laplacian
    Laplacian L(k, m, n, dx, dy);
    RobinBC BC(k, m, dx, n, dy, 1.0, 0.0);
    L = L + BC;

    // Define RHS matrix and apply boundary conditions
    mat RHS = zeros(m + 2, n + 2);
    RHS.row(0).fill(100.0); // Known value at the bottom boundary

    // Convert RHS to a column vector
    vec rhs = vectorise(RHS);

    // Solve the system
    vec SOL = spsolve(L, rhs);

    // Reshape solution back to 2D form
    mat SOL2D = reshape(SOL, m + 2, n + 2);

    // Display solution without negative zeros or excessive decimal places
    std::cout << "2D Poisson Solution:\n";
    for (uint32_t i = 0; i < SOL2D.n_rows; ++i) {
        for (uint32_t j = 0; j < SOL2D.n_cols; ++j) {
            double value = SOL2D(i, j);
            if (std::abs(value) < 1e-10) {  // If value is very close to zero, set it to exactly 0.0
                value = 0.0;
            }

            // Adjust precision and remove unnecessary decimal places
            if (std::abs(value - std::round(value)) < 1e-4) {  // If value is close to an integer
                std::cout << std::fixed << std::setprecision(0) << value;  // No decimals
            } else {
                std::cout << std::fixed << std::setprecision(4) << value;  // Four decimal places
            }

            std::cout << "\t";  // Tab separation
        }
        std::cout << "\n";
    }

    return 0;
}
