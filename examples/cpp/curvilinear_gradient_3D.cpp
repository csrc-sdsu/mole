/**
 * 3D Curvilinear Gradient Example
 *
 * This example demonstrates how to:
 * 1. Create a curvilinear 3D grid
 * 2. Define a scalar field on the grid
 * 3. Compute the gradient using the curvilinear gradient operator
 * 4. Display results
 *
 * Based on the MATLAB example: test_grad3DCurv.m
 */

#include "mole.h"
#include <iostream>
#include <cmath>

using namespace std;

// Generate a curvilinear grid (similar to genCurvGrid.m)
void genCurvGrid3D(int m, int n, int o, cube &X, cube &Y, cube &Z) {
    for (int k = 0; k < o; k++) {
        for (int j = 0; j < n; j++) {
            for (int i = 0; i < m; i++) {
                // Curvilinear transformation
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

// Interpolate scalar field to staggered grid
vec interpolateToStaggered(const cube &C, int m, int n, int o) {
    // Create staggered logical grid coordinates
    // In MATLAB: [1 1.5 : 1 : m-0.5 m]
    vec xs(m+1), ys(n+1), zs(o+1);

    xs(0) = 1;
    xs(m) = m;
    for (int i = 1; i < m; i++)
        xs(i) = 1.5 + (i-1);

    ys(0) = 1;
    ys(n) = n;
    for (int i = 1; i < n; i++)
        ys(i) = 1.5 + (i-1);

    zs(0) = 1;
    zs(o) = o;
    for (int i = 1; i < o; i++)
        zs(i) = 1.5 + (i-1);

    // Simple interpolation (linear)
    vec C_staggered((m+1)*(n+1)*(o+1));
    int idx = 0;

    for (int k = 0; k <= o; k++) {
        for (int j = 0; j <= n; j++) {
            for (int i = 0; i <= m; i++) {
                // Get interpolation coordinates
                int i0 = min(i, m-1);
                int j0 = min(j, n-1);
                int k0 = min(k, o-1);

                C_staggered(idx++) = C(i0, j0, k0);
            }
        }
    }

    return C_staggered;
}

int main() {
    cout << "\n=== 3D Curvilinear Gradient Example ===\n" << endl;

    // Parameters
    int k = 2;   // Order of accuracy
    int m = 20;  // Number of nodes along x-axis
    int n = 24;  // Number of nodes along y-axis
    int o = 22;  // Number of nodes along z-axis

    cout << "Grid parameters:" << endl;
    cout << "  Order of accuracy (k): " << k << endl;
    cout << "  Grid size: " << m << " x " << n << " x " << o << endl;
    cout << endl;

    // Generate curvilinear grid
    cout << "Generating curvilinear grid..." << endl;
    cube X(m, n, o);
    cube Y(m, n, o);
    cube Z(m, n, o);

    genCurvGrid3D(m, n, o, X, Y, Z);

    // Define scalar field on nodal grid: C = X^2 + Y^2 + Z^2
    cout << "Creating scalar field C = X^2 + Y^2 + Z^2..." << endl;
    cube C(m, n, o);

    for (int k = 0; k < o; k++) {
        for (int j = 0; j < n; j++) {
            for (int i = 0; i < m; i++) {
                C(i, j, k) = X(i, j, k)*X(i, j, k) +
                             Y(i, j, k)*Y(i, j, k) +
                             Z(i, j, k)*Z(i, j, k);
            }
        }
    }

    cout << "  Scalar field range: [" << C.min() << ", " << C.max() << "]" << endl;
    cout << endl;

    // Interpolate to staggered grid
    cout << "Interpolating to staggered grid..." << endl;
    vec C_staggered = interpolateToStaggered(C, m, n, o);

    // Compute 3D curvilinear gradient
    cout << "Computing 3D curvilinear gradient operator..." << endl;
    GradCurv G;
    G.G3DCurv(k, X, Y, Z);

    cout << "  Gradient operator size: " << G.grad3DCurv.n_rows
         << " x " << G.grad3DCurv.n_cols << endl;
    cout << "  Non-zero elements: " << G.grad3DCurv.n_nonzero << endl;
    cout << endl;

    // Apply gradient operator to scalar field
    cout << "Applying gradient operator to scalar field..." << endl;
    vec grad_result = G.grad3DCurv * C_staggered;

    // Extract components
    int size_u = m*(n-1)*(o-1);
    int size_v = (m-1)*n*(o-1);
    int size_w = (m-1)*(n-1)*o;

    vec Gx = grad_result.subvec(0, size_u-1);
    vec Gy = grad_result.subvec(size_u, size_u+size_v-1);
    vec Gz = grad_result.subvec(size_u+size_v, size_u+size_v+size_w-1);

    cout << "Gradient components:" << endl;
    cout << "  Gx size: " << Gx.n_elem << ", range: [" << Gx.min() << ", " << Gx.max() << "]" << endl;
    cout << "  Gy size: " << Gy.n_elem << ", range: [" << Gy.min() << ", " << Gy.max() << "]" << endl;
    cout << "  Gz size: " << Gz.n_elem << ", range: [" << Gz.min() << ", " << Gz.max() << "]" << endl;
    cout << endl;

    // Compute gradient magnitude at a sample point
    double mag_sample = sqrt(Gx(0)*Gx(0) + Gy(0)*Gy(0) + Gz(0)*Gz(0));
    cout << "Sample gradient magnitude at first point: " << mag_sample << endl;
    cout << endl;

    cout << "\033[1;32mCurvilinear gradient computation completed successfully!\033[0m" << endl;
    cout << "\nNote: For visualization, export the results to a file and use" << endl;
    cout << "      visualization tools like ParaView, VisIt, or MATLAB." << endl;
    cout << endl;

    return 0;
}
