/**
 * This example uses MOLE to solve a 2D BVP
 * It is the equivalent to examples_MATLAB/minimal_poisson2D.m
 * The output can be plotted via:
 * gnuplot> plot 'solution' matrix with image
 */

#include "mole.h"
#include <iostream>

int main() {
  int k = 2; // Operators' order of accuracy
  int m = 9; // Vertical resolution
  int n = 9; // Horizontal resolution

  // Get mimetic operators
  Laplacian L(k, m, n, 1, 1);
  RobinBC BC(k, m, 1, n, 1, 1, 0); // Dirichlet BC
  L = L + BC;

  // Build RHS for system of equations
  mat rhs(m + 2, n + 2, fill::zeros);
  rhs.row(0) = 100 * ones(1, n + 2); // Known value at the bottom boundary

  // Solve the system of linear equations
#ifdef EIGEN
  // Use Eigen only if SuperLU (faster) is not available
  vec sol = Utils::spsolve_eigen(L, vectorise(rhs));
#else
  vec sol = spsolve(L, vectorise(rhs)); // Will use SuperLU
#endif

  // Print out the solution
  cout << reshape(sol, m + 2, n + 2);

  return 0;
}
