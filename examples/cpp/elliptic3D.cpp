/**
 * This example uses MOLE to solve a 3D BVP
 * It is the equivalent to examples_MATLAB/elliptic3D.m
 */

#include "mole.h"
#include <iostream>

int main() {
  int k = 2; // Operators' order of accuracy
  int m = 5; // Vertical resolution
  int n = 6; // Horizontal resolution
  int p = 7; // Depth resolution

  // Get mimetic operators
  Laplacian L(k, m, n, p, 1, 1, 1);
  RobinBC BC(k, m, 1, n, 1, p, 1, 1, 0); // Dirichlet BC
  L = L + BC;

  // Build RHS for system of equations
  cube rhs(m + 2, n + 2, p + 2, fill::zeros);
//   rhs.slice(0) = 100 * ones(n + 2, p + 2); // Known value at the bottom boundary
  rhs.slice(0).fill(100); 

  // Solve the system of linear equations
#ifdef EIGEN
    // Use Eigen only if SuperLU (faster) is not available
    vec sol = Utils::spsolve_eigen(L, vectorise(rhs));
#else
    vec sol = spsolve(L, vectorise(rhs)); // Will use SuperLU
#endif

    // Print out the solution
    // cout << reshape(sol, m + 2, n + 2, p + 2);
    arma::cube sol_cube = arma::cube(sol.memptr(), m + 2, n + 2, p + 2);
    cout << sol_cube;
    
    return 0;
    }

