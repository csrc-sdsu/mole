/**
 * This example uses MOLE to solve 1D Maxwell's equations in free space.
 */

#include "mole.h"
#include <iostream>

int main() {
    int nt = 50;            // Number of time steps
    int m = 100;            // Number of cells
    int k = 2;              // Operators' order of accuracy
    Real a = 0;             // Left boundary
    Real b = 1;             // Right boundary
    Real dx = (b - a) / m;  // Step size
    Real dt = 0.5 * dx;     // CFL-based timestep

    // Get mimetic operators
    Divergence D(k, m, dx);
    D *= dt;
    Gradient G(k, m, dx);
    G *= dt;

    // Grids
    vec centers(m + 2);
    centers(0) = a;
    centers(1) = a + dx / 2.0;
    int i;
    for (i = 2; i <= m; i++)
        centers(i) = centers(i - 1) + dx;
    centers(i) = b;

    // Initialize fields
    vec B = zeros<vec>(m + 1);
    vec E = exp(-100.0 * square(centers - 0.5));  // Gaussian pulse

    // Leapfrog start: half-step back for B
    B -= 0.5 * (G * E);

    // Time stepping
    for (int n = 0; n < nt; ++n) {
        // Update B (edges)
        B -= G * E;

        // Store boundary values
        Real El = E(1);
        Real Er = E(m);

        // Update E (centers)
        E -= D * B;

        // Absorbing boundaries
        E(0)     = El;
        E(m + 1) = Er;
    }

    vec edges = linspace(a, b, m + 1);

    // Dump fields to stdout
    for (size_t i = 0; i < centers.n_elem; ++i)
        cout << centers(i) << " " << E(i) << endl;

    cout << endl;

    for (size_t i = 0; i < edges.n_elem; ++i)
        cout << edges(i) << " " << B(i) << endl;

    return 0;
}
