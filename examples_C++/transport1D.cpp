/**
 * This example uses MOLE to solve the 1D advection-reaction-dispersion 
 * equation: https://wwwbrr.cr.usgs.gov/projects/GWC_coupled/phreeqc/html/final-22.html
 */

#include <iostream>
#include "mole.h"

int main() {

    int     k = 2;        // Operators' order of accuracy
    real   a = 0;        // Left boundary
    real   b = 130;      // Right boundary
    int     m = 26;       // Number of cells
    real  dx = (b-a)/m;  // Cell's width [m]
    real   t = 4;        // Simulation time [years]
    int  iter = 208;      // Number of iterations
    real  dt = t/iter;   // Time step
    real dis = 5;        // Dispersivity [m]
    real vel = 15;       // Pore-water flow velocity [m/year]
    real   R = 2.5;      // Retardation (Cl^- = 1, Na^+ = 2.5)
    real  C0 = 1;        // Displacing solution concentration [mmol/kgw]

    // Get 1D mimetic operators
    Gradient G(k, m, dx);
    Divergence D(k, m, dx);
    Interpol I(m, 0.5);

    // Allocate fields
    vec C(m+2);  // Scalar field (concentrations)
    vec V(m+1);  // Vector field (velocities)

    // Impose initial conditions
    C(0) = C0;
    V.fill(vel);

    // Hydrodynamic dispersion coefficient [m^2/year]
    dis *= vel;  // 75

    // dt = dt/R (retardation)
    dt /= R;

    // Time integration loop
    for(int i = 0; i <= iter; i++) {

        // First-order forward-time scheme
        C += dt*(D*(dis*(G*C))-D*(V%(I*C)));

        // Right boundary condition (reflection)
        C(m+1) = C(m);
    }

    // Spit out the new concentrations!
    cout << C;

    return 0;
}
