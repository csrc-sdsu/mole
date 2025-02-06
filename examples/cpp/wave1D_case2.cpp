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
    const int k = 4;           // Order of accuracy (spatial)
    const int m = 101;         // Number of cells
    const double a = 1.0;      // Left boundary
    const double b = 4.0;      // Right boundary
    const double dx = (b-a)/m; // Step length
    const bool verlet = true;  // If false, use Forest-Ruth algorithm
    const double c = 100.0;    // Wave speed
    const double dt = dx/(2*c);// Time step (CFL condition)
    const double T = 0.06;     // Total simulation time
    const int n_steps = static_cast<int>(T/dt);

    // Staggered grid (displacement nodes)
    arma::vec xgrid = arma::linspace(a, b, m+2);

    // Create Laplacian operator (k=4 for 4th order accuracy)
    Laplacian L(k, m, dx);
    const arma::sp_mat& L_sp = static_cast<const arma::sp_mat&>(L);
    
    // Initial conditions: sin(pi*x) for 2 < x < 3, 0 elsewhere
    arma::vec u(m+2);
    for(int i = 0; i < m+2; i++) {
        double x = xgrid(i);
        u(i) = (x > 2.0 && x < 3.0) ? std::sin(M_PI * x) : 0.0;
    }
    arma::vec v = arma::zeros<arma::vec>(m+2);

    // Forest-Ruth parameter
    const double theta = 1.0/(2.0-std::pow(2.0, 1.0/3.0));

    // Time integration (Position Verlet)
    for (int step = 0; step <= n_steps; step++) {
        if (verlet) {
            // Position Verlet algorithm
            u += 0.5 * dt * v;
            arma::vec Lu = L_sp * u;
            arma::vec F = c * c * Lu;
            v += dt * F;
            u += 0.5 * dt * v;
        } else {
            // Forest-Ruth algorithm
            arma::vec unew = u + theta * 0.5 * dt * v;
            arma::vec Lu = L_sp * unew;
            arma::vec vnew = v + theta * dt * (c * c * Lu);
            
            unew = unew + (1.0-theta) * 0.5 * dt * vnew;
            Lu = L_sp * unew;
            vnew = vnew + (1.0-2.0*theta) * dt * (c * c * Lu);
            
            unew = unew + (1.0-theta) * 0.5 * dt * vnew;
            Lu = L_sp * unew;
            vnew = vnew + theta * dt * (c * c * Lu);
            
            unew = unew + theta * 0.5 * dt * vnew;
            
            u = unew;
            v = vnew;
        }

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
    gp << "set xrange [1:4]\n";
    gp << "set grid\n";
    gp << "set xtics ('0' 1, '0.5' 2.5, '1' 4)\n";  // Match MATLAB xticks
    gp << "set style line 1 linewidth 2\n";         // Match MATLAB line width
    
    // Animation loop
    for (int step = 0; step <= n_steps; step++) {
        gp << "set title '1D Wave equation t = " << step*dt << "'\n";
        gp << "plot 'solution_" << step << ".dat' with lines linestyle 1 notitle\n";
        gp.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(150));
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