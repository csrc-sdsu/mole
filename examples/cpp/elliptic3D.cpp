/**
 * This example uses MOLE to solve a 3D BVP
 * It is the equivalent to examples_MATLAB/elliptic3D.m
 */

#include <iostream>
#include "mole.h"

int main() {
  constexpr int k = 2;  // Operators' order of accuracy
  constexpr int m = 5;  // Vertical resolution
  constexpr int n = 6;  // Horizontal resolution
  constexpr int p = 7;  // Depth resolution

  // Grid spacing in the x, y, and z directions
  constexpr double dx = 1.0;
  constexpr double dy = 1.0;
  constexpr double dz = 1.0;

  // Get mimetic operators
  Laplacian L(k, m, n, p, dx, dy, dz);
  RobinBC BC(k, m, dx, n, dy, p, dz, 1, 0);  // Dirichlet BC
  L = L + BC;

  // Build RHS for system of equations
  arma::cube rhs(m + 2, n + 2, p + 2, arma::fill::zeros);
  rhs.slice(0).fill(100);


  arma::vec sol;  // Declare sol here

#ifdef SuperLU
  cout << "Using SuperLU solver" << endl;
  // Use SuperLU (faster) if available
  sol = arma::spsolve(L, arma::vectorise(rhs));  // Will use SuperLU
#elif EIGEN
  cout << "Using Eigen solver" << endl;
  sol = arma::Utils::spsolve_eigen(L, arma::vectorise(rhs));
#else
  cerr << "Error: No solver available." << endl;
  return -1;  // Exit if no solver is available
#endif

  // Print out the solution
  arma::cube sol_cube = arma::cube(sol.memptr(), m + 2, n + 2, p + 2);
  cout << sol_cube;

  return 0;
}
