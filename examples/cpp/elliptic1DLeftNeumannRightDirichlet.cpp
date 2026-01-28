/**
 * 1D Elliptic Problem with Left Neumann and Right Dirichlet BCs
 *
 * Solves the 1D elliptic equation:
 *     -u'' = 1  on  (0, 1)
 *
 * With boundary conditions:
 *     u'(0) = 0  (left Neumann BC)
 *     u(1) = 0   (right Dirichlet BC)
 *
 * Exact solution: u(x) = (1 - x²)/2
 *
 * This example demonstrates:
 * - Setting up a 1D Laplacian operator
 * - Applying mixed Neumann/Dirichlet boundary conditions
 * - Solving the resulting linear system
 * - Computing solution error
 *
 * Based on MATLAB example: elliptic1DLeftNeumannRightDirichlet.m
 */

#include "mole.h"
#include <iostream>
#include <cmath>
#include <iomanip>

using namespace std;
using namespace AddScalarBC;

int main() {
    cout << "\n=== 1D Elliptic Equation: Left Neumann, Right Dirichlet ===\n" << endl;

    // Parameters
    const u16 k = 2;              // Order of accuracy
    const u32 m = 2 * k + 1;      // Number of cells (must be > 2*k)
    const Real dx = 1.0 / m;      // Cell spacing
    const Real a = 0.0;           // Left boundary
    const Real b = 1.0;           // Right boundary

    cout << "Problem setup:" << endl;
    cout << "  Domain: [" << a << ", " << b << "]" << endl;
    cout << "  Equation: -u'' = 1" << endl;
    cout << "  BC: u'(0) = 0 (Neumann), u(1) = 0 (Dirichlet)" << endl;
    cout << "  Order of accuracy (k): " << k << endl;
    cout << "  Number of cells (m): " << m << endl;
    cout << "  Cell spacing (dx): " << dx << endl;
    cout << "  Total unknowns: " << m + 2 << endl;
    cout << endl;

    // Create 1D Laplacian operator
    cout << "Constructing 1D Laplacian operator..." << endl;
    Laplacian L(k, m, dx);
    sp_mat A = -sp_mat(L);  // Negate to solve -u'' = f

    cout << "  Operator size: " << A.n_rows << " × " << A.n_cols << endl;
    cout << "  Non-zero elements: " << A.n_nonzero << endl;
    cout << endl;

    // Create grid points (centers and boundaries)
    vec x(m + 2);
    x(0) = a;
    x(1) = a + dx / 2.0;
    for (u32 i = 2; i <= m; i++) {
        x(i) = x(i - 1) + dx;
    }
    x(m + 1) = b;

    // Right-hand side: f = 1
    vec f(m + 2, fill::ones);

    // Set up boundary conditions
    cout << "Setting up boundary conditions..." << endl;
    BC1D bc;
    bc.dc = {0.0, 1.0};  // Left: Neumann (dc=0), Right: Dirichlet (dc=1)
    bc.nc = {1.0, 0.0};  // Left: Neumann (nc=1), Right: no Neumann (nc=0)
    bc.v = {0.0, 0.0};   // Left: u'(0) = 0, Right: u(1) = 0

    cout << "  Left boundary (x=0): u' = 0 (Neumann)" << endl;
    cout << "  Right boundary (x=1): u = 0 (Dirichlet)" << endl;
    cout << endl;

    // Apply boundary conditions
    cout << "Applying boundary conditions to operator and RHS..." << endl;
    addScalarBC1D(A, f, k, m, dx, bc);
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

    // Compute exact solution: u(x) = (1 - x²)/2
    vec u_exact(m + 2);
    for (u32 i = 0; i < m + 2; i++) {
        u_exact(i) = 0.5 * (1.0 - x(i) * x(i));
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
    if (max_error < 1e-3) {
        cout << "\033[1;32mSolution verified: Error within acceptable tolerance!\033[0m" << endl;
    } else {
        cout << "\033[1;33mWarning: Error exceeds expected tolerance\033[0m" << endl;
    }
    cout << endl;

    // Display sample solution values
    cout << "Sample solution values:" << endl;
    cout << fixed << setprecision(6);

    // Left boundary (x=0)
    cout << "  u(0.0):  computed = " << u(0)
         << ", exact = " << u_exact(0)
         << ", error = " << abs(u(0) - u_exact(0)) << endl;

    // Mid-point (x≈0.5)
    u32 idx_mid = (m + 2) / 2;
    cout << "  u(" << x(idx_mid) << "): computed = " << u(idx_mid)
         << ", exact = " << u_exact(idx_mid)
         << ", error = " << abs(u(idx_mid) - u_exact(idx_mid)) << endl;

    // Right boundary (x=1)
    cout << "  u(1.0):  computed = " << u(m + 1)
         << ", exact = " << u_exact(m + 1)
         << ", error = " << abs(u(m + 1) - u_exact(m + 1)) << endl;
    cout << endl;

    // Solution statistics
    cout << "Solution statistics:" << endl;
    cout << "  Minimum value: " << u.min() << endl;
    cout << "  Maximum value: " << u.max() << endl;
    cout << "  Mean value:    " << mean(u) << endl;
    cout << endl;

    // Verify boundary conditions
    cout << "Boundary condition verification:" << endl;

    // Check right Dirichlet BC: u(1) = 0
    cout << "  Right BC: u(1) = " << u(m + 1) << " (should be ≈ 0)" << endl;

    // Check left Neumann BC: u'(0) ≈ 0 (approximate derivative)
    Real left_derivative = (u(1) - u(0)) / (dx / 2.0);
    cout << "  Left BC: u'(0) ≈ " << left_derivative << " (should be ≈ 0)" << endl;
    cout << endl;

    return 0;
}
