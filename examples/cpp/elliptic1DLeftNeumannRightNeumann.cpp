
/**
 * this example uses mole to solve the 1d bvp -u''= x - 1/2
 * with homogeneous neumann conditions u'(0) = 0, u'(1) = 0
 * exact solution: u(x) = constant + x^2/4 - x^3/6
 */

#include "mole.h"
#include <iostream>

int main() {

    const int k = 2;
    const int m = 10;
    const Real dx = 1.0 / m;
    const Real a = 0;   // left boundary
    const Real b = 1;   // right boundary

    // Mimetic operators
    Laplacian L(k, m, dx);
    const Real d = 0; // Dirichlet coeff
    const Real n = 1; // Neumann coeff
    RobinBC BC(k, m, dx, d, n);
    L += BC;

    // 1D grid
    vec grid(m + 2);
    grid(0) = a;
    grid(1) = grid(0) + dx / 2.0;
    for (int i = 2; i <= m; i++) {
        grid(i) = grid(i - 1) + dx;
    }
    grid(m + 1) = b;

    // RHS
    vec rhs(m+2); rhs.zeros();
    for (int i=1; i<=m; ++i) {
        rhs(i) = -(grid(i) - 0.5);
    }
    rhs(0) = 0.0;
    rhs(m+1) = 0.0;

    // Solve the system
    #ifdef EIGEN
        // Use eigen if available
        vec sol = Utils:: spsolve_eigen(L, rhs);
    #else
        vec sol = spsolve(L, rhs);
    #endif

    // shift
    const Real val = sol(0);
    for (int j = 0; j < m+2; ++j) {
        sol(j) -= val;
    }

    // Create a GNUplot script file
    std::ofstream plot_script("plot.gnu");
    if (!plot_script) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }
    plot_script << "set title \"-u'' = x - 1/2, u'(0) = 0, u'(1) = 0\"\n";
    plot_script << "set xlabel 't'\n";
    plot_script << "set ylabel 'y'\n";
    plot_script << "plot '-' using 1:2 with lines\n";

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