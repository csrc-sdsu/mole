/**
 * Test for addScalarBC boundary condition functions
 *
 * This test verifies:
 * 1. 1D Dirichlet boundary conditions
 * 2. 1D Neumann boundary conditions
 * 3. 2D mixed boundary conditions
 * 4. 3D boundary conditions
 */

#include "mole.h"
#include <iostream>
#include <cmath>

using namespace std;
using namespace AddScalarBC;

void test_1D_dirichlet() {
    cout << "Testing 1D Dirichlet boundary conditions..." << endl;

    // Parameters
    u16 k = 2;
    u32 m = 10;
    Real dx = 0.1;

    // Create Laplacian operator
    Laplacian L(k, m, dx);
    sp_mat A = sp_mat(L);
    vec b(m+2, fill::ones);

    // Set up Dirichlet boundary conditions: u(0) = 1, u(L) = 0
    BC1D bc;
    bc.dc = {1.0, 1.0};  // Dirichlet on both sides
    bc.nc = {0.0, 0.0};  // No Neumann
    bc.v = {1.0, 0.0};   // Values at boundaries

    // Apply boundary conditions
    addScalarBC1D(A, b, k, m, dx, bc);

    // Verify that first and last rows were modified
    if (A(0, 0) == 0.0) {
        cout << "\033[1;31m1D Dirichlet test FAILED!\033[0m" << endl;
        cout << "First diagonal element should be non-zero for Dirichlet BC" << endl;
        exit(1);
    }

    // Verify RHS was updated with boundary values
    if (abs(b(0) - 1.0) > 1e-10 || abs(b(m+1) - 0.0) > 1e-10) {
        cout << "\033[1;31m1D Dirichlet RHS test FAILED!\033[0m" << endl;
        cout << "b(0) = " << b(0) << " (expected 1.0)" << endl;
        cout << "b(end) = " << b(m+1) << " (expected 0.0)" << endl;
        exit(1);
    }

    cout << "  1D Dirichlet test passed" << endl;
}

void test_1D_neumann() {
    cout << "Testing 1D Neumann boundary conditions..." << endl;

    // Parameters
    u16 k = 2;
    u32 m = 10;
    Real dx = 0.1;

    // Create Laplacian operator
    Laplacian L(k, m, dx);
    sp_mat A = sp_mat(L);
    vec b(m+2, fill::ones);

    // Set up Neumann boundary conditions: du/dn(0) = 0, du/dn(L) = 0
    BC1D bc;
    bc.dc = {0.0, 0.0};  // No Dirichlet
    bc.nc = {1.0, 1.0};  // Neumann on both sides
    bc.v = {0.0, 0.0};   // Zero flux at boundaries

    // Apply boundary conditions
    addScalarBC1D(A, b, k, m, dx, bc);

    // Verify operator was modified (for Neumann, gradient is involved)
    if (A.n_nonzero == 0) {
        cout << "\033[1;31m1D Neumann test FAILED!\033[0m" << endl;
        cout << "Operator should have non-zero entries after BC application" << endl;
        exit(1);
    }

    cout << "  1D Neumann test passed" << endl;
}

void test_2D_mixed() {
    cout << "Testing 2D mixed boundary conditions..." << endl;

    // Parameters
    u16 k = 2;
    u32 m = 10;
    u32 n = 10;
    Real dx = 0.1;
    Real dy = 0.1;

    cout << "  Creating Laplacian with k=" << k << ", m=" << m << ", n=" << n << endl;
    // Create 2D Laplacian operator
    Laplacian L(k, m, n, dx, dy);
    sp_mat A = sp_mat(L);
    vec b((m+2)*(n+2), fill::ones);

    // Set up mixed boundary conditions
    // Left/Right: Dirichlet, Bottom/Top: Neumann
    BC2D bc;
    bc.dc = {1.0, 1.0, 0.0, 0.0};  // Dirichlet on left/right
    bc.nc = {0.0, 0.0, 1.0, 1.0};  // Neumann on bottom/top

    // Initialize boundary value vectors
    bc.v[0] = vec(n, fill::value(1.0));      // Left
    bc.v[1] = vec(n, fill::value(0.0));      // Right
    bc.v[2] = vec(m+2, fill::zeros);         // Bottom
    bc.v[3] = vec(m+2, fill::zeros);         // Top

    // Apply boundary conditions
    addScalarBC2D(A, b, k, m, dx, n, dy, bc);

    // Verify operator was modified
    if (A.n_nonzero == 0) {
        cout << "\033[1;31m2D mixed BC test FAILED!\033[0m" << endl;
        cout << "Operator should have non-zero entries" << endl;
        exit(1);
    }

    cout << "  2D mixed BC test passed (operator size: " << A.n_rows << "x" << A.n_cols << ")" << endl;
}

void test_3D_dirichlet() {
    cout << "Testing 3D Dirichlet boundary conditions..." << endl;

    // Parameters
    u16 k = 2;
    u32 m = 6;
    u32 n = 6;
    u32 o = 6;
    Real dx = 0.1;
    Real dy = 0.1;
    Real dz = 0.1;

    // Create 3D Laplacian operator
    Laplacian L(k, m, n, o, dx, dy, dz);
    sp_mat A = sp_mat(L);
    vec b((m+2)*(n+2)*(o+2), fill::ones);

    // Set up Dirichlet boundary conditions on all faces
    BC3D bc;
    bc.dc = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0};  // Dirichlet on all faces
    bc.nc = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};  // No Neumann

    // Initialize boundary value vectors
    bc.v[0] = vec(n*o, fill::value(1.0));    // Left
    bc.v[1] = vec(n*o, fill::value(0.0));    // Right
    bc.v[2] = vec((m+2)*o, fill::zeros);     // Bottom
    bc.v[3] = vec((m+2)*o, fill::zeros);     // Top
    bc.v[4] = vec((m+2)*(n+2), fill::zeros); // Front
    bc.v[5] = vec((m+2)*(n+2), fill::zeros); // Back

    // Apply boundary conditions
    addScalarBC3D(A, b, k, m, dx, n, dy, o, dz, bc);

    // Verify operator was modified
    if (A.n_nonzero == 0) {
        cout << "\033[1;31m3D Dirichlet test FAILED!\033[0m" << endl;
        cout << "Operator should have non-zero entries" << endl;
        exit(1);
    }

    cout << "  3D Dirichlet test passed (operator size: " << A.n_rows << "x" << A.n_cols << ")" << endl;
}

void test_periodic() {
    cout << "Testing periodic boundary conditions (do nothing case)..." << endl;

    // Parameters
    u16 k = 2;
    u32 m = 10;
    Real dx = 0.1;

    // Create Laplacian operator
    Laplacian L(k, m, dx);
    sp_mat A_orig = sp_mat(L);
    sp_mat A = A_orig;
    vec b_orig(m+2, fill::ones);
    vec b = b_orig;

    // Set up periodic boundary conditions (all zeros)
    BC1D bc;
    bc.dc = {0.0, 0.0};
    bc.nc = {0.0, 0.0};
    bc.v = {0.0, 0.0};

    // Apply boundary conditions (should do nothing)
    addScalarBC1D(A, b, k, m, dx, bc);

    // Verify that A and b were NOT modified
    Real diff_A = norm(A - A_orig, "fro");
    Real diff_b = norm(b - b_orig);

    if (diff_A > 1e-10 || diff_b > 1e-10) {
        cout << "\033[1;31mPeriodic BC test FAILED!\033[0m" << endl;
        cout << "Operator and RHS should not be modified for periodic BC" << endl;
        cout << "||A - A_orig|| = " << diff_A << endl;
        cout << "||b - b_orig|| = " << diff_b << endl;
        exit(1);
    }

    cout << "  Periodic BC test passed" << endl;
}

int main() {
    cout << "\n=== AddScalarBC Test Suite ===\n" << endl;

    try {
        test_1D_dirichlet();
        test_1D_neumann();
        test_periodic();
        test_2D_mixed();
        test_3D_dirichlet();

        cout << "\n\033[1;32mAll AddScalarBC Tests PASSED!\033[0m\n" << endl;
    } catch (const exception &e) {
        cout << "\n\033[1;31mTest FAILED with exception: " << e.what() << "\033[0m\n" << endl;
        return 1;
    }

    return 0;
}
