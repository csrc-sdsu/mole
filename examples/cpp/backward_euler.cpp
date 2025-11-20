/**
 * @file backward_euler.cpp
 * @brief Solves a first-order ODE with backward euler method with an initial value condition.
 * Equation: $\frac{dy}{dt} = \sin^2(t) \cdot y$
 * Domain: N/A
 * Boundary Conditions: N/A
 */

#include "mole.h"
#include <iostream>
#include <iomanip>
#include <cmath>

using namespace arma;

// Function declaration for f(t, y)
double f(double t, double y);

int main() {
    // Problem parameters
    constexpr double h = 0.01;  // Step-size h
    vec t = arma::regspace(0, h, 5);  // Calculates up to y(5) at step-size h
    arma::mat y = arma::mat(1, t.size(), arma::fill::zeros);

    // Initial conditions
    y(0) = 2.0;
    
    // Backward Euler method
    for (int i = 0; i < t.size()-1; i++) {
        double y_old = y(i);
        double tol = 1e-6;
        for (int k = 0; k < 100; k++) {     // fixed-point iteration for rootfinding
            y(i+1) = y_old + h*f(t(i+1), y_old);    // Backward euler method
            if (std::abs(y(i+1) - y_old) / y(i+1) < tol) {   // Stopping criteria for approximate relative error
                break;
            }
        }
    }

    //  Create a GNUplot script file
    std::ofstream plot_script("plot.gnu");
    if (!plot_script) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }
    plot_script << "set title 'Approximation to y(t) using Backward Euler'\n";
    plot_script << "set xlabel 't'\n";
    plot_script << "set ylabel 'y'\n";
    plot_script << "plot '-' using 1:2 with lines\n";
    
    // Print the time and solution values
    for (int i = 0; i < t.size(); ++i) {
        // output to stdout
        std::cout << t(i) << " " << y(i) << "\n";
        // AND output to plot_script (plot.gnu)
        plot_script << t(i) << " " << y(i) << "\n";
    }
    plot_script.close();

    // Execute GNUplot using the script
    if (system("gnuplot -persist plot.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }
}

// Function definition for f(t, y)
double f(double t, double y) {
    return std::pow(std::sin(t), 2) * y;
}