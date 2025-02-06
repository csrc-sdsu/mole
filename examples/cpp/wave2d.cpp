#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <gnuplot-iostream.h>
#include "./src/cpp/laplacian.h" 
#include "./src/cpp/robinbc.h"
#include <armadillo>

// Function to create meshgrid
void create_meshgrid(const arma::vec& x, const arma::vec& y, arma::mat& X, arma::mat& Y) {
    X = arma::repmat(x.t(), y.size(), 1);
    Y = arma::repmat(y, 1, x.size());
}

int main() {
    // Parameters
    const int k = 2;           // Order of accuracy
    const int m = 50;          // Number of cells along x-axis
    const int n = m;           // Number of cells along y-axis
    const double a = 0.0;      // West boundary
    const double b = 1.0;      // East boundary
    const double c = 0.0;      // South boundary
    const double d = 1.0;      // North boundary
    const double dx = (b-a)/m; // Step length along x-axis
    const double dy = (d-c)/n; // Step length along y-axis
    const double speed = 1.0;  // Wave speed
    const double dt = dx/(2*speed); // Time step (CFL condition)
    const double T = 1.0;      // Total simulation time
    const int n_steps = static_cast<int>(T/dt);

    // Create 2D grid
    arma::vec xgrid = arma::linspace(a, b, m+2);
    arma::vec ygrid = arma::linspace(c, d, n+2);
    arma::mat X, Y;
    create_meshgrid(xgrid, ygrid, X, Y);

    // Create Laplacian operator
    Laplacian L(k, m, n, dx, dy);
    RobinBC BC(k, m, dx, n, dy, 1.0, 0.0);
    
    // Cast to sp_mat before adding
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    const arma::sp_mat& BC_sp = static_cast<const arma::sp_mat&>(BC);
    arma::sp_mat combined = L_sp + BC_sp;

    // Initial conditions
    arma::mat U_init(m+2, n+2);
    for(size_t i = 0; i < m+2; ++i) {
        for(size_t j = 0; j < n+2; ++j) {
            U_init(i,j) = std::sin(M_PI * X(i,j)) * std::sin(M_PI * Y(i,j));
        }
    }
    arma::vec u = arma::vectorise(U_init);
    arma::vec v = arma::zeros<arma::vec>((m+2)*(n+2));

    // Time integration (Position Verlet)
    for (int step = 0; step <= n_steps; step++) {
        // First half-step: update displacement
        u += 0.5 * dt * v;

        // Update velocity using the Laplacian operator
        arma::vec Lu = combined * u;
        arma::vec F = speed * speed * Lu;
        v += dt * F;

        // Second half-step: update displacement
        u += 0.5 * dt * v;

        // Reshape for plotting
        arma::mat U_plot = arma::reshape(u, m+2, n+2);

        // Save data for plotting
        std::ofstream outfile("solution2d_" + std::to_string(step) + ".dat");
        for (size_t i = 0; i < m+2; ++i) {
            for (size_t j = 0; j < n+2; ++j) {
                outfile << X(i,j) << " " << Y(i,j) << " " << U_plot(i,j) << std::endl;
            }
            outfile << std::endl;
        }
    }

    // Plot using Gnuplot
    Gnuplot gp;
    gp << "set terminal qt\n";
    gp << "set xlabel 'x'\n";
    gp << "set ylabel 'y'\n";
    gp << "set zlabel 'z'\n";
    gp << "set view 60,30\n";
    gp << "set hidden3d\n";
    gp << "set pm3d\n";
    gp << "set zrange [-1:1]\n";
    
    // Animation loop
    for (int step = 0; step <= n_steps; step++) {
        gp << "set title '2D Wave equation t = " << step*dt << "'\n";
        gp << "splot 'solution2d_" << step << ".dat' using 1:2:3 with pm3d title ''\n";
        gp.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(70));
    }

    std::cout << "Press Enter to exit and cleanup files..." << std::endl;
    std::cin.get();

    // Cleanup solution files
    for (int step = 0; step <= n_steps; step++) {
        std::string filename = "solution2d_" + std::to_string(step) + ".dat";
        std::remove(filename.c_str());
    }

    return 0;
}