#include "mole.h"  // Include the MOLE library
#include <iostream>
#include <cmath>    // For sin()
#include <iomanip>  // For setprecision

// Function prototype for f(t, y)
double f(double t, double y);

int main() {
    double h = 0.1;               // Step size
    double t_start = 0.0;         // Initial time
    double t_end = 5.0;           // Final time

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
        double k1 = f(t(i), y(i));
        double k2 = f(t(i) + h / 2.0, y(i) + h / 2.0 * k1);
        
        y(i + 1) = y(i) + h * k2;
    }

    // Print results
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "t\t\ty\n";
    for (int i = 0; i < n_steps; ++i) {
        std::cout << t(i) << "\t" << y(i) << "\n";
    }

    return 0;
}

// Function definition for f(t, y)
double f(double t, double y) {
    return pow(sin(t), 2) * y;
}