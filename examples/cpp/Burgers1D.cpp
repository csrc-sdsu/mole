
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
#include <iostream>
#include <armadillo>
#include <cmath>
#include <cstdio>     // for popen
#include "mole.h"
#include "utils.h"

using namespace arma;
using namespace std;

int main() {
    constexpr double west = -15.0;
    constexpr double east = 15.0;
    constexpr int k = 2;
    constexpr int m = 300;

    double dx = (east - west) / m;
    double t = 10.0;
    double dt = dx;

    // Mimetic divergence and interpolation (sparse)
    Divergence D(k, m, dx);
    Interpol I(m, 1.0);

    // Grid setup
    vec xgrid(m + 2);
    xgrid(0) = west;
    xgrid(m + 1) = east;
    for (int i = 1; i <= m; ++i) {
        xgrid(i) = west + (i - 0.5) * dx;
    }

    // Initial condition
    vec U = exp(-square(xgrid) / 50.0);

    // Check matrix dimensions if needed
    sp_mat D_sp = sp_mat(D);
    sp_mat I_sp = sp_mat(I);
    if (D_sp.n_cols != I_sp.n_rows || I_sp.n_cols != U.n_rows) {
        cerr << "Error: Incompatible matrix dimensions!" << endl;
        return 1;
    }

    int total_steps = t / dt;
    int plot_interval = total_steps / 5;

    // Gnuplot for visualization
    FILE* gnuplotPipe = popen("gnuplot -persist", "w");
    if (!gnuplotPipe) {
        cerr << "Error: Could not open Gnuplot." << endl;
        return 1;
    }

    for (int step = 0; step <= total_steps; ++step) {
        double time = step * dt;

        // Explicit time step: U = U + (-dt/2) * D * (I * U²)
        U = U + (-dt / 2.0) * (D_sp * (I_sp * square(U)));

        if (step % plot_interval == 0) {
            double area = Utils::trapz(xgrid, U);
            cout << "Time step: " << step
                 << ", Time: " << time
                 << ", Trapz Area: " << area
                 << ", U_min: " << U.min()
                 << ", U_max: " << U.max()
                 << ", U_center: " << U(U.n_elem / 2)
                 << endl;

            // Plot with Gnuplot
            fprintf(gnuplotPipe, "reset\n");
            fprintf(gnuplotPipe, "set title '1D Inviscid Burgers'' Equation'\n");
            fprintf(gnuplotPipe, "set xlabel 'x'\n");
            fprintf(gnuplotPipe, "set ylabel 'U(x,t)'\n");
            fprintf(gnuplotPipe, "set grid\n");
            fprintf(gnuplotPipe, "plot '-' using 1:2 with lines lw 2 title 't = %.2f'\n", time);

            for (uword i = 0; i < xgrid.n_elem; ++i)
                fprintf(gnuplotPipe, "%f %f\n", xgrid(i), U(i));

            fprintf(gnuplotPipe, "e\n");
            fflush(gnuplotPipe);
        }
    }

    pclose(gnuplotPipe);
    return 0;
}
