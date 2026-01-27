/**
 * 2D Poisson Equation with Dirichlet Boundary Conditions
 *
 * Solves the 2D Poisson equation:
 *     ∇²u = f  on  Ω = [0,1] × [0,1]
 *     u = g     on  ∂Ω
 *
 * with manufactured solution: u(x,y) = sin(πx)sin(πy)
 *
 * This example demonstrates how to use addScalarBC to apply
 * Dirichlet boundary conditions to a discrete Laplacian operator.
 *
 * Based on MATLAB example: elliptic2D.m
 */

#include "mole.h"
#include <iostream>
#include <cmath>

using namespace std;
using namespace AddScalarBC;

int main() {
    cout << "\n=== 2D Poisson Equation with Dirichlet BCs ===\n" << endl;

    // Parameters
    u16 k = 2;        // Order of accuracy
    u32 m = 30;       // Number of cells in x-direction
    u32 n = 30;       // Number of cells in y-direction
    Real dx = 1.0 / (m + 1);
    Real dy = 1.0 / (n + 1);

    cout << "Grid parameters:" << endl;
    cout << "  Order of accuracy (k): " << k << endl;
    cout << "  Grid size: " << m << " x " << n << endl;
    cout << "  Cell spacing: dx = " << dx << ", dy = " << dy << endl;
    cout << endl;

    // Create 2D Laplacian operator
    cout << "Constructing 2D Laplacian operator..." << endl;
    Laplacian L(k, m, n, dx, dy);
    sp_mat A = sp_mat(L);
    cout << "  Operator size: " << A.n_rows << " x " << A.n_cols << endl;
    cout << "  Non-zero elements: " << A.n_nonzero << endl;
    cout << endl;

    // Create grid points
    vec x = linspace<vec>(0, 1, m+2);
    vec y = linspace<vec>(0, 1, n+2);

    // Manufactured solution: u(x,y) = sin(πx)sin(πy)
    // Right-hand side: f = -∇²u = 2π²sin(πx)sin(πy)
    vec f((m+2)*(n+2));
    for (u32 j = 0; j < n+2; j++) {
        for (u32 i = 0; i < m+2; i++) {
            u32 idx = j * (m+2) + i;
            f(idx) = 2.0 * M_PI * M_PI * sin(M_PI * x(i)) * sin(M_PI * y(j));
        }
    }

    // Set up Dirichlet boundary conditions: u = 0 on all boundaries
    cout << "Applying Dirichlet boundary conditions..." << endl;
    BC2D bc;
    bc.dc = {1.0, 1.0, 1.0, 1.0};  // Dirichlet on all sides
    bc.nc = {0.0, 0.0, 0.0, 0.0};  // No Neumann

    // Boundary values (u = 0 on all boundaries)
    bc.v[0] = vec(n, fill::zeros);      // Left: x = 0
    bc.v[1] = vec(n, fill::zeros);      // Right: x = 1
    bc.v[2] = vec(m+2, fill::zeros);    // Bottom: y = 0
    bc.v[3] = vec(m+2, fill::zeros);    // Top: y = 1

    // Apply boundary conditions
    addScalarBC2D(A, f, k, m, dx, n, dy, bc);
    cout << "  Boundary conditions applied" << endl;
    cout << "  Modified operator size: " << A.n_rows << " x " << A.n_cols << endl;
    cout << endl;

    // Solve the linear system A*u = f
    cout << "Solving linear system..." << endl;
    vec u = spsolve(A, f);

    if (u.n_elem == 0) {
        cout << "\033[1;31mFailed to solve linear system!\033[0m" << endl;
        return 1;
    }

    cout << "  Solution obtained" << endl;
    cout << endl;

    // Compute exact solution at interior points
    vec u_exact((m+2)*(n+2));
    for (u32 j = 0; j < n+2; j++) {
        for (u32 i = 0; i < m+2; i++) {
            u32 idx = j * (m+2) + i;
            u_exact(idx) = sin(M_PI * x(i)) * sin(M_PI * y(j));
        }
    }

    // Compute error
    vec error = u - u_exact;
    Real max_error = max(abs(error));
    Real l2_error = norm(error) / sqrt(u.n_elem);

    cout << "Error analysis:" << endl;
    cout << "  Max error: " << max_error << endl;
    cout << "  L2 error:  " << l2_error << endl;
    cout << endl;

    // Verify solution quality
    if (max_error < 1e-2) {
        cout << "\033[1;32mSolution accurate within tolerance!\033[0m" << endl;
    } else {
        cout << "\033[1;33mWarning: Error may be higher than expected\033[0m" << endl;
    }

    // Display some solution values
    cout << "\nSample solution values:" << endl;
    cout << "  u(0.5, 0.5) ≈ " << u((n+2)/2 * (m+2) + (m+2)/2)
         << " (exact: " << sin(M_PI * 0.5) * sin(M_PI * 0.5) << ")" << endl;
    cout << "  u(0.25, 0.25) ≈ " << u((n+2)/4 * (m+2) + (m+2)/4)
         << " (exact: " << sin(M_PI * 0.25) * sin(M_PI * 0.25) << ")" << endl;
    cout << "  u(0.75, 0.75) ≈ " << u(3*(n+2)/4 * (m+2) + 3*(m+2)/4)
         << " (exact: " << sin(M_PI * 0.75) * sin(M_PI * 0.75) << ")" << endl;
    cout << endl;

    cout << "To visualize the solution, export the data and use" << endl;
    cout << "tools like ParaView, VisIt, or MATLAB/Python." << endl;
    cout << endl;

    return 0;
}
