 /**
 * @file elliptic1DNonHomogeneousDirichlet.cpp
 * @brief Solves the 1D linear equation -u'' = 1
 *
 * ## Spatial Domains:
 * - The spatial domain is [0, 1]
 * - Interior points are spaced by dx = (b - a) / m.
 *
 * ## Boundary Conditions:
 *      u(0) = 1/2, u(1) = 1/2
 *
 * The solution is computed numerically, and the result is compared with the exact solution:
 *      u_exact(x) = (-x^2 + x + 1)/2
 *
 * The results are saved to a file "plot.gnu" and visualized using GNUplot.
*/

#include "mole.h"
#include <iostream>

int main() {

    const int k = 2;
    const int m = 2 * k + 1;
    const Real dx = 1.0 / m;
    const Real a = 0;   // left boundary
    const Real b = 1;   // right boundary
    const Real left_dirichlet = 0.5;
    const Real right_dirichlet = 0.5;

    // Mimetic operators
    Laplacian L(k, m, dx);
    const Real d = 1; // Dirichlet coeff
    const Real n = 0; // Neumann coeff
    RobinBC BC(k, m, dx, d, n);
    L += BC;

    // 1D grid
    arma::vec grid(m + 2);
    grid(0) = a;
    grid(1) = grid(0) + dx / 2.0;
    for (int i = 2; i <= m; i++) {
        grid(i) = grid(i - 1) + dx;
    }
    grid(m + 1) = b;

    // RHS
    arma::vec rhs(m+2);
    rhs.fill(-1.0);
    rhs(0) = left_dirichlet;
    rhs(m+1) = right_dirichlet;

    // Solve the system
    #ifdef EIGEN
        // Use eigen if available
        arma::vec sol = Utils:: spsolve_eigen(L, rhs);
    #else
        arma::vec sol = spsolve(L, rhs);
    #endif

        // Create a GNUplot script file
    std::ofstream plot_script("plot.gnu");
    if (!plot_script) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }
    plot_script << "set title \"-u'' = 1, u(0) = 1/2, u(1) = 1/2\"\n";
    plot_script << "set xlabel 't'\n";
    plot_script << "set ylabel 'y'\n";
    plot_script << "plot '-' using 1:2 with lines title \"Estimated Solution\", "
                << "(-x**2 + x + 1)/2 with lines title \"Exact Solution\"\n";

    for (int i = 0; i <= m + 1; ++i) {
        plot_script << grid(i) << " " << sol(i) << "\n";
    }
    plot_script.close();

    // Execute GNUplot using the script
    if (system("gnuplot -persist plot.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }

    cout << sol;

    return 0;
}