/**
 * Energy test
 */

#include "mole.h"
#include <algorithm>
#include <iostream>

int main() {

  int k = 4;
  Real a = -5;
  Real b = 5;
  int m = 500;
  vec grid = linspace(a, b, m);
  Real dx = grid(1) - grid(0);
  Real tol = 1e-10;

  Laplacian L(k, m - 2, dx);

  std::transform(grid.begin(), grid.end(), grid.begin(),
                 [](Real x) { return x * x; });

  sp_mat V(m, m);
  V.diag(0) = grid;

  sp_mat H = -0.5 * (sp_mat)L + V;

  cx_vec eigval;
  eig_gen(eigval, (mat)H);

  eigval = sort(eigval);

  vec expected{1, 3, 5, 7, 9};

  bool failed = false;
  for (int i = 0; i < expected.size(); ++i)
    if (std::norm(real(eigval(i) / eigval(0)) - expected(i)) > tol) {
      cout << "\033[1;31mTest FAILED!\033[0m\n";
      failed = true;
    }

  if (!failed)
    cout << "\033[1;32mTest PASSED!\033[0m\n";

  return 0;
}
