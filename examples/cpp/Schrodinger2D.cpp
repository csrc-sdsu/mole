#include "mole.h"
#include <iostream>
#include <cmath>
#include <iomanip>
#include <vector>

using namespace arma;


std::vector<std::vector<double>> interpol2D(int m, int n, double dx, double dy) {
    std::vector<std::vector<double>> result(m + 2, std::vector<double>(n + 2, 1.0)); 
    return result;
}

std::vector<std::vector<double>> interpolD2D(int m, int n, double dx, double dy) {
    std::vector<std::vector<double>> result(m + 2, std::vector<double>(n + 2, 0.5)); 
    return result;
}

int main() {
    int p = 105; // Number of time steps for the simulation
    double Lxy = 1.0;
    int k = 2; // Order of accuracy
    int m = 50; // Grid points in x
    int n = 50; // Grid points in y
    int nx = 2; // Energy level in x
    int ny = 2; // Energy level in y
    double dx = Lxy / m; // Step in x
    double dy = Lxy / n; // Step in y
    double dt = dx; // Time step

    // Define staggered grids
    vec xgrid = join_vert(vec({0}), linspace(dx / 2, Lxy - dx / 2, m), vec({Lxy}));
    vec ygrid = join_vert(vec({0}), linspace(dy / 2, Lxy - dy / 2, n), vec({Lxy}));

    // Initialize 2D staggered grid
    mat X, Y;
    Utils utils;
    utils.meshgrid(xgrid, ygrid, X, Y);

    // Initialize Laplacian operator with Robin BC
    Laplacian L(k, m, n, dx, dy);
    RobinBC BC(k, m, 1, n, 1, 1, 0);
    L = L + BC;

    // Ensure the Laplacian is square
    int total_size = (m + 2) * (n + 2); // Total size for the grid including boundaries
    std::cout << "Laplacian L has size: " << L.n_rows << " x " << L.n_cols << std::endl;

    // Hamiltonian definition
    auto H = [&](const vec &x) { 
        return 0.5 * (L * x);  // This should produce a vector of size (m+2)*(n+2)
    };

    // Initial conditions: Ensure psi_old is initialized with the correct size
    double A = 2 / Lxy;

    // Initialize the wavefunction psi_old
    vec psi_old = vectorise(A * sin(nx * M_PI / Lxy * X) % sin(ny * M_PI / Lxy * Y));
    psi_old = reshape(psi_old, total_size, 1); // Ensure it is of size (m+2)*(n+2)

    vec v_old(psi_old.n_elem, fill::zeros);

    // Initialize Psi_re with zeros before the loop
    mat Psi_re = zeros<mat>(m + 2, n + 2); // Initialize with zeros

    // Time-stepping loop (Position Verlet)
    for (int t = 0; t <= p; ++t) {
        // Debug: Print vector sizes to check compatibility
        std::cout << "Time Step " << t << ": psi_old size = " << psi_old.n_elem
                  << ", v_old size = " << v_old.n_elem << std::endl;

        // Apply the first interpolation to update psi_old
        std::vector<std::vector<double>> I2 = interpol2D(m, n, dx, dy);  // Identity interpolation (for simplicity)

        // Position Verlet algorithm: Update psi_old based on v_old
        for (int ix = 0; ix < m + 2; ++ix) {
            for (int iy = 0; iy < n + 2; ++iy) {
                int index = ix * (n + 2) + iy;
                psi_old(index) += 0.5 * dt * v_old(index); // Apply the velocity update
            }
        }

        // Calculate v_new using the Hamiltonian
        vec v_new = v_old + 0.5 * dt * H(psi_old); // Hamiltonian is multiplied by the timestep

        // Update psi_new based on the new velocity v_new
        for (int ix = 0; ix < m + 2; ++ix) {
            for (int iy = 0; iy < n + 2; ++iy) {
                int index = ix * (n + 2) + iy;
                psi_old(index) += 0.5 * dt * v_new(index); // Final update for psi_old
            }
        }

        // Update Psi_re directly without reshaping each time
        Psi_re = reshape(psi_old, m + 2, n + 2); // Reshape once, update in place

        // Only output results for the last time step
        if (t == p) {
            std::cout << "Time Step: " << t << std::endl;
            std::cout << "X, Y, Psi" << std::endl;
            for (size_t i = 0; i < Psi_re.n_rows; ++i) {
                for (size_t j = 0; j < Psi_re.n_cols; ++j) {
                    std::cout << std::fixed << std::setprecision(5)
                              << X(i, j) << ", " << Y(i, j) << ", " << Psi_re(i, j) << std::endl;
                }
            }
            std::cout << "--- End of Time Step " << t << " ---" << std::endl;
        }

        // Update variables for next time step
        v_old = v_new;
    }

    std::cout << "Simulation complete." << std::endl;
    return 0;
}
