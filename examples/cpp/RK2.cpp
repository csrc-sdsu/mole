#include "mole.h"  
#include <iostream>
#include <sstream>  
#include <cmath>    
#include <iomanip>  

// Defines the ODE: dy/dt = sin^2(t) * y
double f(double t, double y);

int main() {
    constexpr double h = 0.1;      // Time step for the RK2 method
    double t_start = 0.0;          // Start of the time interval
    double t_end = 5.0;            // End of the time interval

    int n_steps = static_cast<int>((t_end - t_start) / h) + 1;

    // Vectors to store time points and numerical solutions
    vec t(n_steps);               
    vec y(n_steps);              

    // Initial conditions for the ODE
    t(0) = t_start;
    y(0) = 2.0; 

    // Compute the time points
    for (int i = 1; i < n_steps; ++i) {
        t(i) = t(i - 1) + h;
    }

    // Solve the ODE using the 2nd-order Runge-Kutta (RK2) method
    for (int i = 0; i < n_steps - 1; ++i) {
        double k1 = f(t(i), y(i));                            // Approximate slope at the beginning
        double k2 = f(t(i) + h / 2.0, y(i) + h / 2.0 * k1);   // Corrected slope at midpoint
        y(i + 1) = y(i) + h * k2;                            // Update solution
    }

    // Open a pipe to send data and commands to GNUplot for visualization
    FILE* gnuplot = popen("gnuplot -persist", "w");
    if (!gnuplot) {
        std::cerr << "Error: Failed to open GNUplot.\n";
        return 1;
    }

    // Set up the plot in GNUplot
    fprintf(gnuplot, "set title 'RK2 Solution to ODE'\n");
    fprintf(gnuplot, "set xlabel 't'\n");
    fprintf(gnuplot, "set ylabel 'y'\n");
    fprintf(gnuplot, "plot '-' using 1:2 with lines title 'RK2 Solution'\n");

    // Send the computed data to GNUplot
    for (int i = 0; i < n_steps; ++i) {
        fprintf(gnuplot, "%f %f\n", t(i), y(i));
    }

    // Signal the end of data input to GNUplot
    fprintf(gnuplot, "e\n");

    // Close the GNUplot pipe
    pclose(gnuplot);

    return 0;
}

// Defines the right-hand side of the ODE
double f(double t, double y) {
    return std::pow(std::sin(t), 2) * y;
}