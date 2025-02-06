#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <chrono>
#include <thread>
#include <gnuplot-iostream.h>
#include "./src/cpp/laplacian.h" 
#include "./src/cpp/robinbc.h"
#include "./src/cpp/interpol.h"
#include <armadillo>

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

    // Create staggered grid
    arma::vec xvals = arma::regspace(a + dx/2, dx, b - dx/2);
    xvals = arma::join_cols(arma::vec({a}), arma::join_cols(xvals, arma::vec({b})));
    arma::vec yvals = arma::regspace(c + dy/2, dy, d - dy/2);
    yvals = arma::join_cols(arma::vec({c}), arma::join_cols(yvals, arma::vec({d})));
    arma::mat X, Y;
    create_meshgrid(xvals, yvals, X, Y);

    // Create operators
    Laplacian L(k, m, n, dx, dy);
    RobinBC BC(k, m, dx, n, dy, 1.0, 0.0);
    
    // Create interpolation operators
    Interpol I(m, n, 0.5, 0.5);          // Regular interpolation
    Interpol I2(true, m, n, 0.5, 0.5);   // Second type interpolation

    // Cast operators to sp_mat
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    const arma::sp_mat& BC_sp = static_cast<const arma::sp_mat&>(BC);
    arma::sp_mat I_sp = static_cast<arma::sp_mat>(I);
    arma::sp_mat I2_sp = static_cast<arma::sp_mat>(I2);
    arma::sp_mat combined = L_sp + BC_sp;

    // Scale interpolation operators
    I_sp = dt * I_sp;
    I2_sp = 0.5 * dt * I2_sp;

    // Initial conditions
    arma::mat U_init(m+2, n+2);
    for(size_t i = 0; i < m+2; ++i) {
        for(size_t j = 0; j < n+2; ++j) {
            U_init(i,j) = std::sin(M_PI * X(i,j)) * std::sin(M_PI * Y(i,j));
        }
    }
    arma::vec u = arma::vectorise(U_init);
    arma::vec v = arma::zeros<arma::vec>(I_sp.n_rows);  // Match interpolator dimensions

    // Time integration (Position Verlet)
    for (int step = 0; step <= n_steps; step++) {
        // Position Verlet with interpolation
        u += I2_sp * v;
        arma::vec Lu = combined * u;
        arma::vec F = speed * speed * Lu;
        v += I_sp * F;
        u += I2_sp * v;

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
    gp << "set terminal qt size 800,600 font 'Arial,12'\n";
    gp << "set xlabel 'x'\n";
    gp << "set ylabel 'y'\n";
    gp << "set zlabel 'z'\n";
    gp << "set view 60,30\n";
    gp << "set hidden3d\n";
    gp << "set pm3d\n";
    gp << "set zrange [-1:1]\n";
    gp << "set xrange [0:1]\n";
    gp << "set yrange [0:1]\n";
    gp << "set grid\n";
    gp << "set colorbox\n";
    gp << "set cbrange [-1:1]\n";
    
    // Animation loop
    for (int step = 0; step <= n_steps; step++) {
        gp << "set title 'Elastic membrane with position Verlet Time = " 
           << std::fixed << std::setprecision(2) << step*dt << "'\n";
        gp << "splot 'solution2d_" << step 
           << ".dat' using 1:2:3 with pm3d title ''\n";
        gp.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    // Cleanup
    std::cout << "Press Enter to exit and cleanup files..." << std::endl;
    std::cin.get();
    for (int step = 0; step <= n_steps; step++) {
        std::string filename = "solution2d_" + std::to_string(step) + ".dat";
        std::remove(filename.c_str());
    }

    return 0;
}
