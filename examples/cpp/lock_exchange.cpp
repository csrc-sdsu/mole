/**
 * lock_exchange.cpp
 *
 * A 2D lock‐exchange simulation using mimetic methods with the MOLE library.
 * The simulation uses the Boussinesq approximation to model nonisothermal flow
 * in a domain [0,100]x[0,20] (in meters) with 100×20 cells.
 */

#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include "mole.h"

using namespace arma;

// Forward declarations of GNU-related functions
void saveForGnuplot(const mat& matrix, const std::string& filename,
                    double x_start, double x_end, double y_start, double y_end,
                    double dx, double dy);
void saveVelocityForGnuplot(const mat& u, const mat& v,
                            const std::string& filename, int subsample,
                            double x_start, double x_end, double y_start,
                            double y_end);
void generateGnuplotScript(const std::string& scriptFilename, double x_start,
                           double x_end, double y_start, double y_end);

int main() {
  // ----------------------- Domain and Grid Setup -----------------------
  constexpr double a = 0.0, b = 100.0;  // x-domain [0, 100] meters
  constexpr double c = 0.0, d = 20.0;   // y-domain [0, 20] meters
  constexpr int m = 100;                // cells in x-direction
  constexpr int n = 20;                 // cells in y-direction
  const double dx = (b - a) / m;        // grid spacing in x
  const double dy = (d - c) / n;        // grid spacing in y

  // Create coordinate matrices (size: (n+2) x (m+2))
  mat X(n + 2, m + 2, fill::zeros);
  mat Y(n + 2, m + 2, fill::zeros);
  for (int i = 0; i < n + 2; i++) {
    for (int j = 0; j < m + 2; j++) {
      // Using cell-center approximations
      X(i, j) = a + (j - 0.5) * dx;
      Y(i, j) = c + (i - 0.5) * dy;
    }
  }

  // ----------------------- Variables Initialization -----------------------
  // Fields with extra boundary layers: (n+2) x (m+2)
  mat rho = zeros<mat>(n + 2, m + 2);  // Density [kg/m^3]
  mat T = zeros<mat>(n + 2, m + 2);    // Temperature [°C]
  mat p = zeros<mat>(n + 2, m + 2);    // Pressure [N/m^2]

  // Velocity fields:
  // u-velocity (x-direction) defined on an n x (m+1) grid.
  mat u = zeros<mat>(n, m + 1);
  // v-velocity (y-direction) defined on an (n+1) x m grid.
  mat v = zeros<mat>(n + 1, m);

  // ----------------------- Physical Parameters -----------------------
  constexpr double alpha = 1.664e-4;  // Thermal expansion coefficient (1/°C)
  constexpr double T0 = 10.0;         // Reference temperature (°C)
  constexpr double rho0 = 1027.0;     // Reference density (kg/m^3)
  constexpr double interface_width = 0.1;  // Width of the initial interface (m)
  constexpr double g = 9.806;              // Gravitational acceleration (m/s^2)
  constexpr double reduced_gravity = 0.01;  // Reduced gravity (m/s^2)
  const double delta_rho = reduced_gravity * rho0 / g;  // Density difference

  // ----------------------- Time Parameters -----------------------
  constexpr double simulationTime = 200.0;  // Total simulation time [s]
  constexpr double dt = 1.0;                // Time step [s]
  constexpr int iterations = static_cast<int>(simulationTime / dt);

  // ----------------------- Initialize Density and Temperature
  // ----------------------- Set up an initial error function profile along the
  // x-axis to mimic the lock exchange.
  for (int j = 0; j < m + 2; j++) {
    double x = a + j * dx;
    for (int i = 0; i < n + 2; i++) {
      double erf_arg = (x - (a + b) / 2.0) / interface_width;
      rho(i, j) = rho0 + delta_rho / 2.0 * (1.0 - std::erf(erf_arg));
      T(i, j) = (1.0 - rho(i, j) / rho0) / alpha + T0;
    }
  }

  // ----------------------- Derived Quantities -----------------------
  double T_middle = (T(0, 0) + T(n + 1, m + 1)) / 2.0;
  double rho_middle = rho0 * (1 - alpha * (T_middle - T0));
  double mu = 0.00141;          // Dynamic viscosity [kg/(m·s)]
  double nu = mu / rho_middle;  // Kinematic viscosity [m^2/s]

  // ----------------------- Mimetic Operators Setup -----------------------
  constexpr int k = 2;  // Order of accuracy

  // Construct 2D mimetic operators
  Divergence D(k, m, n, dx, dy);  // 2D divergence operator
  Gradient G(k, m, n, dx, dy);    // 2D gradient operator

  // Build the Laplacian operator
  Laplacian L(k, m, n, dx, dy);
  // Impose Dirichlet boundary conditions using a RobinBC
  RobinBC BC(k, m, dx, n, dy, 0, 1);  // Neumann BC
  L = L + BC;

  // Pre-multiply the gradient operator for pressure correction.
  G *= (-dt / rho_middle);

  std::cout << "Starting simulation with " << iterations << " time steps..."
            << std::endl;

  // ----------------------- Time-Stepping Loop -----------------------
  for (int t = 0; t < iterations; t++) {
    // -- Predictor Step for u --
    mat u_star = u;  // Temporary storage for predicted u

    // Apply No-slip Boundary Conditions to the predicted velocities
    u_star.row(0).zeros();
    u_star.row(u_star.n_rows - 1).zeros();
    u_star.col(0).zeros();
    u_star.col(u_star.n_cols - 1).zeros();

    for (int i = 1; i < n - 1; i++) {
      for (int j = 1; j < m; j++) {
        double d2u_dy2 = (u(i - 1, j) - 2 * u(i, j) + u(i + 1, j)) / (dy * dy);
        double d2u_dx2 = (u(i, j - 1) - 2 * u(i, j) + u(i, j + 1)) / (dx * dx);
        double udu_dx = (u(i, j) > 0) ? u(i, j) * (u(i, j) - u(i, j - 1)) / dx
                                      : u(i, j) * (u(i, j + 1) - u(i, j)) / dx;
        double vij =
            0.25 * (v(i, j) + v(i + 1, j - 1) + v(i + 1, j) + v(i, j - 1));
        double vdu_dy = (vij > 0) ? vij * (u(i, j) - u(i - 1, j)) / dy
                                  : vij * (u(i + 1, j) - u(i, j)) / dy;
        u_star(i, j) =
            u(i, j) + dt * (nu * (d2u_dy2 + d2u_dx2) - (udu_dx + vdu_dy));
      }
    }

    // -- Predictor Step for v --
    mat v_star = v;  // Temporary storage for predicted v

    // Apply No-slip Boundary Conditions to the predicted velocities
    v_star.row(0).zeros();
    v_star.row(v_star.n_rows - 1).zeros();
    v_star.col(0).zeros();
    v_star.col(v_star.n_cols - 1).zeros();

    for (int i = 1; i < n; i++) {
      for (int j = 1; j < m - 1; j++) {  // v has m columns
        double d2v_dy2 = (v(i - 1, j) - 2 * v(i, j) + v(i + 1, j)) / (dy * dy);
        double d2v_dx2 = (v(i, j - 1) - 2 * v(i, j) + v(i, j + 1)) / (dx * dx);
        double vdv_dy = (v(i, j) > 0) ? v(i, j) * (v(i, j) - v(i - 1, j)) / dy
                                      : v(i, j) * (v(i + 1, j) - v(i, j)) / dy;
        double uij =
            0.25 * (u(i, j) + u(i - 1, j + 1) + u(i, j + 1) + u(i - 1, j));
        double udv_dx = (uij > 0) ? uij * (v(i, j) - v(i, j - 1)) / dx
                                  : uij * (v(i, j + 1) - v(i, j)) / dx;
        v_star(i, j) =
            v(i, j) + dt * (nu * (d2v_dy2 + d2v_dx2) - (vdv_dy + udv_dx) +
                            g * alpha * (T(i, j) - T_middle));
      }
    }

    // -- Pressure Solve --
    // Flatten the predicted velocities into vectors.
    // Use transpose to match MATLAB's column-major order during vectorization
    vec u_vec = vectorise(u_star.t());
    vec v_vec = vectorise(v_star.t());
    vec R = (rho_middle / dt) * join_cols(u_vec, v_vec);

    // Calculate the right-hand side for the pressure Poisson equation
    vec b = D * R;  // This is the divergence of the predicted velocity field

    // Solve the pressure Poisson equation
    vec p_vec;
#ifdef SuperLU
    p_vec = spsolve(L, b);
#elif EIGEN
    p_vec = Utils::spsolve_eigen(L, b);
#else
    std::cerr << "Error: No solver available." << std::endl;
    return -1;
#endif

    // Reshape the solution vector back into a matrix
    p = reshape(p_vec, m + 2, n + 2).t();

    // -- Corrector Step --
    // Update velocities by adding the pressure gradient, similar to MATLAB's u
    // = u_s+G(1:u_length, :)*p;
    int tot_u = u_vec.n_elem;
    vec p_grad = G * p_vec;
    vec p_grad_u = p_grad.rows(0, tot_u - 1);
    vec p_grad_v = p_grad.rows(tot_u, p_grad.n_rows - 1);

    // Make sure to reshape in the same order that was used when flattening
    u = reshape(u_vec + p_grad_u, m + 1, n).t();
    v = reshape(v_vec + p_grad_v, m, n + 1).t();

    // -- Advection of Temperature --
    // Implement a simple upwind differencing scheme for temperature advection
    mat T_new = T;

    for (int i = 1; i < n + 1; i++) {
      for (int j = 1; j < m + 1; j++) {
        // Interpolate velocities to cell centers
        double u_ij = 0.5 * (u(i - 1, j) + u(i - 1, j - 1));
        double v_ij = 0.5 * (v(i, j - 1) + v(i - 1, j - 1));

        // Calculate upwind temperature gradients
        double dT_dx, dT_dy;

        // X-direction upwind
        if (u_ij > 0) {
          // Flow from left to right, use backward difference
          dT_dx = (T(i, j) - T(i, j - 1)) / dx;
        } else {
          // Flow from right to left, use forward difference
          dT_dx = (T(i, j + 1) - T(i, j)) / dx;
        }

        // Y-direction upwind
        if (v_ij > 0) {
          // Flow from bottom to top, use backward difference
          dT_dy = (T(i, j) - T(i - 1, j)) / dy;
        } else {
          // Flow from top to bottom, use forward difference
          dT_dy = (T(i + 1, j) - T(i, j)) / dy;
        }

        // Update temperature using advection equation: dT/dt + u*dT/dx +
        // v*dT/dy = 0
        T_new(i, j) = T(i, j) - dt * (u_ij * dT_dx + v_ij * dT_dy);
      }
    }

    // Apply boundary conditions (zero-gradient)
    T_new.row(0) = T_new.row(1);
    T_new.row(n + 1) = T_new.row(n);
    T_new.col(0) = T_new.col(1);
    T_new.col(m + 1) = T_new.col(m);

    // Update the temperature field
    T = T_new;

    // Print progress every 10 iterations
    if (t % 10 == 0) {
      std::cout << "t = " << (t + 1) * dt << " s" << std::endl;
    }
  }

  // ----------------------- Post-Processing -----------------------
  // Recompute the density from the temperature field using the equation of
  // state
  rho = rho_middle * (1 - alpha * (T - T_middle));

  std::cout << "Simulation complete. Saving results..." << std::endl;

  // Compute statistical measures for validation
  std::cout << "\n======= SIMULATION RESULTS SUMMARY =======\n";

  // 1. Compute min, max, mean values for key fields
  double rho_min = rho.min();
  double rho_max = rho.max();
  double rho_mean = mean(mean(rho));

  double T_min = T.min();
  double T_max = T.max();
  double T_mean = mean(mean(T));

  double p_min = p.min();
  double p_max = p.max();
  double p_mean = mean(mean(p));

  double u_min = u.min();
  double u_max = u.max();
  double u_mean = mean(mean(u));

  double v_min = v.min();
  double v_max = v.max();
  double v_mean = mean(mean(v));

  // Print statistics
  std::cout << "Density (kg/m³):     min = " << rho_min << ", max = " << rho_max
            << ", mean = " << rho_mean << std::endl;
  std::cout << "Temperature (°C):    min = " << T_min << ", max = " << T_max
            << ", mean = " << T_mean << std::endl;
  std::cout << "Pressure (N/m²):     min = " << p_min << ", max = " << p_max
            << ", mean = " << p_mean << std::endl;
  std::cout << "X-velocity (m/s):    min = " << u_min << ", max = " << u_max
            << ", mean = " << u_mean << std::endl;
  std::cout << "Y-velocity (m/s):    min = " << v_min << ", max = " << v_max
            << ", mean = " << v_mean << std::endl;

  // 2. Calculate front position (approximate)
  // Find the x-position where density is approximately halfway between min and
  // max
  double rho_threshold = (rho_min + rho_max) / 2.0;
  double left_front_pos = 0.0;
  double right_front_pos = 0.0;
  bool found_left = false;
  bool found_right = false;

  // Check density at mid-height (row n/2)
  int mid_row = n / 2;
  for (int j = 1; j < m + 1; j++) {
    // Find left front (first position from left where density crosses
    // threshold)
    if (!found_left && j > 1 && rho(mid_row, j) < rho_threshold &&
        rho(mid_row, j - 1) >= rho_threshold) {
      // Linear interpolation to find more precise position
      double t = (rho_threshold - rho(mid_row, j - 1)) /
                 (rho(mid_row, j) - rho(mid_row, j - 1));
      left_front_pos = (j - 1 + t) * dx;
      found_left = true;
    }

    // Find right front (first position from right where density crosses
    // threshold)
    int j_from_right = m + 1 - j;
    if (!found_right && j_from_right < m &&
        rho(mid_row, j_from_right) < rho_threshold &&
        rho(mid_row, j_from_right + 1) >= rho_threshold) {
      // Linear interpolation
      double t = (rho_threshold - rho(mid_row, j_from_right + 1)) /
                 (rho(mid_row, j_from_right) - rho(mid_row, j_from_right + 1));
      right_front_pos = (j_from_right + 1 - t) * dx;
      found_right = true;
    }

    if (found_left && found_right) break;
  }

  std::cout << "Approximate front positions:" << std::endl;
  std::cout << "  Left front:  " << left_front_pos << " m from left boundary"
            << std::endl;
  std::cout << "  Right front: " << right_front_pos << " m from left boundary"
            << std::endl;
  std::cout << "  Front propagation: "
            << (right_front_pos - left_front_pos) / 2.0 << " m from center"
            << std::endl;

  // 3. Calculate total kinetic energy
  double kinetic_energy = 0.0;
  for (int i = 0; i < u.n_rows; i++) {
    for (int j = 0; j < u.n_cols - 1; j++) {
      // Average u at cell centers
      double u_center = 0.5 * (u(i, j) + u(i, j + 1));
      kinetic_energy += u_center * u_center;
    }
  }

  for (int i = 0; i < v.n_rows - 1; i++) {
    for (int j = 0; j < v.n_cols; j++) {
      // Average v at cell centers
      double v_center = 0.5 * (v(i, j) + v(i + 1, j));
      kinetic_energy += v_center * v_center;
    }
  }

  // Scale by 0.5 * density * cell volume
  kinetic_energy *= 0.5 * rho_mean * dx * dy;
  std::cout << "Total kinetic energy: " << kinetic_energy << " J" << std::endl;

  std::cout
      << "=============================================================\n\n";

  // Save for Armadillo compatibility (standard CSV format)
  rho.save("density.csv", csv_ascii);
  p.save("pressure.csv", csv_ascii);
  T.save("temperature.csv", csv_ascii);
  u.save("u_velocity.csv", csv_ascii);
  v.save("v_velocity.csv", csv_ascii);

  // Save data in Gnuplot-friendly format
  saveForGnuplot(T, "temperature_gnuplot.dat", a, b, c, d, dx, dy);
  saveForGnuplot(rho, "density_gnuplot.dat", a, b, c, d, dx, dy);
  saveForGnuplot(p, "pressure_gnuplot.dat", a, b, c, d, dx, dy);

  // Save velocity field data
  saveVelocityForGnuplot(u, v, "velocity_gnuplot.dat", 3, a, b, c, d);

  // Generate Gnuplot script for visualization
  generateGnuplotScript("plot_lock_exchange.gnu", a, b, c, d);

  std::cout << "Results saved to CSV files and Gnuplot-friendly format."
            << std::endl;
  std::cout << "To visualize results, run: gnuplot plot_lock_exchange.gnu"
            << std::endl;

  return 0;
}

// GNU-related function implementations
void saveForGnuplot(const mat& matrix, const std::string& filename,
                    double x_start, double x_end, double y_start, double y_end,
                    double dx, double dy) {
  std::ofstream outFile(filename);
  if (!outFile.is_open()) {
    std::cerr << "Error: Could not open file " << filename << " for writing"
              << std::endl;
    return;
  }

  // Output Gnuplot metadata if coordinates are provided
  if (x_end > x_start && y_end > y_start) {
    outFile << "# Gnuplot data file" << std::endl;
    outFile << "# X-range: " << x_start << " to " << x_end << std::endl;
    outFile << "# Y-range: " << y_start << " to " << y_end << std::endl;
    outFile << "# Grid size: " << matrix.n_rows << " x " << matrix.n_cols
            << std::endl;
    outFile << "# dx = " << dx << ", dy = " << dy << std::endl << std::endl;
  }

  // Data in a format suitable for Gnuplot's 'matrix'
  for (size_t i = 0; i < matrix.n_rows; ++i) {
    for (size_t j = 0; j < matrix.n_cols; ++j) {
      outFile << matrix(i, j);
      if (j < matrix.n_cols - 1) outFile << " ";
    }
    outFile << std::endl;
  }

  outFile.close();
}

void saveVelocityForGnuplot(const mat& u, const mat& v,
                            const std::string& filename, int subsample,
                            double x_start, double x_end, double y_start,
                            double y_end) {
  std::ofstream outFile(filename);
  if (!outFile.is_open()) {
    std::cerr << "Error: Could not open file " << filename << " for writing"
              << std::endl;
    return;
  }

  // Calculate grid spacings
  double dx = (x_end - x_start) / (u.n_cols - 1);
  double dy = (y_end - y_start) / (u.n_rows - 1);

  // Output format: x y u v
  // This is suitable for gnuplot's vector plotting
  outFile << "# Velocity field data for Gnuplot vector plotting" << std::endl;
  outFile << "# Format: x y u v" << std::endl;
  outFile << "# x, y: position coordinates" << std::endl;
  outFile << "# u, v: velocity components" << std::endl << std::endl;

  // Account for staggered grid positions by interpolating to cell centers
  for (size_t i = 0; i < u.n_rows; i += subsample) {
    for (size_t j = 0; j < u.n_cols - 1; j += subsample) {
      // Calculate position (adjust as needed based on your grid arrangement)
      double x = x_start + j * dx;
      double y = y_start + i * dy;

      // Get velocity components (adjust indices as needed for your staggered
      // grid)
      double u_val = 0.5 * (u(i, j) + u(i, j + 1));

      // Use static_cast to ensure type consistency and avoid std::min template
      // deduction errors
      size_t i_plus_1 = i + 1;
      size_t v_rows_minus_1 = v.n_rows - 1;
      size_t v_cols_minus_1 = v.n_cols - 1;

      size_t safe_i = (i < v_rows_minus_1) ? i : v_rows_minus_1;
      size_t safe_i_plus_1 =
          (i_plus_1 < v_rows_minus_1) ? i_plus_1 : v_rows_minus_1;
      size_t safe_j = (j < v_cols_minus_1) ? j : v_cols_minus_1;

      double v_val = 0.5 * (v(safe_i, safe_j) + v(safe_i_plus_1, safe_j));

      outFile << x << " " << y << " " << u_val << " " << v_val << std::endl;
    }
  }

  outFile.close();
}

void generateGnuplotScript(const std::string& scriptFilename, double x_start,
                           double x_end, double y_start, double y_end) {
  std::ofstream scriptFile(scriptFilename);
  if (!scriptFile.is_open()) {
    std::cerr << "Error: Could not open file " << scriptFilename
              << " for writing" << std::endl;
    return;
  }

  scriptFile << "#!/usr/bin/gnuplot -persist\n\n";

  // Output settings
  scriptFile << "# Output settings\n";
  scriptFile
      << "set terminal pngcairo size 1200,800 enhanced font 'Arial,12'\n";
  scriptFile << "set output 'lock_exchange_results.png'\n\n";

  // Common settings
  scriptFile << "# Common settings\n";
  scriptFile << "set palette defined (0 'blue', 0.5 'white', 1 'red')\n";
  scriptFile << "set view map\n";
  scriptFile << "set size ratio -1\n";
  scriptFile << "set xlabel 'x (m)'\n";
  scriptFile << "set ylabel 'y (m)'\n\n";

  // Set the correct data ranges
  scriptFile << "# Set the correct data ranges\n";
  scriptFile << "set xrange [" << x_start << ":" << x_end << "]\n";
  scriptFile << "set yrange [" << y_start << ":" << y_end << "]\n\n";

  // Create a 2x2 multiplot layout
  scriptFile << "# Create a 2x2 multiplot layout\n";
  scriptFile << "set multiplot layout 2,2 title 'Lock Exchange Simulation "
                "Results at t = 200s'\n\n";

  // Plot temperature field (top-left)
  scriptFile << "# Plot temperature field (top-left)\n";
  scriptFile << "set title 'Temperature (°C)'\n";
  scriptFile << "plot 'temperature_gnuplot.dat' matrix with image notitle\n\n";

  // Plot density field (top-right)
  scriptFile << "# Plot density field (top-right)\n";
  scriptFile << "set title 'Density (kg/m^3)'\n";
  scriptFile << "plot 'density_gnuplot.dat' matrix with image notitle\n\n";

  // Plot pressure field (bottom-left)
  scriptFile << "# Plot pressure field (bottom-left)\n";
  scriptFile << "set title 'Pressure (N/m^2)'\n";
  scriptFile << "plot 'pressure_gnuplot.dat' matrix with image notitle\n\n";

  // Plot velocity field (bottom-right)
  scriptFile << "# Plot velocity vector field (bottom-right)\n";
  scriptFile << "set title 'Velocity Field (m/s)'\n";
  scriptFile << "plot 'velocity_gnuplot.dat' using 1:2:3:4 with vectors head "
                "filled lc 'black' notitle\n\n";

  scriptFile << "unset multiplot\n\n";

  // Create individual plots for each field

  // Temperature
  scriptFile << "# Individual temperature plot\n";
  scriptFile << "set output 'temperature_field.png'\n";
  scriptFile << "set title 'Temperature (°C) at t = 200s'\n";
  scriptFile << "plot 'temperature_gnuplot.dat' matrix with image notitle\n\n";

  // Density
  scriptFile << "# Individual density plot\n";
  scriptFile << "set output 'density_field.png'\n";
  scriptFile << "set title 'Density (kg/m^3) at t = 200s'\n";
  scriptFile << "plot 'density_gnuplot.dat' matrix with image notitle\n\n";

  // Pressure
  scriptFile << "# Individual pressure plot\n";
  scriptFile << "set output 'pressure_field.png'\n";
  scriptFile << "set title 'Pressure (N/m^2) at t = 200s'\n";
  scriptFile << "plot 'pressure_gnuplot.dat' matrix with image notitle\n\n";

  // Velocity
  scriptFile << "# Individual velocity vector plot\n";
  scriptFile << "set output 'velocity_field.png'\n";
  scriptFile << "set title 'Velocity Field (m/s) at t = 200s'\n";
  scriptFile << "plot 'velocity_gnuplot.dat' using 1:2:3:4 with vectors head "
                "filled lc 'black' notitle\n";

  scriptFile.close();

  std::cout << "Gnuplot script generated: " << scriptFilename << std::endl;
  std::cout << "To visualize results, run: gnuplot " << scriptFilename
            << std::endl;
}
