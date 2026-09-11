/**
 * This example uses MOLE to solve a 3D Boundary Value Problem (BVP)
 * 
 * Mathematical Problem:
 * --------------------
 * Equation:    ∇²u = 0  (3D Laplace equation)
 *              where ∇² = ∂²/∂x² + ∂²/∂y² + ∂²/∂z²
 * 
 * Domain:      Ω = [0,m]×[0,n]×[0,p]  (3D rectangular domain)
 *              where in this example m=5, n=6, p=7 are the number of cells in each direction
 * 
 * Boundary Conditions:
 * ------------------
 * Front face (z=0):    u = 100
 * All other faces:     u = 0    (Dirichlet conditions)
 * 
 * Visualization:
 * -------------
 * The middle slice (z = p/2) is output for visualization using GNUplot
 */

#include <fstream>  
#include <iostream>
#include <cstdlib>

#include "mole.h"

using namespace std;

int main() {
  constexpr int k = 2;  // Operators' order of accuracy
  constexpr int m = 5;  // Vertical resolution
  constexpr int n = 6;  // Horizontal resolution
  constexpr int p = 7;  // Depth resolution

  // Output filenames
  const string DATA_FILENAME = "solution_data.txt";
  const string GNUPLOT_SCRIPT = "plot.gnu";

  // Grid spacing in the x, y, and z directions
  constexpr double dx = 1.0;
  constexpr double dy = 1.0;
  constexpr double dz = 1.0;

  // Boundary condition constants
  constexpr double DIRICHLET_COEF = 1.0;  // Coefficient for Dirichlet term in Robin BC
  constexpr double NEUMANN_COEF = 0.0;    // Coefficient for Neumann term in Robin BC

  // Get mimetic operators
  Laplacian L(k, m, n, p, dx, dy, dz);
  RobinBC BC(k, m, dx, n, dy, p, dz, DIRICHLET_COEF, NEUMANN_COEF);  // Dirichlet BC
  L = L + BC;

  // Build RHS for system of equations
  arma::cube rhs(m + 2, n + 2, p + 2, arma::fill::zeros);
  rhs.slice(0).fill(100);  // Set boundary condition at z = 0

  arma::vec sol;  // Declare sol

#ifdef EIGEN
    sol = arma::Utils::spsolve_eigen(L, arma::vectorise(rhs));
#else
    // Default to SuperLU if EIGEN is not defined
    sol = arma::spsolve(L, arma::vectorise(rhs));
#endif

  // Reshape solution into a 3D cube
  arma::cube sol_cube(sol.memptr(), m + 2, n + 2, p + 2);

  // Save numerical solution to a file (for GNUplot)
  ofstream data_file(DATA_FILENAME);
  if (!data_file) {
    cerr << "Error: Unable to open file for writing data.\n";
    return EXIT_FAILURE;
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
  cout << "Solution saved to " << DATA_FILENAME << "\n";

  // Generate GNUplot script
  ofstream plot_script(GNUPLOT_SCRIPT);
  if (!plot_script) {
    cerr << "Error: Failed to create GNUplot script.\n";
    return EXIT_FAILURE;
  }

  plot_script << "set title 'Numerical Solution (MOLE)'\n";
  plot_script << "set xlabel 'x'\n";
  plot_script << "set ylabel 'y'\n";
  plot_script << "set zlabel 'u'\n";
  plot_script << "set view map\n";
  plot_script << "set dgrid3d 20,20\n";
  plot_script << "set pm3d\n";
  plot_script << "splot '" << DATA_FILENAME << "' using 1:2:3 with lines title "
                 "'Numerical Solution'\n";
  plot_script.close();

  // Execute GNUplot
  string gnuplot_command = "gnuplot -persist " + GNUPLOT_SCRIPT;
  if (system(gnuplot_command.c_str()) != 0) {
    cerr << "Error: Failed to execute GNUplot.\n";
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
