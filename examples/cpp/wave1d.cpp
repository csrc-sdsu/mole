#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <gnuplot-iostream.h>
#include "./src/cpp/laplacian.h" 
#include <armadillo>

int main() {
    // Parameters
    const int m = 50;          // Number of cells
    const double a = 0.0;      // Left boundary
    const double b = 1.0;      // Right boundary
    const double dx = (b - a)/m;
    const double c = 2.0;      // Wave speed
    const double dt = dx/(2*c);// Time step (CFL condition)
    const double T = 1.0;      // Total simulation time
    const int n_steps = static_cast<int>(T/dt);

    // Staggered grid (displacement nodes)
    arma::vec xgrid = arma::linspace(a, b, m+2);

    // Create Laplacian operator (k=2 for 2nd order accuracy)
    Laplacian L(2, m, dx);
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    
    // Initial conditions
    arma::vec u = arma::sin(M_PI * xgrid);
    arma::vec v = arma::zeros<arma::vec>(m+2);

    // Time integration (Position Verlet)
    for (int step = 0; step <= n_steps; step++) {
        // First half-step: update displacement
        u += 0.5 * dt * v;

        // Update velocity using the Laplacian operator
        arma::vec Lu = L_sp * u;
        arma::vec F = c * c * Lu;
        v += dt * F;

        // Second half-step: update displacement
        u += 0.5 * dt * v;

        // Save data for plotting
        std::ofstream outfile("solution_" + std::to_string(step) + ".dat");
        for (int i = 0; i < m+2; i++) {
            outfile << xgrid(i) << " " << u(i) << std::endl;
        }
    }

    // Plot using Gnuplot
    Gnuplot gp;
    gp << "set terminal qt\n";
    gp << "set xlabel 'x'\n";
    gp << "set ylabel 'u(x)'\n";
    gp << "set yrange [-1.5:1.5]\n";
    gp << "set grid\n";
    
    // Animation loop
    for (int step = 0; step <= n_steps; step++) {
        gp << "set title '1D Wave equation t = " << step*dt << "'\n";
        gp << "plot 'solution_" << step << ".dat' w linespoints title 't = " 
           << step*dt << "' pt 7 ps 0.5\n";
        gp.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    std::cout << "Press Enter to exit and cleanup files..." << std::endl;
    std::cin.get();

    // Cleanup solution files
    for (int step = 0; step <= n_steps; step++) {
        std::string filename = "solution_" + std::to_string(step) + ".dat";
        std::remove(filename.c_str());
    }

    return 0;
}