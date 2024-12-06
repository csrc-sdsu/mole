#include "mole.h"         
#include <iostream>       
#include <armadillo>     
#include <cmath>          
#include <iomanip>        
#include "laplacian.h"    
#include "robinbc.h"      
#include "utils.h"        

using namespace arma;     

// Function to create a 2D mesh grid from 1D vectors x and y
void meshgrid(const vec &x, const vec &y, mat &X, mat &Y) {
    X.set_size(y.n_elem, x.n_elem); // Initialize matrix sizes
    Y.set_size(y.n_elem, x.n_elem);
    for (size_t i = 0; i < y.n_elem; ++i) {
        X.row(i) = x.t();          // Assign rows of X as transposed x
        Y.row(i).fill(y(i));       // Fill rows of Y with corresponding y value
    }
}

int main() {
    
    double Lxy = 1.0;         // Domain size in x and y directions
    int k = 2;                // Laplacian operator stencil size
    int m = 50;               // Number of grid points in x-direction
    int n = 50;               // Number of grid points in y-direction
    int nx = 2;               // Frequency parameter for initial condition (x)
    int ny = 2;               // Frequency parameter for initial condition (y)
    double dx = Lxy / m;      // Grid spacing in x-direction
    double dy = Lxy / n;      // Grid spacing in y-direction
    double dt = dx / 2;       // Time step size 

    // Create grid points in x and y directions
    vec xgrid = linspace(0, Lxy, m + 2);
    vec ygrid = linspace(0, Lxy, n + 2);

    // Initialize 2D mesh grid matrices X and Y
    mat X, Y;
    meshgrid(xgrid, ygrid, X, Y);

    // Initialize Laplacian operator and apply Robin boundary conditions
    Laplacian L(k, m, n, dx, dy);
    RobinBC BC(k, m, 1, n, 1, 1, 0);
    L = L + BC;  // Combine Laplacian and boundary conditions

    // Define initial conditions for psi and velocity (v)
    double A = 0.1; // Amplitude of the initial condition
    vec psi_old = vectorise(A * sin(nx * M_PI / Lxy * X) % sin(ny * M_PI / Lxy * Y));
    vec v_old(psi_old.n_elem, fill::zeros); // Initialize velocity to zero

    // Set output precision to match MATLAB's precision for comparison
    std::cout << std::scientific;  
    std::cout.precision(10);      

    // Time-stepping loop
    for (int t = 0; t <= 105; ++t) {
        // Leapfrog integration for updating psi and velocity
        psi_old += 0.5 * dt * v_old;     // First half-step for psi
        v_old += dt * (L * psi_old);     // Full step for velocity
        psi_old += 0.5 * dt * v_old;     // Second half-step for psi

        // Reshape 1D psi vector into 2D matrix for output
        mat Psi_re = reshape(psi_old, m + 2, n + 2);

        // Print results to the terminal
        std::cout << "Time step: " << t << std::endl;
        for (size_t i = 0; i < m + 2; ++i) {
            for (size_t j = 0; j < n + 2; ++j) {
                std::cout << std::fixed << std::setprecision(2)
                          << X(i, j) << " " << Y(i, j) << " "
                          << Psi_re(i, j) << std::endl;
            }
        }
    }

    return 0; // End of program
}
