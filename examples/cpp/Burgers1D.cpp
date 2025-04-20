
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
#include "mole.h"

using namespace arma;
using namespace std;

int main() {
    constexpr double west = -15.0;
    constexpr double east = 15.0;
    constexpr int k = 2;     // Operator's order of accuracy
    constexpr int m = 300;   // Number of cells

    double dx = (east - west) / m; // Grid spacing
    double t = 10.0; // Simulation time
    double dt = dx; // CFL condition for explicit schemes

    // Divergence and interpolation operators (matching MATLAB's dimensions)
    Divergence D(k, m, dx); // 1D Mimetic divergence operator
    Interpol I(m, 1.0); // 1D interpolator (upwind)

    // 1D Staggered grid (same as MATLAB)
    vec xgrid(m + 2);
    xgrid(0) = west;
    xgrid(m + 1) = east;
    for (int i = 1; i <= m; ++i) {
        xgrid(i) = west + (i - 0.5) * dx; // Matches MATLAB's staggered grid
    }

    // Initial condition (matching MATLAB)
    vec U = exp(-square(xgrid) / 50.0);

    // Premultiply D_matrix out of time loop
    mat D_matrix = (-dt / 2) * mat(D) * mat(I);

    // Verify dimensions
    if (D_matrix.n_cols != U.n_rows) {
        cerr << "Error: Incompatible matrix dimensions!" << endl;
        cerr << "D_matrix: " << D_matrix.n_rows << "x" << D_matrix.n_cols << endl;
        cerr << "U: " << U.n_rows << "x" << U.n_cols << endl;
        return 1;
    }

    // Time integration loop
    int total_steps = t / dt;
    int print_interval = total_steps / 5;

    for (double time = 0; time <= t; time += dt) {
        // Update U (explicit scheme)
        U = U + D_matrix * square(U);

        // Print only 5 times during the run
        if ((int)(time / dt) % print_interval == 0) {
            double area = sum(U) * dx;

            cout << "Time step: " << (int)(time / dt)
                 << ", Time: " << time
                 << ", Area: " << area
                 << ", U_min: " << U.min()
                 << ", U_max: " << U.max()
                 << ", U_center: " << U(U.n_elem / 2)
                 << endl;
        }
    }

    return 0;
}

