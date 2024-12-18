#include "mole.h"    
#include <iostream>    
#include <cmath>    
#include <iomanip>    
#include <vector>    
#include <fstream>    
  
using namespace arma;    
  
int main() {    
  int p = 105;  // Number of time steps for the simulation    
  double Lxy = 1.0;    
  int k = 2;  // Order of accuracy    
  int m = 50; // Grid points in x    
  int n = 50; // Grid points in y    
  int nx = 2; // Energy level in x    
  int ny = 2; // Energy level in y    
  double dx = Lxy / m; // Step in x    
  double dy = Lxy / n; // Step in y    
  double dt = dx/2; // Reduced time step size with additional reduction    
  
  // Define staggered grids    
  vec xgrid = join_vert(vec({0}), linspace(dx / 2, Lxy - dx / 2, m), vec({Lxy}));    
  vec ygrid = join_vert(vec({0}), linspace(dy / 2, Lxy - dy / 2, n), vec({Lxy}));    
  
  // Initialize 2D staggered grid    
  mat X, Y;    
  Utils utils;    
  utils.meshgrid(xgrid, ygrid, X, Y);    
  
  // Debug grid sizes    
  std::cout << "Grid X size: " << X.n_rows << " x " << X.n_cols << std::endl;    
  std::cout << "Grid Y size: " << Y.n_rows << " x " << Y.n_cols << std::endl;    
  
  // Initialize Laplacian operator with Robin BC    
  Laplacian L(k, m, n, dx, dy);    
  RobinBC BC(k, m, 1, n, 1, 1, 0);    
  L = L + BC;    
  
  // Ensure the Laplacian is square    
  int total_size = (m + 2) * (n + 2); // Total size for the grid including boundaries    
  std::cout << "Laplacian L has size: " << L.n_rows << " x " << L.n_cols << std::endl;    
  
  // Hamiltonian definition with damping term    
  auto H = [&](const vec &x) {    
   vec result = 0.5 * (L * x);    
   for (size_t i = 0; i < x.n_elem; ++i) {    
    result(i) -= 0.01 * x(i); // Damping term    
   }    
   return result;    
  };    
  
  // Define wave numbers    
  auto kx = [&](int nx) { return nx * M_PI / Lxy; };    
  auto ky = [&](int ny) { return ny * M_PI / Lxy; };    
  
  double A = 2 / Lxy;    
  
  // Initialize the wavefunction psi_old    
  mat Psi_grid(m + 2, n + 2, fill::zeros);    
  
  // Manually pad Psi_grid    
  for (int i = 1; i <= m; i++) {    
   for (int j = 1; j <= n; j++) {    
    Psi_grid(i, j) = A * sin(kx(nx) * X(i, j)) * sin(ky(ny) * Y(i, j));    
   }    
  }    
  
  // Convert to column vector for compatibility    
  vec psi_old = vectorise(Psi_grid);  // Convert to column vector    
  
  // Debug size of psi_old    
  std::cout << "psi_old size: " << psi_old.n_elem << ", expected: " << total_size << std::endl;    
  
  if (psi_old.n_elem != total_size) {    
   std::cerr << "Error: psi_old size mismatch. Expected " << total_size    
    << ", got " << psi_old.n_elem << std::endl;    
   return -1;    
  }    
  
  vec v_old(total_size, fill::zeros); // Initialize v_old to the same size as psi_old    
  
  // Initialize Psi_re with zeros    
  mat Psi_re = zeros<mat>(m + 2, n + 2);    
  
  // Create 2D interpolator of the second type    
  Interpol I2(true, m, n, 0.5, 0.5);    
  
  // Create a new interpolator as a square matrix  
  mat I2_mat = conv_to<mat>::from(I2.submat(0, 0, 2703, 2703));  
  I2_mat = I2_mat.t() * I2_mat;  
  
  try {    
   // Time-stepping loop (Position Verlet)    
   double initial_energy = 0.5 * dot(psi_old, H(psi_old));    
   std::cout << "Initial energy: " << initial_energy << std::endl;    
  
   for (int t = 0; t <= p; ++t) {    
    // Debug: Print vector sizes to check compatibility    
    if (t == 0) {    
      std::cout << "Time Step " << t << ": psi_old size = " << psi_old.n_elem    
       << ", v_old size = " << v_old.n_elem << std::endl;    
    }    
  
    // Position Verlet algorithm: Update psi_old based on v_old    
    psi_old += 0.5 * dt * v_old;    
  
    // Apply interpolation to psi_old    
    vec interpolated_psi = I2_mat * psi_old;    
  
    // Calculate v_new using the Hamiltonian and interpolated psi    
    vec v_new = v_old + dt * H(psi_old);    
  
    // Check for NaN or infinity    
    if (v_new.has_nan() || v_new.has_inf()) {    
      std::cerr << "Error: v_new contains NaN or infinity." << std::endl;    
      return -1;    
    }    
  
    // Update psi_old based on v_new    
    psi_old += 0.5 * dt * v_new;    
  
    // Check for NaN or infinity    
    if (psi_old.has_nan() || psi_old.has_inf()) {    
      std::cerr << "Error: psi_old contains NaN or infinity." << std::endl;    
      return -1;    
    }    
  
    // Update Psi_re for output    
    Psi_re = reshape(psi_old, m + 2, n + 2);    
  
    // Monitor the energy    
    double current_energy = 0.5 * dot(psi_old, H(psi_old));    
    if (t == p) {    
      std::cout << "Final Time Step " << t << ": Energy = " << current_energy << std::endl;    
      std::cout << "X, Y, Psi" << std::endl;    
      for (size_t i = 0; i < Psi_re.n_rows; ++i) {    
       for (size_t j = 0; j < Psi_re.n_cols; ++j) {    
        std::cout << std::fixed << std::setprecision(5)    
         << X(i, j) << ", " << Y(i, j) << ", " << Psi_re(i, j) << std::endl;    
       }    
      }    
    }    
  
    // Update variables for the next time step    
    v_old = v_new;    
   }    
  } catch (const std::exception &e) {    
   std::cerr << "Error: " << e.what() << std::endl;    
   return -1;    
  }    
  
  std::cout << "Simulation complete." << std::endl;    
  return 0;    
}

