/**
 * This example uses MOLE to solve a 3D BVP
 * It visualizes the middle slice (z = p/2) using GNUplot
 * It is the equivalent to examples_MATLAB/elliptic3D.m
 */

#include <fstream>  // For writing data
#include <iostream>

#include "mole.h"

using namespace std;
using namespace arma;

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
  rhs.slice(0).fill(100);  // Set boundary condition at z = 0

  arma::vec sol;  // Declare sol

#ifdef SuperLU
  cout << "Using SuperLU solver" << endl;
  sol = arma::spsolve(L, arma::vectorise(rhs));  // Use SuperLU
#elif EIGEN
  cout << "Using Eigen solver" << endl;
  sol = arma::Utils::spsolve_eigen(L, arma::vectorise(rhs));
#else
  cerr << "Error: No solver available." << endl;
  return -1;
#endif

  // Reshape solution into a 3D cube
  arma::cube sol_cube(sol.memptr(), m + 2, n + 2, p + 2);

  // Save numerical solution to a file (for GNUplot)
  ofstream data_file("solution_data.txt");
  if (!data_file) {
    cerr << "Error: Unable to open file for writing data.\n";
    return 1;
  }

  // Save middle slice (z = p/2) for 2D visualization
  int mid_z = p / 2;
  for (int i = 0; i < m + 2; i++) {
    for (int j = 0; j < n + 2; j++) {
      data_file << i << " " << j << " " << sol_cube(i, j, mid_z) << "\n";
    }
    data_file << "\n";  // Blank line for GNUplot matrix format
  }
  data_file.close();
  cout << "Solution saved to solution_data.txt\n";

  // Generate GNUplot script
  ofstream plot_script("plot.gnu");
  if (!plot_script) {
    cerr << "Error: Failed to create GNUplot script.\n";
    return 1;
  }

  plot_script << "set title 'Numerical Solution (MOLE)'\n";
  plot_script << "set xlabel 'x'\n";
  plot_script << "set ylabel 'y'\n";
  plot_script << "set zlabel 'u'\n";
  plot_script << "set view map\n";
  plot_script << "set dgrid3d 20,20\n";
  plot_script << "set pm3d\n";
  plot_script << "splot 'solution_data.txt' using 1:2:3 with lines title "
                 "'Numerical Solution'\n";
  plot_script.close();

  // Execute GNUplot
  if (system("gnuplot -persist plot.gnu") != 0) {
    cerr << "Error: Failed to execute GNUplot.\n";
    return 1;
  }

  return 0;
}
