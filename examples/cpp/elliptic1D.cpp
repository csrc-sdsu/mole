/**
 * This example uses MOLE to solve a 1D BVP
 */

#include "mole.h"
#include <iostream>

int main() {

  int k = 6;             // Operators' order of accuracy
  Real a = 0;            // Left boundary
  Real b = 1;            // Right boundary
  int m = 2 * k + 1;     // Number of cells
  Real dx = (b - a) / m; // Step size

  // Get mimetic operators
  Laplacian L(k, m, dx);
  Real d = 1; // Dirichlet coefficient
  Real n = 1; // Neumann coefficient
  RobinBC BC(k, m, dx, d, n);
  L = L + BC;

  // 1D Staggered grid
  vec grid(m + 2);
  grid(0) = a;
  grid(1) = a + dx / 2.0;
  int i;
  for (i = 2; i <= m; i++) {
    grid(i) = grid(i - 1) + dx;
  }
  grid(i) = b;

  // Build RHS for system of equations
  vec rhs(m + 2);
  rhs = exp(grid); // rhs(0) = 1
  rhs(0) = 0;
  rhs(m + 1) = 2 * exp(1); // rhs(1) = 2e

  // Solve the system of linear equations
#ifdef EIGEN
  // Use Eigen only if SuperLU (faster) is not available
  vec sol = Utils::spsolve_eigen(L, rhs);
#else
  vec sol = spsolve(L, rhs); // Will use SuperLU
#endif

  // Print out the solution
  cout << sol;

  return 0;
}
