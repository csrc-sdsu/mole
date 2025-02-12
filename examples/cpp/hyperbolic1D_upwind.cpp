#include "mole.h"
#include <iostream>
#include <cmath>
#include <thread>

using namespace std::chrono_literals;
constexpr double pi = 3.14159;

sp_mat sidedNodalTemp(int m, double dx, const std::string& type) {

    // Create a sparse matrix of size (m+1) x (m+1)
    sp_mat S(m + 1, m + 1);
    if (type == "backward") {
        // Backward difference
        S.diag(-1) = -ones<vec>(m);  // Sub-diagonal
        S.diag(0) = ones<vec>(m + 1);    // Main diagonal
        S(0, m - 1) = -1;                // Wrap-around for periodic boundary
        S /= dx;
    } else if (type == "forward") {
        // Forward difference
        S.diag(0) = -ones<vec>(m + 1);   // Main diagonal
        S.diag(1) = ones<vec>(m);    // Super-diagonal
        S(m, 1) = 1;                     // Wrap-around for periodic boundary
        S /= dx;
    } else { // "centered"
        // Centered difference
        S.diag(-1) = -ones<vec>(m);  // Sub-diagonal
        S.diag(1) = ones<vec>(m);    // Super-diagonal
        S(0, m - 1) = -1;                // Wrap-around for periodic boundary
        S(m, 1) = 1;                     // Wrap-around for periodic boundary
        S /= (2 * dx);
    }

    return S;
}

int main()
{
    double a = 1.0;       // Velocity
    double west = 0.0;    // Domain's left limit
    double east = 1.0;    // Domain's right limit

    int m = 20;           // Number of cells
    double dx = (east - west) / m;  // Grid spacing

    double t = 1.0;       // Simulation time
    double dt = dx / std::abs(a);  // Time step based on CFL condition
    
    sp_mat S = sidedNodalTemp(m, dx, (a > 0) ? "backward" : "forward"); // Use "forward" if a < 0
    
    vec grid = arma::regspace(west, dx, east);
    vec U = sin(2 * pi * grid);

    S = speye<sp_mat>(S.n_rows, S.n_cols) - a * dt * S;
    
    // Open a pipe to GNUplot
    FILE *gnuplotPipe = popen("gnuplot -persistent", "w");
    if (!gnuplotPipe) {
        std::cerr << "Error opening GNUplot.\n";
        return 1;
    }
    
    int steps = t / dt;

    for (int i = 1; i <= steps; ++i) {
        U = S * U;  // Compute U^(n+1)

        // Save data to file for plotting
        std::ofstream dataFile("plot_data.dat");
        for (size_t j = 0; j < grid.n_elem; ++j) {
            dataFile << grid(j) << " " << U(j) << " "
            << std::sin(2 * pi * (grid(j) - a * i * dt)) << "\n";
        }
        dataFile.close();

        // Send plot commands to GNUplot
        fprintf(gnuplotPipe, "set title 't = %.2f'\n", i * dt);
        fprintf(gnuplotPipe, "set xlabel 'x'\n");
        fprintf(gnuplotPipe, "set ylabel 'u(x, t)'\n");
        fprintf(gnuplotPipe, "set xrange [%f:%f]\n", west, east);
        fprintf(gnuplotPipe, "set yrange [-1.5:1.5]\n");
        fprintf(gnuplotPipe, "plot 'plot_data.dat' using 1:2 with linespoints title 'Approximation', "
                             "'plot_data.dat' using 1:3 with lines title 'Exact Solution'\n");
        fflush(gnuplotPipe);

        std::this_thread::sleep_for(400ms);
    }

    // Close GNUplot
    pclose(gnuplotPipe);
    
   
    
}
