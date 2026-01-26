/**
 * Test for curvilinear operators (GradCurv, DivCurv, Jacobian, Interpolator)
 *
 * This test verifies:
 * 1. Jacobian computation for 3D curvilinear grids
 * 2. 3D curvilinear gradient operator construction
 * 3. 3D curvilinear divergence operator construction
 * 4. Basic interpolator functionality
 */

#include "mole.h"
#include <iostream>
#include <cmath>

using namespace std;

// Helper function to generate a simple curvilinear grid
void genCurvGrid3D(int m, int n, int o, cube &X, cube &Y, cube &Z) {
    for (int k = 0; k < o; k++) {
        for (int j = 0; j < n; j++) {
            for (int i = 0; i < m; i++) {
                double x = j - M_PI + 2*sin((j-M_PI)/5.0)*cos((i-M_PI)/5.0);
                double y = i - M_PI + 2*sin((j-M_PI)/5.0)*cos((i-M_PI)/5.0);
                double z = k;
                X(i, j, k) = x;
                Y(i, j, k) = y;
                Z(i, j, k) = z;
            }
        }
    }
}

void test_jacobian_3d(int k, int m, int n, int o) {
    cout << "Testing 3D Jacobian with k=" << k
         << ", grid=" << m << "x" << n << "x" << o << "..." << endl;

    cube X(m, n, o);
    cube Y(m, n, o);
    cube Z(m, n, o);

    genCurvGrid3D(m, n, o, X, Y, Z);

    Jacob J;
    J.Jacobian(k, X, Y, Z);

    // Verify Jacobian vector has correct size
    if (J.Jacob_vec.n_elem != m*n*o) {
        cout << "\033[1;31mJacobian size test FAILED!\033[0m" << endl;
        cout << "Expected size: " << m*n*o << ", got: " << J.Jacob_vec.n_elem << endl;
        exit(1);
    }

    // Verify Jacobian is non-zero (physical grid should have valid transformation)
    if (max(abs(J.Jacob_vec)) < 1e-10) {
        cout << "\033[1;31mJacobian non-zero test FAILED!\033[0m" << endl;
        exit(1);
    }

    cout << "  Jacobian test passed (size=" << J.Jacob_vec.n_elem
         << ", max|J|=" << max(abs(J.Jacob_vec)) << ")" << endl;
}

void test_grad3DCurv(int k, int m, int n, int o) {
    cout << "Testing 3D Curvilinear Gradient with k=" << k
         << ", grid=" << m << "x" << n << "x" << o << "..." << endl;

    cube X(m, n, o);
    cube Y(m, n, o);
    cube Z(m, n, o);

    genCurvGrid3D(m, n, o, X, Y, Z);

    GradCurv G;
    G.G3DCurv(k, X, Y, Z);

    // Verify gradient operator was constructed
    if (G.grad3DCurv.n_rows == 0) {
        cout << "\033[1;31mGradCurv construction FAILED!\033[0m" << endl;
        exit(1);
    }

    int expected_rows = m*(n-1)*(o-1) + (m-1)*n*(o-1) + (m-1)*(n-1)*o;
    int expected_cols = (m+1)*(n+1)*(o+1);

    if (G.grad3DCurv.n_rows != expected_rows || G.grad3DCurv.n_cols != expected_cols) {
        cout << "\033[1;31mGradCurv size test FAILED!\033[0m" << endl;
        cout << "Expected: " << expected_rows << "x" << expected_cols
             << ", got: " << G.grad3DCurv.n_rows << "x" << G.grad3DCurv.n_cols << endl;
        exit(1);
    }

    cout << "  GradCurv test passed (operator size=" << G.grad3DCurv.n_rows
         << "x" << G.grad3DCurv.n_cols << ")" << endl;
}

void test_div3DCurv(int k, int m, int n, int o) {
    cout << "Testing 3D Curvilinear Divergence with k=" << k
         << ", grid=" << m << "x" << n << "x" << o << "..." << endl;

    cube X(m, n, o);
    cube Y(m, n, o);
    cube Z(m, n, o);

    genCurvGrid3D(m, n, o, X, Y, Z);

    DivCurv D;
    D.D3DCurv(k, X, Y, Z);

    // Verify divergence operator was constructed
    if (D.div3DCurv.n_rows == 0) {
        cout << "\033[1;31mDivCurv construction FAILED!\033[0m" << endl;
        exit(1);
    }

    int expected_cols = m*(n-1)*(o-1) + (m-1)*n*(o-1) + (m-1)*(n-1)*o;
    int expected_rows = (m+1)*(n+1)*(o+1);  // Divergence output is at centers

    if (D.div3DCurv.n_rows != expected_rows || D.div3DCurv.n_cols != expected_cols) {
        cout << "\033[1;31mDivCurv size test FAILED!\033[0m" << endl;
        cout << "Expected: " << expected_rows << "x" << expected_cols
             << ", got: " << D.div3DCurv.n_rows << "x" << D.div3DCurv.n_cols << endl;
        exit(1);
    }

    cout << "  DivCurv test passed (operator size=" << D.div3DCurv.n_rows
         << "x" << D.div3DCurv.n_cols << ")" << endl;
}

void test_interpolator(int k, int m, int n, int o) {
    cout << "Testing Interpolator with k=" << k
         << ", grid=" << m << "x" << n << "x" << o << "..." << endl;

    Interpolator interp;

    // Test 3D center to faces interpolation
    sp_mat CtoF = interp.Inter_CenterToFaces(k, m, n, o);

    if (CtoF.n_rows == 0 || CtoF.n_cols == 0) {
        cout << "\033[1;31mInterpolator construction FAILED!\033[0m" << endl;
        exit(1);
    }

    cout << "  Interpolator test passed (CtoF size=" << CtoF.n_rows
         << "x" << CtoF.n_cols << ")" << endl;
}

int main() {
    cout << "\n=== Curvilinear Operators Test Suite ===\n" << endl;

    int k = 2;  // Order of accuracy
    int m = 10; // Grid size
    int n = 10;
    int o = 10;

    try {
        test_jacobian_3d(k, m, n, o);
        test_interpolator(k, m-1, n-1, o-1);
        test_grad3DCurv(k, m, n, o);
        test_div3DCurv(k, m, n, o);

        cout << "\n\033[1;32mAll Curvilinear Tests PASSED!\033[0m\n" << endl;
    } catch (const exception &e) {
        cout << "\n\033[1;31mTest FAILED with exception: " << e.what() << "\033[0m\n" << endl;
        return 1;
    }

    return 0;
}
