#include <iostream>
#include <armadillo>
#include <cmath>
#include "mole.h"

using namespace arma;
using namespace std;

int main() {
    double west = -15.0;
    double east = 15.0;
    int k = 2;
    int m = 300;
    double dx = (east - west) / m;
    double t = 10.0;
    double dt = dx;
    
    Divergence D(k, m, dx);  // Using the Divergence class
    Interpol I(m, 1.0);      // Using the Interpol class
    
    vec xgrid = linspace<vec>(west, east, m+2);
    xgrid = xgrid.subvec(1, m+1);  // Ensures size is (301)
    n
    vec U = exp(-square(xgrid) / 50.0);  // Correct size (301 × 1)
    
    mat D_matrix = (-dt / 2) * mat(I) * mat(D); // (301 × 301)

    // Time integration loop
    for (double time = 0; time <= t; time += dt) {
        double area = sum(U) * dx;  // Area conservation (analogous to trapz in MATLAB)
        
        // Print the output directly to the terminal
        cout << "%% Time step: " << (int)(time / dt) << ", Time: " << time << endl;
        
        // Print xgrid
        cout << "xgrid = [";
        for (size_t i = 0; i < xgrid.n_elem; ++i) {
            cout << xgrid(i);
            if (i != xgrid.n_elem - 1) cout << ", ";
        }
        cout << "]" << endl;

        // Print U
        cout << "U = [";
        for (size_t i = 0; i < U.n_elem; ++i) {
            cout << U(i);
            if (i != U.n_elem - 1) cout << ", ";
        }
        cout << "]" << endl << endl;
        
        U = U + D_matrix * square(U);  // Update U
    }
    
    return 0;
}
