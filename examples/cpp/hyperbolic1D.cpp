/**
 * Solving the 1D Linear Hyperbolic Advection Equation
 * with Periodic Boundary Conditions on a Staggered Mimetic Grid
 *
 * Equation:
 *   u_t + a u_x = 0
 *
 * Domain:
 *   0 <= x <= 1
 *
 * Initial Condition:
 *   u(x,0) = sin(2*pi*x)
 *
 * Boundary Conditions:
 *   Periodic boundary conditions are imposed so that waves leaving one
 *   side of the domain re-enter from the other side.
 *
 * Grid:
 *   The solution is stored on the 1D staggered MOLE grid
 *
 *      grid = [west, west + dx/2, west + 3dx/2, ..., east - dx/2, east]
 *
 *   The two endpoints are included as boundary/storage points, while the
 *   interior points are cell-centered.
 *
 * Spatial Discretization:
 *   The spatial operator uses MOLE's mimetic divergence and interpolation:
 *
 *      D = div(k,m,dx)
 *      I = interpol(m,0.5)
 *
 *   The advection operator is assembled as
 *
 *      -a*dt*2*D*I
 *
 *   matching the MATLAB staggered-grid structure.
 *
 * Time Integration:
 *   One startup step is computed using Explicit Euler, then the solution
 *   advances using the Leapfrog scheme:
 *
 *      U^{n+1} = U^{n-1} - 2*a*dt*D*I*U^n
 *
 * Exact Solution:
 *   u_exact(x,t) = sin(2*pi*(x - a*t))
 *
 * Output:
 *   The numerical and exact solutions are written to a data file and
 *   animated with GNUplot.
 */

#include "mole.h"
#include <armadillo>
#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>

using namespace arma;
using namespace std;

constexpr double pi = M_PI;

int main()
{
    // Parameters
    const double a    = 1.0;
    const double west = 0.0;
    const double east = 1.0;

    const uint16_t k = 2;
    const uint32_t m = 50;

    const double dx = (east - west) / static_cast<double>(m);

    const double tf = 1.0;
    const double dt = dx / std::abs(a);

    // Staggered grid:
    // [west, west+dx/2, west+3dx/2, ..., east-dx/2, east]
    vec grid(m + 2, fill::zeros);

    grid(0) = west;

    for (uint32_t j = 1; j <= m; ++j) {
        grid(j) = west + dx / 2.0 + static_cast<double>(j - 1) * dx;
    }

    grid(m + 1) = east;

    // Initial condition
    vec U = sin(2.0 * pi * grid);

    // Mimetic divergence and interpolation operators
    Divergence DivOp(k, m, dx);
    Interpol   IntOp(m, 0.5);

    sp_mat D = sp_mat(DivOp);
    sp_mat I = sp_mat(IntOp);

    // Periodic boundary conditions imposed on the divergence operator.
    D(0, 1) = 1.0 / (2.0 * dx);
    D(0, D.n_cols - 2) = -1.0 / (2.0 * dx);

    D(D.n_rows - 1, 1) = 1.0 / (2.0 * dx);
    D(D.n_rows - 1, D.n_cols - 2) = -1.0 / (2.0 * dx);

    // Mimetic staggered advection update operator.
    sp_mat Adv = -a * dt * 2.0 * D * I;

    // Number of time steps
    const int steps = static_cast<int>(std::round(tf / dt));

    // Output data for all time slices
    ofstream dataFile("hyperbolic1D_results.dat");

    if (!dataFile) {
        cerr << "Error: could not open hyperbolic1D_results.dat\n";
        return EXIT_FAILURE;
    }

    // Leapfrog needs two time levels.
    vec Uold = U;
    vec Ucur = Uold + 0.5 * Adv * Uold;

    for (int n = 1; n <= steps; ++n) {
        const double t = n * dt;

        for (uword j = 0; j < grid.n_elem; ++j) {
            const double x = grid(j);
            const double u_exact = std::sin(2.0 * pi * (x - a * t));

            dataFile << x << " " << Ucur(j) << " " << u_exact << "\n";
        }

        dataFile << "\n\n";

        vec Unext = Uold + Adv * Ucur;

        Uold = Ucur;
        Ucur = Unext;
    }

    dataFile.close();

    // GNUplot script
    ofstream scriptFile("hyperbolic1D_plot.gnu");

    if (!scriptFile) {
        cerr << "Error: could not create hyperbolic1D_plot.gnu\n";
        return EXIT_FAILURE;
    }

    scriptFile << "set terminal qt\n";
    scriptFile << "set xlabel 'x'\n";
    scriptFile << "set ylabel 'u(x,t)'\n";
    scriptFile << "set xrange [" << west << ":" << east << "]\n";
    scriptFile << "set yrange [-1.5:1.5]\n";
    scriptFile << "set grid\n";
    scriptFile << "unset key\n";
    scriptFile << "do for [i=0:" << steps - 1 << "] {\n";
    scriptFile << "    plot 'hyperbolic1D_results.dat' index i using 1:2 "
               << "with linespoints title sprintf('Numerical, t = %.2f', (i+1)*"
               << dt << "), "
               << "'hyperbolic1D_results.dat' index i using 1:3 "
               << "with lines title 'Exact Solution'\n";
    scriptFile << "    pause 0.1\n";
    scriptFile << "}\n";

    scriptFile.close();

    // Run GNUplot
    int status = std::system("gnuplot -persistent hyperbolic1D_plot.gnu");

    if (status != 0) {
        cerr << "Error: failed to execute GNUplot.\n";
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
