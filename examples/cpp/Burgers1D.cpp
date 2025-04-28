
/**
 * Solving the 1D Advection Equation using a Mimetic Finite Difference Scheme
 *
 * Equation: ∂U/∂t + ∂(U²)/∂x = 0  (Nonlinear Burgers' Equation in conservative form)
 * Domain:   x ∈ [-15, 15] with m = 300 grid cells
 * Time:     Simulated until t = 10.0 with time step dt = dx (CFL condition)
 * Initial Condition: U(x,0) = exp(-x² / 50)
 * Boundary Conditions: Mimetic divergence and interpolation operators applied (implicit treatment)
 *
 * Solution is computed using a staggered grid approach, explicit time-stepping, 
 * and mimetic finite difference operators for divergence and interpolation.
 */  
#include <armadillo>
#include <cmath>
#include <cstdlib>    // for EXIT_SUCCESS / EXIT_FAILURE
#include <fstream>
#include <iostream>
#include <string>
#include <iomanip>
#include "mole.h"
#include "utils.h"

int main() {
    constexpr double west = -15.0;
    constexpr double east = 15.0;
    constexpr int k = 2;
    constexpr int m = 300;
    constexpr double t = 10.0;

    const double dx = (east - west) / m;
    const double dt = dx;

    Divergence D(k, m, dx);
    Interpol I(m, 1.0);

    // Spatial grid (including ghost cells)
    arma::vec xgrid(m + 2);
    xgrid(0) = west;
    xgrid(m + 1) = east;
    for (int i = 1; i <= m; ++i) {
        xgrid(i) = west + (i - 0.5) * dx;
    }

    // Initial condition
    arma::vec U = arma::exp(-arma::square(xgrid) / 50.0);

    // Sanity check: matrix dimensions
    if (D.n_cols != I.n_rows || I.n_cols != U.n_rows) {
        std::cerr << "Error: Incompatible matrix dimensions!" << std::endl;
        return EXIT_FAILURE;
    }

    int total_steps = static_cast<int>(t / dt);
    int plot_interval = total_steps / 5;

    for (int step = 0; step <= total_steps; ++step) {
        double time = step * dt;

        // Explicit update
        U += (-dt / 2.0) * (D * (I * arma::square(U)));

        if (step % plot_interval == 0) {
            double area = Utils::trapz(xgrid, U);
            std::cout << "Time step: " << step
                      << ", Time: " << time
                      << ", Trapz Area: " << area
                      << ", U_min: " << U.min()
                      << ", U_max: " << U.max()
                      << ", U_center: " << U(U.n_elem / 2)
                      << std::endl;

            std::string filename = "output_step_" + std::to_string(step) + ".dat";
            std::ofstream outfile(filename);
            if (!outfile) {
                std::cerr << "Error: Could not open file for writing: " << filename << std::endl;
                return EXIT_FAILURE;
            }

            outfile << "# x    U(x)\n";
            for (arma::uword i = 0; i < xgrid.n_elem; ++i) {
                outfile << std::setw(12) << xgrid(i) << " "
                        << std::setw(12) << U(i) << "\n";
            }
        }
    }

    return EXIT_SUCCESS;
}



