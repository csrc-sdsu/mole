/**
 * 2D Elliptic Problem with Dirichlet Boundary Conditions on All Edges
 *
 * Solves the 2D elliptic equation:
 *     -∇²u = f  on  Ω = [0,1] × [0,1]
 *
 * With Dirichlet boundary conditions on all four edges:
 *     u(x,0) = g_bottom(x)    (bottom edge)
 *     u(x,1) = g_top(x)       (top edge)
 *     u(0,y) = g_left(y)      (left edge)
 *     u(1,y) = g_right(y)     (right edge)
 *
 * Manufactured solution: u(x,y) = sin(2πx)sin(2πy)
 *
 * This example demonstrates:
 * - Setting up a 2D Laplacian operator
 * - Applying Dirichlet boundary conditions on all edges
 * - Solving the resulting linear system
 * - Computing solution error
 *
 * Based on MATLAB example: elliptic2DXDirichletYDirichlet.m
 */

#include "mole.h"
#include <iostream>
#include <cmath>
#include <iomanip>

using namespace std;
using namespace AddScalarBC;

int main() {
    cout << "\n=== 2D Elliptic Equation with Dirichlet BCs ===\n" << endl;

    // Parameters
    const u16 k = 2;        // Order of accuracy
    const u32 m = 31;       // Number of cells in x-direction
    const u32 n = 33;       // Number of cells in y-direction
    const Real a = 0.0;     // Left boundary of domain
    const Real b = 1.0;     // Right boundary of domain
    const Real c = 0.0;     // Bottom boundary of domain
    const Real d = 1.0;     // Top boundary of domain

    const Real dx = (b - a) / (m + 1);
    const Real dy = (d - c) / (n + 1);

    cout << "Problem setup:" << endl;
    cout << "  Domain: [" << a << ", " << b << "] × [" << c << ", " << d << "]" << endl;
    cout << "  Order of accuracy (k): " << k << endl;
    cout << "  Grid size: " << m << " × " << n << endl;
    cout << "  Cell spacing: dx = " << dx << ", dy = " << dy << endl;
    cout << "  Total unknowns: " << (m+2) * (n+2) << endl;
    cout << endl;

    // Create 2D Laplacian operator
    cout << "Constructing 2D Laplacian operator..." << endl;
    Laplacian L(k, m, n, dx, dy);
    sp_mat A = -sp_mat(L);  // Negate to solve -∇²u = f

    cout << "  Operator size: " << A.n_rows << " × " << A.n_cols << endl;
    cout << "  Non-zero elements: " << A.n_nonzero << endl;
    cout << endl;

    // Create grid points
    vec x = linspace<vec>(a, b, m+2);
    vec y = linspace<vec>(c, d, n+2);

    // Manufactured solution: u(x,y) = sin(2πx)sin(2πy)
    // ∇²u = -8π²sin(2πx)sin(2πy), so for -∇²u = f, we have f = 8π²sin(2πx)sin(2πy)
    vec f((m+2)*(n+2));
    for (u32 j = 0; j < n+2; j++) {
        for (u32 i = 0; i < m+2; i++) {
            u32 idx = j * (m+2) + i;
            f(idx) = 8.0 * M_PI * M_PI * sin(2.0 * M_PI * x(i)) * sin(2.0 * M_PI * y(j));
        }
    }

    // Set up Dirichlet boundary conditions on all edges
    cout << "Setting up Dirichlet boundary conditions..." << endl;
    BC2D bc;
    bc.dc = {1.0, 1.0, 1.0, 1.0};  // Dirichlet on all four edges
    bc.nc = {0.0, 0.0, 0.0, 0.0};  // No Neumann conditions

    // Left boundary: u(0, y) = sin(2π·0)sin(2πy) = 0
    bc.v[0] = vec(n, fill::zeros);

    // Right boundary: u(1, y) = sin(2π·1)sin(2πy) = 0
    bc.v[1] = vec(n, fill::zeros);

    // Bottom boundary: u(x, 0) = sin(2πx)sin(2π·0) = 0
    bc.v[2] = vec(m+2, fill::zeros);

    // Top boundary: u(x, 1) = sin(2πx)sin(2π·1) = 0
    bc.v[3] = vec(m+2, fill::zeros);

    cout << "  Left boundary (x=0): u = 0" << endl;
    cout << "  Right boundary (x=1): u = 0" << endl;
    cout << "  Bottom boundary (y=0): u = 0" << endl;
    cout << "  Top boundary (y=1): u = 0" << endl;
    cout << endl;

    // Apply boundary conditions
    cout << "Applying boundary conditions to operator and RHS..." << endl;
    addScalarBC2D(A, f, k, m, dx, n, dy, bc);
    cout << "  Boundary conditions applied" << endl;
    cout << endl;

    // Solve the linear system A*u = f
    cout << "Solving linear system A*u = f..." << endl;
    vec u = spsolve(A, f);

    if (u.n_elem == 0) {
        cout << "\033[1;31mError: Failed to solve linear system!\033[0m" << endl;
        return 1;
    }

    cout << "  Solution obtained successfully" << endl;
    cout << endl;

    // Compute exact solution
    vec u_exact((m+2)*(n+2));
    for (u32 j = 0; j < n+2; j++) {
        for (u32 i = 0; i < m+2; i++) {
            u32 idx = j * (m+2) + i;
            u_exact(idx) = sin(2.0 * M_PI * x(i)) * sin(2.0 * M_PI * y(j));
        }
    }

    // Compute error
    vec error = u - u_exact;
    Real max_error = max(abs(error));
    Real l2_error = norm(error) / sqrt(u.n_elem);
    Real rel_error = norm(error) / norm(u_exact);

    cout << "Error analysis:" << endl;
    cout << "  Maximum error:  " << scientific << setprecision(6) << max_error << endl;
    cout << "  L2 norm error:  " << l2_error << endl;
    cout << "  Relative error: " << rel_error << endl;
    cout << endl;

    // Verify solution quality
    if (max_error < 1e-2) {
        cout << "\033[1;32mSolution verified: Error within acceptable tolerance!\033[0m" << endl;
    } else {
        cout << "\033[1;33mWarning: Error exceeds expected tolerance\033[0m" << endl;
    }
    cout << endl;

    // Display sample solution values
    cout << "Sample solution values:" << endl;
    cout << fixed << setprecision(6);

    // Center point (0.5, 0.5)
    u32 idx_center = (n+2)/2 * (m+2) + (m+2)/2;
    Real exact_center = sin(2.0 * M_PI * 0.5) * sin(2.0 * M_PI * 0.5);
    cout << "  u(0.5, 0.5):  computed = " << u(idx_center)
         << ", exact = " << exact_center
         << ", error = " << abs(u(idx_center) - exact_center) << endl;

    // Point (0.25, 0.25)
    u32 idx_quarter = (n+2)/4 * (m+2) + (m+2)/4;
    Real exact_quarter = sin(2.0 * M_PI * 0.25) * sin(2.0 * M_PI * 0.25);
    cout << "  u(0.25, 0.25): computed = " << u(idx_quarter)
         << ", exact = " << exact_quarter
         << ", error = " << abs(u(idx_quarter) - exact_quarter) << endl;

    // Point (0.75, 0.75)
    u32 idx_three_quarters = 3*(n+2)/4 * (m+2) + 3*(m+2)/4;
    Real exact_three_quarters = sin(2.0 * M_PI * 0.75) * sin(2.0 * M_PI * 0.75);
    cout << "  u(0.75, 0.75): computed = " << u(idx_three_quarters)
         << ", exact = " << exact_three_quarters
         << ", error = " << abs(u(idx_three_quarters) - exact_three_quarters) << endl;
    cout << endl;

    // Solution statistics
    cout << "Solution statistics:" << endl;
    cout << "  Minimum value: " << u.min() << endl;
    cout << "  Maximum value: " << u.max() << endl;
    cout << "  Mean value:    " << mean(u) << endl;
    cout << endl;

    cout << "Note: For visualization of the solution, export the data to" << endl;
    cout << "      a file and use tools like ParaView, VisIt, or MATLAB/Python." << endl;
    cout << endl;

    return 0;
}
