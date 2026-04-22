/**
 * @file mimetic_diff_two_way_wave_eq_neumann.cpp
 * @brief Solves the wave equation with neumann boundary conditions
 *
 * Equation: d^2u/dt^2 = c^2 * d^2u/dx^2
 * Domain: - Spatial domain: [-2, 2]
 *         - N spatial points / dx spacing (user-defined)
 *         - Time integration: centered-in-time, centered-in-space (CTCS)
 * Boundary Conditions: du/dx(0,t) = 0, du/dx(M,t) = 0
 * Initial Condition: u(0,t) = cos(pi x)^2, |x|<.5
 *                           = 0,           otherwise
 *
 *
 * Methods:
 *     1. mimetic_diff()
 *      - Uses mimetic finite differences for the spatial Laplacian.
 *      - Preserves discrete conservation properties.
 *
 *    2. finite_diff()
 *       - Uses standard finite differences (tridiagonal Laplacian).
 *
 * Purpose:
 *    - Compare numerical accuracy, computational cost, and runtime of MD vs FD.
 *    - Demonstrate differences in error, stability, and sparsity handling.
 *
 * NOTES:
 *    - Both solvers use a two-step leapfrog (centered-time) scheme.
 *    - CFL condition must be satisfied: c*dt/dx <= 1
 *    - Visualization and comparison are performed at the final time step.
 *
 *
 * EXPLANATION:
 *    The main difference between the methods is how the grid is discretized.
 *    Finite differences use a standard grid, where the domain from A to B is
 *    broken into N equal sized cells, with n+1 grid points demarking the
 *    boundaries.
 *
 *  A                                                                 B
 *  <-----dx-----> <-----dx----->       <-----dx-----> <-----dx----->    -- space
 * |----cell 1----|----cell 2----| ... |----cell N-1--|----cell N----|   -- cells
 * 0              1              2 ...N-1             N             N+1  -- index
 *
 * Where the mimetic difference uses a staggered grid, with a half step at each
 * boundary.
 * A                                                         B
 *  <--dx/2--> <-----dx----->       <-----dx-----> <--dx/2-->    -- space
 * |--cell 1--|----cell 2----| ... |----cell N-1--|--cell N--|   -- cells
 * 0          1              2 ... N             N+1        N+2  -- index
 *
 * In numbers, from 0 to 1, with 5 cells, an FD grid and MD grid would be
 * FD:
 *    0.0        0.2        0.4        0.6        0.8        1.0
 *     o----------o----------o----------o----------o----------o
 *     x0         x1         x2         x3         x4         x5
 *
 * MD:
 *    0.0   0.1       0.3        0.5        0.7        0.9   1.0
 *     o-----o---------o----------o----------o----------o-----o
 *     x0   x1         x2         x3         x4         x5    x6
 *
 *
 *   The CTCS has a second order accurate time scheme, so it will never get >2
 *   convergence. The user can change the order of the mimetic scheme very easily
 *   in the mimetic_diff_two_way_wave_eq.m file (k=2), which shows how easy it is
 *   to switch orders of the experiment, for very little cost.
 *
 * ----------------------------------------------------------------------------
 * SPDX-License-Identifier: GPL-3.0-or-later
 * © 2008-2024 San Diego State University Research Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 * ----------------------------------------------------------------------------
 *
 */


#include "mole.h"
#include <iostream>
#include <cmath>
#include <chrono>

using namespace arma;
using namespace std;
using namespace AddScalarBC;

// Initial Condition Function
static inline Real u_ic(const Real x) {
    return ((x > -0.5) && (x < 0.5)) ? std::pow(std::cos(datum::pi * x), 2.0) : 0.0;
}

// Wave solution using d'Almbert
static inline Real u_sol(const Real x, const Real t, const Real c) {
    return 0.5 * (u_ic(x - c * t) + u_ic(x + c * t));
}

// Stores flops, time, and error
struct Result {
    vec flops;
    vec walltime;
    vec error;
};

Result mimetic_diff(u16 k, Real c, Real dt, vector<u32> num_cells, double west, double east) {
    // Generic holders for loop info
    vec error_md(num_cells.size(), fill::zeros);
    vec walltime_md(num_cells.size(), fill::zeros);
    vec flops_md(num_cells.size(), fill::zeros);

    // Loop through each cell size
    for (u32 cell_index = 0; cell_index < num_cells.size(); ++cell_index) {
        // Setup the domain
        const u32 m = num_cells[cell_index];                    // Number of cells, mimetics uses 'cells'
        const u32 nx = m + 2;                                   //number of grid points
        const Real dx = (east - west) / static_cast<Real>(m);   // spacial discretization
        const u32 t = static_cast<u32>(std::ceil(1.0 / (c * dt)));

        // MD grid, note the extra staggered (dx/2) step near the boundaries
        vec grid_md(nx, fill::zeros);
        grid_md(0) = west;
        grid_md(1) = west + dx / 2.0;
        for (u32 i = 2; i <= m; ++i) {
            grid_md(i) = grid_md(i - 1) + dx;
        }
        grid_md(m + 1) = east;

        // Initial Displacement is cos curve
        vec U0_md(nx, fill::zeros);
        vec U1_md(nx, fill::zeros);
        for (u32 i = 0; i < m+2; ++i) {
            U0_md(i) = u_sol(grid_md(i), 0, c);
            U1_md(i) = u_sol(grid_md(i), dt, c);
        }

        // The analytic solution, so we can check the error
        vec analytical_md(nx, fill::zeros);
        for (u32 i = 0; i < m+2; ++i) {
            analytical_md(i) = u_sol(grid_md(i), (t + 1) * dt, c);
        }

        // implicit scheme
        const Real alpha = std::pow(c * dt, 2.0) / 2.0;

        // Boundary conditions
        Laplacian L(k, m, dx);
        RobinBC BC(k, m, dx, 0.0, 1.0);   // Neumann
        L += BC;

        // (I - a L)U^(n+1) = 2 U^n - (I - a L)U^(n-1)
        sp_mat A = speye<sp_mat>(nx, nx) - alpha * L;

        vec U2_md = U1_md;

        const uword nnz_fd = A.n_nonzero;
        auto start = std::chrono::steady_clock::now();

        // Loop over time values
        for (u32 nstep = 3; nstep <= t + 2; ++nstep) {
            // (I - aL) U^{n+1} = 2U^n - (I - aL) U^{n-1}
            vec b = 2.0 * U1_md - A * U0_md;

            U2_md = spsolve(A, b);

            // Shift everyone back for leapfrog scheme
            U0_md = U1_md;
            U1_md = U2_md;
        }

        auto end = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

        // Store data for comparison
        flops_md(cell_index) = static_cast<Real>((2 * nnz_fd + U0_md.n_elem) * t);
        walltime_md(cell_index) = duration.count();
        error_md(cell_index) = max(abs(U2_md-analytical_md));
    }

    return {flops_md, walltime_md, error_md};
}

Result finite_diff(Real c, Real dt, vector<u32> num_cells, double west, double east) {
    // generic holders for metrics within the loops
    vec error_fd(num_cells.size(), fill::zeros);
    vec walltime_fd(num_cells.size(), fill::zeros);
    vec flops_fd(num_cells.size(), fill::zeros);

    vec U2_fd; // To store solution

    // Loop through each cell size
    for (u32 cell_index = 0; cell_index < num_cells.size(); ++cell_index) {
        // Setup the domain
        const u32 m = num_cells[cell_index];                        //Number of cells
        const u32 nx = m + 1;                                       //number of grid points
        const Real dx = (east - west) / static_cast<Real>(m);       // spatial discretization
        const Real r2_fd = c * c * (dt * dt / (dx * dx));           // Courant-like factor
        const u32 t = static_cast<u32>(std::ceil(1.0 / (c * dt)));  // first step euler, so t is one less

        // FD grid
        vec grid_fd = linspace<vec>(west, east, nx);

        // Initial Displacement is cos curve
        vec U0_fd(nx, fill::zeros);
        for (u32 i = 0; i < nx; ++i) {
            U0_fd(i) = u_sol(grid_fd(i), 0.0, c);
        }

        U0_fd(0) = U0_fd(1);
        U0_fd(nx - 1) = U0_fd(nx - 2);

        // The analytic solution, so we can check the error
        vec analytic_fd(nx, fill::zeros);
        for (u32 i = 0; i < nx; ++i) {
            analytic_fd(i) = u_sol(grid_fd(i), (t + 1) * dt, c);
        }

        /* Centered Scheme Matrix L
        L is (I + cD), a tridiagonal sparse matrix:
        L =
            [2-2c  c    0    0    0
            c   2-2c   c    0    0
            0     α  2-2c   c    0
            0     0    c  2-2c   c
            0     0    0    c  2-2c]

        where c =  r2_fd = c^2 * (dt^2 / dx^2)
        */
        // For step 1
        // Make a vector of ones, this will be the -1, +1 diagonal of matrix LTCS
        vec B = (r2_fd) * ones<vec>(nx);
        vec A = (2.0 - (2.0 * r2_fd)) * ones<vec>(nx);

        sp_mat LTCS(nx, nx);
        LTCS.diag(0) = A;
        LTCS.diag(-1) = B.subvec(1, nx - 1);
        LTCS.diag(1) = B.subvec(0, nx - 2);

        // Boundary Conditions
        LTCS(0, 0) = 1.0;
        LTCS(0, 1) = -1.0;
        LTCS(nx - 1, nx - 1) = 1.0;
        LTCS(nx - 1, nx - 2) = -1.0;

        vec U1_fd = 0.5 * (LTCS * U0_fd);

        U1_fd(0) = U1_fd(1);
        U1_fd(nx - 1) = U1_fd(nx - 2);

        U2_fd = U1_fd; //Increment time step

        auto start = std::chrono::steady_clock::now();
        const uword nnz_fd = LTCS.n_nonzero;

        // Loop over time values
        for (u32 nstep = 1; nstep <= t; ++nstep) {
            U2_fd = (LTCS * U1_fd) - U0_fd;

            U2_fd(0) = U2_fd(1);
            U2_fd(nx - 1) = U2_fd(nx - 2);

            // Shift everyone back for leapfrog scheme
            U0_fd = U1_fd;
            U1_fd = U2_fd;
        }

        auto end = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

        // Stores data for comparison
        walltime_fd(cell_index) = static_cast<Real>(duration.count());
        flops_fd(cell_index) = static_cast<Real>((2 * nnz_fd + U0_fd.n_elem) * t);
        error_fd(cell_index) = abs(U2_fd - analytic_fd).max();
    }

    return {flops_fd, walltime_fd, error_fd};
}

int main() {
    // Problem definition
    const std::vector<u32> num_cells = {10, 20, 40, 80, 160}; // Number of cells to try, points is cells+1
    const u32 k = 4;                                          // Mimetic Order of Accuracy, can change to 4,6,8
    const double c = .1;                                      // Velocity, 1 makes FD scheme exact
    const double dt = .001;                                   // Time Step
    const double west = -2.0;                                 // Domain's leftmost limits
    const double east =  2.0;                                 // Domain's rightmost limits

    // Store results
    Result md_result = mimetic_diff(k, c, dt, num_cells, west, east);
    Result fd_result = finite_diff(c, dt, num_cells, west, east);

    /// Plot for FLOPs
    // Floating point operations needed for each method. The mimetic difference
    // methods use at least one more point, and have boundary calculations built in.
    std::ofstream plot_script_flops("plot_flops.gnu");
    if (!plot_script_flops) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }
    plot_script_flops << "set title 'FLOPs for each method, mimetic order:"
                      << k
                      <<"'\n";
    plot_script_flops << "set xlabel 'Number of cells'\n";
    plot_script_flops << "set ylabel 'FLOPs'\n";
    plot_script_flops << "set logscale y\n";
    plot_script_flops << "plot '-' using 1:2 with lines title 'FD', "
    << "'-' using 1:2 with lines title 'Mimetic'\n";

    // Plot fd flops
    for (int i = 0; i < fd_result.flops.size(); ++i) {
        plot_script_flops << num_cells[i] << " " << fd_result.flops(i) << "\n";
    }
    plot_script_flops << "e\n";

    // plot md flops
    for (int i = 0; i < md_result.flops.size(); ++i) {
        plot_script_flops << num_cells[i] << " " << md_result.flops(i) << "\n";
    }
    plot_script_flops << "e\n";
    plot_script_flops.close();

    /// Plot for error
    // Plot the comparison of the errors of each scheme - on a log-log plot,
    // so we can capture the slope of the lines == the order of accuracy of the
    // spacial scheme.

    int n = num_cells.size();

    // Calculate error slope for fd
    double fd_dx1 = (east - west) / static_cast<double>(num_cells[n-2]);
    double fd_dx2 = (east - west) / static_cast<double>(num_cells[n-1]);
    double fd_e1 = fd_result.error(n-2);
    double fd_e2 = fd_result.error(n-1);
    double slope_fd = std::log(fd_e2 / fd_e1) / std::log(fd_dx2 / fd_dx1);

    // Calculate error slope for md
    double md_dx1 = (east - west) / static_cast<double>(num_cells[n-2]);
    double md_dx2 = (east - west) / static_cast<double>(num_cells[n-1]);
    double md_e1 = md_result.error(n-2);
    double md_e2 = md_result.error(n-1);
    double slope_md = std::log(md_e2 / md_e1) / std::log(md_dx2 / md_dx1);

    cout << "Finite Difference Error Convergence Slope:   " << slope_fd << endl;
    cout << "Mimetic Difference Error Convergence Slope:  " << slope_md << endl;

    std::ofstream plot_script_error("plot_error_dx.gnu");
    if (!plot_script_error) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }

    plot_script_error << "set title 'Error: FD slope="
                      << slope_fd
                      << ", MD slope="
                      << slope_md
                      << "'\n";
    plot_script_error << "set xlabel 'dx'\n";
    plot_script_error << "set ylabel 'Error'\n";
    plot_script_error << "set logscale xy\n";
    plot_script_error << "set grid\n";
    plot_script_error << "plot '-' using 1:2 with linespoints lw 2 title 'FD', "
                      << "'-' using 1:2 with linespoints lw 2 title 'Mimetic'\n";

    // Plot fd error
    for (size_t i = 0; i < num_cells.size(); ++i) {
        double dx = (east - west) / static_cast<double>(num_cells[i]);
        plot_script_error << dx << " " << fd_result.error(i) << "\n";
    }
    plot_script_error << "e\n";

    // Plot md error
    for (size_t i = 0; i < num_cells.size(); ++i) {
        double dx = (east - west) / static_cast<double>(num_cells[i]);
        plot_script_error << dx << " " << md_result.error(i) << "\n";
    }
    plot_script_error << "e\n";
    plot_script_error.close();


    /// Plot for walltime
    std::ofstream plot_script_time("plot_time.gnu");
    if (!plot_script_time) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }

    plot_script_time << "set title 'Walltime, MD is order 4'\n";
    plot_script_time << "set xlabel 'num points'\n";
    plot_script_time << "set ylabel 'walltime [s]'\n";
    plot_script_time << "set grid\n";
    plot_script_time << "set style line 1 lw 2\n";
    plot_script_time << "set style line 2 lw 2\n";

    double xmin = num_cells.front();
    double xmax = num_cells.back();
    double ymin = std::min(fd_result.walltime.min(), md_result.walltime.min());
    double ymax = std::max(fd_result.walltime.max(), md_result.walltime.max());

    plot_script_time << "set xrange [" << xmin << ":" << xmax << "]\n";
    plot_script_time << "set yrange [" << ymin << ":" << ymax << "]\n";
    plot_script_time << "set key left top\n";
    plot_script_time << "plot '-' using 1:2 with lines ls 1 title 'FD time', "
    << "'-' using 1:2 with lines ls 2 title 'MD time'\n";


    // fd time
    for (size_t i = 0; i < num_cells.size(); ++i) {
        plot_script_time << num_cells[i] << " " << fd_result.walltime(i) << "\n";
    }
    plot_script_time << "e\n";

    // md time
    for (size_t i = 0; i < num_cells.size(); ++i) {
        plot_script_time << num_cells[i] << " " << md_result.walltime(i) << "\n";
    }
    plot_script_time << "e\n";

    plot_script_time.close();

    // Show all plots
    if (system("gnuplot -persist plot_error_dx.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }
    if (system("gnuplot -persist plot_flops.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }
    if (system("gnuplot -persist plot_time.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }

    return 0;
}