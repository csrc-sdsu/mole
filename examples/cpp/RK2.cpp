//  RK2.cpp
 
// Description:
// This program solves a first-order ordinary differential equation (ODE) of the form:
//     dy/dt = sin^2(t) * y
// using the second-order Runge-Kutta (RK2) method. The solution is computed over the 
// time interval [0, 5] with an initial condition y(0) = 2.0.

#include "mole.h"
#include <iostream>
#include <sstream>  // For string streams
#include <fstream>  // For file output
#include <cmath>    // For sin()
#include <iomanip>  // For setprecision

// Function prototype for f(t, y)
double f(double t, double y);

int main() {
    constexpr double h = 0.1;       // Step size
    constexpr double t_start = 0.0; // Initial time
    constexpr double t_end = 5.0;   // Final time

    int n_steps = static_cast<int>((t_end - t_start) / h) + 1;

    // MOLE's vec type for vectors
    vec t(n_steps);              // Time vector
    vec y(n_steps);              // Solution vector

    // Initial conditions
    t(0) = t_start;
    y(0) = 2.0; 

    // Populate the time vector
    for (int i = 1; i < n_steps; ++i) {
        t(i) = t(i - 1) + h;
    }

    // RK2 Method
    for (int i = 0; i < n_steps - 1; ++i) {
        const double k1 = f(t(i), y(i));                              // Slope at the beginning
        const double k2 = f(t(i) + h / 2.0, y(i) + h / 2.0 * k1);     // Slope at midpoint
        y(i + 1) = y(i) + h * k2;                                    // Update solution
    }

    // Print the time and solution values to the standard output
    std::cout << std::fixed << std::setprecision(6);
    for (int i = 0; i < n_steps; ++i) {
        std::cout << t(i) << " " << y(i) << "\n";
    }

    // Generate GNUplot script
    std::ofstream plot_script("plot.gnu");
    if (!plot_script) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }

    plot_script << "set title 'RK2 Solution to ODE'\n";
    plot_script << "set xlabel 't'\n";
    plot_script << "set ylabel 'y'\n";
    plot_script << "plot 'data.txt' using 1:2 with lines title 'RK2 Solution'\n";
    plot_script.close();

    // Execute GNUplot using the script
    if (system("gnuplot -persist plot.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }
    return 0;
}

// Function definition for f(t, y)
double f(double t, double y) {
    return std::pow(std::sin(t), 2) * y;
}
