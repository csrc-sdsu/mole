/**
 * @file hyperbolic1D_upwind.cpp
 * @brief Solves the 1D linear advection equation using finite differencing.
 *
 * The equation being solved is:
 *      ∂u/∂t + a ∂u/∂x = 0
 * where `u(x,t)` is the scalar quantity being advected, and `a` is the constant velocity.
 *
 * ## Spatial and Temporal Domains:
 * - The spatial domain is x ∈ [0,1].
 * - The temporal domain is t ∈ [0,1].
 * - The grid spacing is dx = (east - west) / m.
 * - The time step is chosen based on the CFL condition: dt = dx / |a|.
 *
 * ## Initial Condition:
 *      u(x,0) = sin(2πx),   for x ∈ [0,1]
 *
 * ## Boundary Conditions:
 * - Periodic boundary conditions are applied, meaning u(0,t) = u(1,t).
 * - The spatial derivative is discretized using backward, forward, or centered finite differences.
 *
 * The solution is computed iteratively, and the numerical result is compared with the exact solution:
 *      u_exact(x,t) = sin(2π(x - at)).
 *
 * The results are saved to a file ("results.dat") and visualized using GNUplot.
 */

#include "mole.h"
#include <iostream>
#include <cmath>

using namespace std::chrono_literals;
constexpr double pi = 3.14159;

sp_mat sidedNodalTemp(int m, double dx, const std::string& type) {

    // Create a sparse matrix of size (m+1) x (m+1)
    sp_mat S(m + 1, m + 1);
    if (type == "backward") {
        // Backward difference
        S.diag(-1) = -ones<vec>(m);  // Sub-diagonal
        S.diag(0) = ones<vec>(m + 1);    // Main diagonal
        S(0, m - 1) = -1;                // Wrap-around for periodic boundary
        S /= dx;
    } else if (type == "forward") {
        // Forward difference
        S.diag(0) = -ones<vec>(m + 1);   // Main diagonal
        S.diag(1) = ones<vec>(m);    // Super-diagonal
        S(m, 1) = 1;                     // Wrap-around for periodic boundary
        S /= dx;
    } else { // "centered"
        // Centered difference
        S.diag(-1) = -ones<vec>(m);  // Sub-diagonal
        S.diag(1) = ones<vec>(m);    // Super-diagonal
        S(0, m - 1) = -1;                // Wrap-around for periodic boundary
        S(m, 1) = 1;                     // Wrap-around for periodic boundary
        S /= (2 * dx);
    }

    return S;
}

int main()
{
    constexpr double a = 1.0;       // Velocity
    constexpr double west = 0.0;    // Domain's left limit
    constexpr double east = 1.0;    // Domain's right limit

    constexpr int m = 20;           // Number of cells
    constexpr double dx = (east - west) / m;  // Grid spacing

    constexpr double t = 1.0;       // Simulation time
    constexpr double dt = dx / std::abs(a);  // Time step based on CFL condition
    
    sp_mat S = sidedNodalTemp(m, dx, (a > 0) ? "backward" : "forward"); // Use "forward" if a < 0
    
    vec grid = arma::regspace(west, dx, east);
    vec U = sin(2 * pi * grid);

    S = speye<sp_mat>(S.n_rows, S.n_cols) - a * dt * S;
    
    constexpr int steps = t / dt;
    
    std::ofstream dataFile("results.dat");
    if (!dataFile) {
        std::cerr << "Error opening data file.\n";
        return 1;
    }

    // Write all time steps to a single data file
    for (int i = 1; i <= steps; ++i) {
        // Compute U^(n+1)
        U = S * U;

        // Store the data with an empty line between time steps for indexing in GNUplot
        for (size_t j = 0; j < grid.size(); ++j) {
            dataFile << grid[j] << " " << U[j] << " "
                     << std::sin(2 * pi * (grid[j] - a * i * dt)) << "\n";
        }
        dataFile << "\n\n"; // Separate time steps
    }
    dataFile.close();

    // Create the GNUplot script
    std::ofstream scriptFile("gp_script");
    if (!scriptFile) {
        std::cerr << "Error creating GNUplot script.\n";
        return 1;
    }

    scriptFile << "set terminal qt\n";
    scriptFile << "set xlabel 'x'\n";
    scriptFile << "set ylabel 'u(x,t)'\n";
    scriptFile << "set xrange [" << west << ":" << east << "]\n";
    scriptFile << "set yrange [-1.5:1.5]\n";
    scriptFile << "set grid\n";
    scriptFile << "do for [i=0:" << steps-1 << "] {\n";
    scriptFile << "    plot 'results.dat' index i using 1:2 with linespoints title sprintf('t = %.2f', i*" << dt << " + " << dt << "), "
                  "'results.dat' index i using 1:3 with lines title 'Exact Solution'\n";
    scriptFile << "    pause 0.1\n";
    scriptFile << "}\n";

    scriptFile.close();

    // Run GNUplot with the script
    system("gnuplot -persistent gp_script");
}
