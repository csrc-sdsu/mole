/**
 * This example uses MOLE to solve the 1D Schrodinger equation
 */

#include "mole.h"
#include <algorithm>
#include <iostream>

int main() {

  int k = 4;   // Operators' order of accuracy
  Real a = -5; // Left boundary
  Real b = 5;  // Right boundary
  int m = 500; // Number of cells
  vec grid = linspace(a, b, m);
  Real dx = grid(1) - grid(0); // Step size

  // Get mimetic Laplacian operator
  Laplacian L(k, m - 2, dx);

  std::transform(grid.begin(), grid.end(), grid.begin(),
                 [](Real x) { return x * x; });

  sp_mat V(m, m); // Potential energy operator
  V.diag(0) = grid;

  // Hamiltonian
  sp_mat H = -0.5 * (sp_mat)L + V;

  cx_vec eigval;
  eig_gen(eigval, (mat)H); // Compute eigenvalues

  eigval = sort(eigval);

  cout << "Energy levels = [ ";
  for (int i = 0; i < 4; ++i)
    cout << real(eigval(i) / eigval(0)) << ' ';
  cout << "]\n";

  return 0;
}
