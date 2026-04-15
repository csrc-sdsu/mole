#include "mole.h"
#include <armadillo>
#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdlib>

using namespace arma;
using namespace std;

constexpr double pi = 3.14159265358979323846;

//------------------------------------------------------------
// Periodic backward-difference matrix for a > 0 upwind scheme
//------------------------------------------------------------
sp_mat periodicBackwardDerivative(int m, double dx)
{
    // Grid has m+1 nodal points: x = 0, dx, ..., 1
    sp_mat D(m + 1, m + 1);

    // Backward difference:
    // (u_j - u_{j-1}) / dx
    D.diag(-1) = -ones<vec>(m);
    D.diag(0)  =  ones<vec>(m + 1);

    // Periodic wrap:
    // first row uses the left periodic neighbor
    D(0, m - 1) = -1.0;

    D /= dx;

    return D;
}

int main()
{
    //--------------------------------------------------------
    // 1. Parameters
    //--------------------------------------------------------
    const double a    = 1.0;
    const double west = 0.0;
    const double east = 1.0;

    const int m = 50;
    const double dx = (east - west) / static_cast<double>(m);

    const double tf = 1.0;
    const double dt = dx / std::abs(a);

    //--------------------------------------------------------
    // 2. Grid and initial condition
    //--------------------------------------------------------
    vec grid = regspace(west, dx, east);
    vec U = sin(2.0 * pi * grid);

    //--------------------------------------------------------
    // 3. Upwind spatial derivative for a > 0
    //--------------------------------------------------------
    sp_mat D = periodicBackwardDerivative(m, dx);

    //--------------------------------------------------------
    // 4. Explicit Euler update matrix
    //--------------------------------------------------------
    sp_mat A = speye<sp_mat>(D.n_rows, D.n_cols) - a * dt * D;

    //--------------------------------------------------------
    // 5. Number of time steps
    //--------------------------------------------------------
    const int steps = static_cast<int>(std::round(tf / dt));

    //--------------------------------------------------------
    // 6. Output data for all time slices
    //--------------------------------------------------------
    ofstream dataFile("hyperbolic1D_results.dat");
    if (!dataFile) {
        cerr << "Error: could not open hyperbolic1D_results.dat\n";
        return EXIT_FAILURE;
    }

    for (int n = 1; n <= steps; ++n) {
        U = A * U;
        const double t = n * dt;

        for (uword j = 0; j < grid.n_elem; ++j) {
            const double x = grid(j);
            const double u_exact = std::sin(2.0 * pi * (x - a * t));

            dataFile << x << " " << U(j) << " " << u_exact << "\n";
        }
        dataFile << "\n\n";
    }

    dataFile.close();

    //--------------------------------------------------------
    // 7. GNUplot script
    //--------------------------------------------------------
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
    scriptFile << "do for [i=0:" << steps - 1 << "] {\n";
    scriptFile << "    plot 'hyperbolic1D_results.dat' index i using 1:2 with linespoints title sprintf('Numerical, t = %.2f', (i+1)*" << dt << "), "
               << "'hyperbolic1D_results.dat' index i using 1:3 with lines title 'Exact Solution'\n";
    scriptFile << "    pause 0.1\n";
    scriptFile << "}\n";

    scriptFile.close();

    //--------------------------------------------------------
    // 8. Run GNUplot
    //--------------------------------------------------------
    int status = std::system("gnuplot -persistent hyperbolic1D_plot.gnu");
    if (status != 0) {
        cerr << "Error: failed to execute GNUplot.\n";
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
