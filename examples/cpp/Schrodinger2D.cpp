#include "mole.h"
#include <iostream>
#include <cmath>
#include <iomanip>

using namespace arma;

int main() {
    int p =105;// k: Number of time steps for the simulation (to match matlab))
    double Lxy = 1.0;
    int k = 2;
    int m = 50;
    int n = 50;
    int nx = 2;
    int ny = 2;
    double dx = Lxy / m;
    double dy = Lxy / n;
    double dt = dx / 2;

    // Create grid points in x and y directions
    vec xgrid = linspace(0, Lxy, m + 2);
    vec ygrid = linspace(0, Lxy, n + 2);

    // Initialize 2D mesh grid matrices X and Y
    mat X, Y;

    // Create an instance of Utils to call the meshgrid function
    Utils utils;
    utils.meshgrid(xgrid, ygrid, X, Y);

    // Initialize Laplacian operator and apply Robin boundary conditions
    Laplacian L(k, m, n, dx, dy);
    RobinBC BC(k, m, 1, n, 1, 1, 0);
    L = L + BC;

    // Define initial conditions for psi and velocity (v)
    double A = 0.1;
    vec psi_old = vectorise(A * sin(nx * M_PI / Lxy * X) % sin(ny * M_PI / Lxy * Y));
    vec v_old(psi_old.n_elem, fill::zeros);

    // Set output precision to match MATLAB's precision for comparison
    std::cout << std::scientific;
    std::cout.precision(10);

    // Initialize Psi_re matrix once outside the loop
    mat Psi_re(m + 2, n + 2, fill::zeros);


    // Time-stepping loop
    for (int t = 0; t <= p; ++t) {
        // Leapfrog integration for updating psi and velocity
        psi_old += 0.5 * dt * v_old;
        v_old += dt * (L * psi_old);
        psi_old += 0.5 * dt * v_old;

        // Reshape 1D psi vector into 2D matrix for output
        Psi_re = reshape(psi_old, m + 2, n + 2);

        std::cout << "Time step " << t << std::endl;
        for (size_t i = 0; i < m + 1; ++i) {
            for (size_t j = 0; j < n + 2; ++j) {
                std::cout << std::fixed << std::setprecision(5)
                          << X(i, j) << " " << Y(i, j) << " "
                          << Psi_re(i, j) << std::endl;
            }
        }
        std::cout << "---- End of Time step " << t << " ----" << std::endl;
    }


    std::cout << "Simulation complete" << std::endl;

    return 0;
}