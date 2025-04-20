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
#include <fstream>
#include <cmath>
#include <armadillo>
#include "mole.h"

using namespace arma;
using namespace std;

int main() {
    // --- Parameters ---
    constexpr double west = -15.0;
    constexpr double east = 15.0;
    constexpr int k = 2;
    constexpr int m = 300;
    constexpr double dx = (east - west) / m;
    constexpr double t_end = 10.0;
    constexpr double dt = dx;
    const int steps = static_cast<int>(t_end / dt);

    // --- Operators ---
    Divergence D(k, m, dx);
    Interpol I(m, 1.0);
    mat D_matrix = (-dt / 2.0) * mat(D) * mat(I);

    // --- Grid and Initial Condition ---
    vec xgrid(m + 2);
    xgrid(0) = west;
    xgrid(m + 1) = east;
    for (int i = 1; i <= m; ++i) {
        xgrid(i) = west + (i - 0.5) * dx;
    }
    vec U = exp(-square(xgrid) / 50.0);

    // --- Output file ---
    ofstream out("burgers1D_output.dat");
    if (!out.is_open()) {
        cerr << "Error: Cannot open output file." << endl;
        return 1;
    }

    // --- Time Loop ---
    for (int step = 0; step <= steps; ++step) {
        double time = step * dt;

        // Write output every N steps
        if (step % 50 == 0) {
            out << "# Time = " << time << endl;
            for (size_t i = 0; i < xgrid.n_elem; ++i) {
                out << xgrid(i) << " " << U(i) << "\n";
            }
            out << "\n\n"; // Blank lines for Gnuplot indexing
        }

        // Forward Euler update
        U = U + D_matrix * square(U);
    }
    out.close();

    // --- Gnuplot script ---
    ofstream gp("gp_script");
    if (!gp.is_open()) {
        cerr << "Error: Cannot create Gnuplot script." << endl;
        return 1;
    }

    gp << "set terminal qt\n";
    gp << "set xlabel 'x'\n";
    gp << "set ylabel 'U(x, t)'\n";
    gp << "set xrange [" << west << ":" << east << "]\n";
    gp << "set yrange [0:1]\n";
    gp << "set grid\n";
    gp << "do for [i=0:" << steps / 50 << "] {\n";
    gp << "  plot 'burgers1D_output.dat' index i using 1:2 with lines title sprintf('Time = %.2f', i * " << 50 * dt << ")\n";
    gp << "  pause 0.1\n";
    gp << "}\n";
    gp.close();

    // --- Launch Gnuplot ---
    system("gnuplot -persistent gp_script");

    return 0;
}
