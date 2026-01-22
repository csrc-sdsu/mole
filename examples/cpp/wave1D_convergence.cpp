/*
 * ======================================================================================
 * Example: 2nd Order Convergence for 1D Wave Equation (Hyperbolic)
 * Language: C++ (using MOLE library & Armadillo)
 * ======================================================================================
 *
 * Reference:
 * Problem based on "Example 10.1" from:
 * Mathews, J. H., & Fink, K. D. (2004). Numerical methods using MATLAB (4th ed.).
 * Pearson Prentice Hall.
 *
 * Context:
 * This example was presented during the postgraduate course "Introduction
 * to Mimetic Difference Methods and Applications", taught by Prof. Jose
 * Castillo in October 2023 at the Faculty of Exact Sciences, Engineering
 * and Surveying (FCEIA) of the National University of Rosario (UNR),
 * Argentina.
 *
 * Mathematical Formulation:
 * ∂²u/∂t² = 4 ∂²u/∂x²   on Ω = [0, 1] x [0, 0.5]
 * (Comparing with standard form u_tt = c² u_xx, this implies wave speed c = 2)
 *
 * Domain Description:
 * - Spatial: x ∈ [0, 1]
 * - Temporal: t ∈ [0, 0.5]
 * - Grid: Staggered grid (Mimetic Discretization)
 *
 * Boundary Conditions (Dirichlet):
 * u(0, t) = 0
 * u(1, t) = 0
 *
 * Initial Conditions:
 * u(x, 0) = sin(πx) + sin(2πx)
 * ∂u/∂t(x, 0) = 0
 *
 * Analytical Solution (Exact):
 * u(x, t) = sin(πx)cos(2πt) + sin(2πx)cos(4πt)
 *
 * Implementation Details:
 * - Spatial Scheme: Mimetic Finite Differences (Order k=2)
 * - Time Integration: Verlet Algorithm (Symplectic, 2nd order, Leapfrog equivalent)
 * - Library: MOLE (with Armadillo for linear algebra)
 *
 * Output:
 * - Prints a table of L2 errors and convergence rates for successive grid refinements.
 *
 * Author: Martin S. Armoa
 * Programming Assistant: Google Gemini via VS Code
 * ======================================================================================
 */

#include "mole.h"
#include <iostream>
#include <vector>
#include <cmath>
#include <iomanip>

using namespace arma;
using namespace std;

// --- Physical Parameters ---
const double PI = 3.14159265358979323846;
const double WAVE_SPEED_C = 2.0;
const double T_FINAL = 0.5;

// --- Analytical Solution for Validation ---
double exact_sol(double x, double t) {
    return sin(PI*x)*cos(PI*WAVE_SPEED_C*t) + sin(2*PI*x)*cos(2*PI*WAVE_SPEED_C*t);
}

// --- Simulation Runner ---
// Returns the discrete L2 error for a given number of cells (m)
double run_simulation(int m) {
    int k = 2;              // Spatial order of accuracy
    double a = 0.0;         // Left boundary
    double b = 1.0;         // Right boundary
    double dx = (b - a) / m;

    // Time step based on CFL condition for stability
    // dt <= dx / c. We use dx / 4c for safety and precision.
    double dt_approx = dx / (4.0 * WAVE_SPEED_C);
    int Nt = (int)ceil(T_FINAL / dt_approx);
    double dt = T_FINAL / Nt;

    // 1. Initialize Mimetic Laplacian Operator
    Laplacian L(k, m, dx);

    // 2. Initialize State Vectors (Size m+2 to include boundary ghost points)
    vec u(m + 2, fill::zeros);
    vec v(m + 2, fill::zeros);
    vec acc(m + 2, fill::zeros);

    // Coordinate auxiliary vector for error calculation
    // Armadillo indices: 0 (Left BC), 1..m (Interior), m+1 (Right BC)
    vector<double> x_centers(m + 2);

    // Set Initial Conditions
    for (int i = 1; i <= m; i++) {
        double x = a + (i - 0.5) * dx;
        x_centers[i] = x;
        u(i) = exact_sol(x, 0.0);
    }

    // Enforce Boundary Conditions
    u(0) = 0.0;
    u(m+1) = 0.0;

    // 3. Time Integration Loop (Velocity Verlet)
    // Step 0: Initial acceleration
    acc = (WAVE_SPEED_C*WAVE_SPEED_C) * (L * u);
    acc(0) = 0.0; acc(m+1) = 0.0; // Enforce Dirichlet on acceleration

    for (int t = 0; t < Nt; t++) {
        // v(t+0.5) = v(t) + 0.5*dt*a(t)
        v = v + 0.5 * dt * acc;

        // u(t+1) = u(t) + dt*v(t+0.5)
        u = u + dt * v;

        // a(t+1) = Force(u(t+1))
        acc = (WAVE_SPEED_C*WAVE_SPEED_C) * (L * u);
        acc(0) = 0.0; acc(m+1) = 0.0; // Enforce Dirichlet

        // v(t+1) = v(t+0.5) + 0.5*dt*a(t+1)
        v = v + 0.5 * dt * acc;
    }

    // 4. Compute L2 Error
    double sum_sq_error = 0.0;
    for (int i = 1; i <= m; i++) {
        double diff = u(i) - exact_sol(x_centers[i], T_FINAL);
        sum_sq_error += diff * diff;
    }

    return sqrt(sum_sq_error * dx);
}

int main() {
    vector<int> mesh_sizes = {20, 40, 80, 160, 320};
    vector<double> errors;
    vector<double> dx_vals;

    cout << "===========================================" << endl;
    cout << " MOLE Example: 1D Wave Equation Convergence" << endl;
    cout << "===========================================" << endl;

    cout << endl << "### Convergence Rate Table - MIMETIC Scheme" << endl;
    cout << "| Cells (m) | dx         | L2 Error   | Rate (p) |" << endl;
    cout << "| :---      | :---       | :---       | :---     |" << endl;

    for (size_t i = 0; i < mesh_sizes.size(); i++) {
        int m = mesh_sizes[i];
        double dx = 1.0 / m;

        try {
            double error = run_simulation(m);
            errors.push_back(error);
            dx_vals.push_back(dx);

            string rate_str = "-";
            if (i > 0) {
                double rate = log(errors[i-1] / errors[i]) / log(dx_vals[i-1] / dx_vals[i]);
                char buffer[50];
                sprintf(buffer, "%.2f", rate);
                rate_str = string(buffer);
            }

            cout << "| " << setw(9) << left << m
                 << " | " << scientific << setprecision(4) << dx
                 << " | " << scientific << setprecision(4) << error
                 << " | " << setw(8) << rate_str << " |" << endl;

        } catch (const std::exception& e) {
            cout << "Error simulation m=" << m << ": " << e.what() << endl;
        }
    }
    return 0;
}
