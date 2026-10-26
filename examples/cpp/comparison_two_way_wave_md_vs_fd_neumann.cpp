/**
 * @file comparison_two_way_wave_md_vs_fd_neumann.cpp
 * @brief Solves the wave equation with neumann boundary conditions
 *
 * Equation: d^2u/dt^2 = c^2 * d^2u/dx^2
 * Domain: - Spatial domain: [-2, 2]
 *         - N spatial points / dx spacing (user-defined)
 *         - Time integration: centered-in-time, centered-in-space (CTCS)
 * Boundary Conditions: du/dx(-2,t) = 0, du/dx(2,t) = 0
 * Initial profile: smooth Gaussian f(x) = exp(-x^2 / 0.1), evenly reflected
 *                  across the domain boundaries for the Neumann solution.
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
 *   on line 315 (k=2), which shows how easy it is
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
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>

Real f(Real x) {
    return std::exp(-x * x / 0.1);
}

Real reflected_x(Real x, Real west, Real east) {
    const Real interval = east - west;
    Real position = std::fmod(x - west, 2.0 * interval);
    if (position < 0.0) {
        position += 2.0 * interval;
    }
    return west + interval - std::abs(position - interval);
}

Real u_sol(Real x, Real t, Real c, Real west, Real east) {
    return 0.5 * (f(reflected_x(x - c * t, west, east))
                + f(reflected_x(x + c * t, west, east)));
}

// Stores flops, time, and error
struct Result {
    arma::vec flops;
    arma::vec walltime;
    arma::vec error;
    arma::vec final;
};

Result mimetic_diff(arma::u16 k, Real c, Real dt, const std::vector<arma::u32> &num_cells, Real west, Real east) {
    // Generic holders for loop info
    arma::vec error_md(num_cells.size(), arma::fill::zeros);
    arma::vec walltime_md(num_cells.size(), arma::fill::zeros);
    arma::vec flops_md(num_cells.size(), arma::fill::zeros);
    arma::vec U2_md;

    // Boundary conditions
    AddScalarBC::BC1D bc;
    bc.dc = {0.0, 0.0};
    bc.nc = {1.0, 1.0};
    bc.v  = {0.0, 0.0};

    // Loop through each cell size
    for (std::size_t cell_index = 0; cell_index < num_cells.size(); ++cell_index) {
        // Setup the domain
        const arma::u32 m = num_cells[cell_index];              // Number of cells, mimetics uses 'cells'
        const arma::u32 nx = m + 2;                             //number of grid points
        const Real dx = (east - west) / static_cast<Real>(m);   // spatial discretization
        const arma::u32 t = static_cast<arma::u32>(std::ceil(1.0 / (c * dt)));
        const Real r2_md = std::pow(c * dt, 2.0);

        // MD grid, note the extra staggered (dx/2) step near the boundaries
        arma::vec grid_md(nx, arma::fill::zeros);
        grid_md(0) = west;
        grid_md(1) = west + dx / 2.0;
        for (arma::u32 i = 2; i <= m; ++i) {
            grid_md(i) = grid_md(i - 1) + dx;
        }
        grid_md(m + 1) = east;

        // Initial displacement is a Gaussian with a reflected extension for Neumann boundaries.
        arma::vec U0_md(nx, arma::fill::zeros);
        for (arma::u32 i = 0; i < m+2; ++i) {
            U0_md(i) = u_sol(grid_md(i), 0, c, west, east);
        }

        // The analytic solution, so we can check the error
        arma::vec analytical_md(nx, arma::fill::zeros);
        for (arma::u32 i = 0; i < m+2; ++i) {
            analytical_md(i) = u_sol(grid_md(i), (t + 1) * dt, c, west, east);
        }

        // Laplacian
        Laplacian L(k, m, dx);
        arma::sp_mat L_interior = arma::sp_mat(L);

        // Modify for BCs
        arma::sp_mat Lbc = L_interior;
        arma::vec b_bc(nx, arma::fill::zeros);
        AddScalarBC::addScalarBC(Lbc, b_bc, k, m, dx, bc);

        /* Solve for the boundary values.
         * addScalarBC() modifies the matrix and adds a vector of boundary values, b_bc.
         * It is meant for implicit schemes, but we can use it here to solve for just the
         * boundary values, and use an explicit scheme for the interior points. Here is
         * defined solve_boundary() which solves a single boundary, and solve_boundaries(),
         * which solves both.
         */
        auto solve_boundary = [&](arma::vec &u, arma::uword boundary) {
            Real rhs = b_bc(boundary);
            for (arma::sp_mat::const_row_iterator it = Lbc.begin_row(boundary);
                 it != Lbc.end_row(boundary); ++it) {
                if (it.col() != boundary) {
                    rhs -= (*it) * u(it.col());
                }
            }
            u(boundary) = rhs / Lbc(boundary, boundary);
        };
        auto solve_boundaries = [&](arma::vec &u) {
            solve_boundary(u, 0);
            solve_boundary(u, nx - 1);
        };

        // Premultiply L_interior by r2_md, so we can use it in the time loop
        L_interior *= r2_md;

        arma::vec U1_md = U0_md + 0.5 * (L_interior * U0_md);
        solve_boundaries(U1_md);

        U2_md = U1_md;

        const arma::uword nnz_md = L_interior.n_nonzero;
        auto start = std::chrono::steady_clock::now();

        for (arma::u32 nstep = 1; nstep <= t; ++nstep) {
            U2_md = 2.0 * U1_md + (L_interior * U1_md) - U0_md;
            solve_boundaries(U2_md);

            U0_md = U1_md;
            U1_md = U2_md;
        }

        auto end = std::chrono::steady_clock::now();
        std::chrono::duration<double> duration = end - start;

        // Store data for comparison
        flops_md(cell_index) = static_cast<Real>((2 * nnz_md + 3 * U0_md.n_elem) * t);
        walltime_md(cell_index) = duration.count();
        arma::vec diff = U2_md-analytical_md;
        error_md(cell_index) = arma::norm(diff) / arma::norm(analytical_md);
    }

    return {flops_md, walltime_md, error_md, U2_md};
}

Result finite_diff(Real c, Real dt, const std::vector<arma::u32> &num_cells, Real west, Real east) {
    // generic holders for metrics within the loops
    arma::vec error_fd(num_cells.size(), arma::fill::zeros);
    arma::vec walltime_fd(num_cells.size(), arma::fill::zeros);
    arma::vec flops_fd(num_cells.size(), arma::fill::zeros);

    arma::vec U2_fd; // To store solution

    // Loop through each cell size
    for (std::size_t cell_index = 0; cell_index < num_cells.size(); ++cell_index) {
        // Setup the domain
        const arma::u32 m = num_cells[cell_index];                  //Number of cells
        const arma::u32 nx = m + 1;                                 //number of grid points
        const Real dx = (east - west) / static_cast<Real>(m);       // spatial discretization
        const Real r2_fd = c * c * (dt * dt / (dx * dx));           // Courant-like factor
        const arma::u32 t = static_cast<arma::u32>(std::ceil(1.0 / (c * dt)));  // first step euler, so t is one less

        // FD grid
        arma::vec grid_fd = arma::linspace<arma::vec>(west, east, nx);

        // Initial displacement is a Gaussian with a reflected extension for Neumann boundaries.
        arma::vec U0_fd(nx, arma::fill::zeros);
        for (arma::u32 i = 0; i < nx; ++i) {
            U0_fd(i) = u_sol(grid_fd(i), 0.0, c, west, east);
        }

        U0_fd(0) = U0_fd(1);
        U0_fd(nx - 1) = U0_fd(nx - 2);

        // The analytic solution, so we can check the error
        arma::vec analytical_fd(nx, arma::fill::zeros);
        for (arma::u32 i = 0; i < nx; ++i) {
            analytical_fd(i) = u_sol(grid_fd(i), (t + 1) * dt, c, west, east);
        }

        /* Centered Scheme Matrix L
        L is (2I + cD), a tridiagonal sparse matrix:
        L =
            [2-2c  c    0    0    0
            c   2-2c   c    0    0
            0     c  2-2c   c    0
            0     0    c  2-2c   c
            0     0    0    c  2-2c]

        where c =  r2_fd = c^2 * (dt^2 / dx^2)
        */
        // For step 1
        // Make a vector of ones, this will be the -1, +1 diagonal of matrix LTCS
        arma::vec B = (r2_fd) * arma::ones<arma::vec>(nx);
        arma::vec A = (2.0 - (2.0 * r2_fd)) * arma::ones<arma::vec>(nx);

        arma::sp_mat LTCS(nx, nx);
        LTCS.diag(0) = A;
        LTCS.diag(-1) = B.subvec(1, nx - 1);
        LTCS.diag(1) = B.subvec(0, nx - 2);

        // Boundary Conditions
        LTCS(0, 0) = 1.0;
        LTCS(0, 1) = -1.0;
        LTCS(nx - 1, nx - 1) = 1.0;
        LTCS(nx - 1, nx - 2) = -1.0;

        arma::vec U1_fd = 0.5 * (LTCS * U0_fd);

        U1_fd(0) = U1_fd(1);
        U1_fd(nx - 1) = U1_fd(nx - 2);

        U2_fd = U1_fd; //Increment time step

        auto start = std::chrono::steady_clock::now();
        const arma::uword nnz_fd = LTCS.n_nonzero;

        // Loop over time values
        for (arma::u32 nstep = 1; nstep <= t; ++nstep) {
            U2_fd = (LTCS * U1_fd) - U0_fd;

            U2_fd(0) = U2_fd(1);
            U2_fd(nx - 1) = U2_fd(nx - 2);

            // Shift everyone back for leapfrog scheme
            U0_fd = U1_fd;
            U1_fd = U2_fd;
        }

        auto end = std::chrono::steady_clock::now();
        std::chrono::duration<double> duration = end - start;

        // Stores data for comparison
        walltime_fd(cell_index) = duration.count();
        flops_fd(cell_index) = static_cast<Real>((2 * nnz_fd + U0_fd.n_elem) * t);
        arma::vec diff = U2_fd - analytical_fd;
        error_fd(cell_index) = arma::norm(diff) / arma::norm(analytical_fd);
    }

    return {flops_fd, walltime_fd, error_fd, U2_fd};
}

int main() {
    // Problem definition
    const std::vector<arma::u32> num_cells = { 20, 40, 80, 160 }; // Number of cells to try, points is cells+1
    const arma::u16 k = 4;                                          // Mimetic Order of Accuracy, can change to 4,6,8
    const Real c = .1;                                              // Velocity, 1 makes FD scheme exact
    const Real dt = .001;                                           // Time Step
    const Real west = -2.0;                                         // Domain's leftmost limits
    const Real east =  2.0;                                         // Domain's rightmost limits

    // Store results
    Result md_result = mimetic_diff(k, c, dt, num_cells, west, east);
    Result fd_result = finite_diff(c, dt, num_cells, west, east);

    std::cout << "Mimetic Results \n" << md_result.final << "\n";
    std::cout << "Finite Results \n" << fd_result.final << "\n";

    // Plot for FLOPs
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
    for (arma::uword i = 0; i < fd_result.flops.n_elem; ++i) {
        plot_script_flops << num_cells[i] << " " << fd_result.flops(i) << "\n";
    }
    plot_script_flops << "e\n";

    // plot md flops
    for (arma::uword i = 0; i < md_result.flops.n_elem; ++i) {
        plot_script_flops << num_cells[i] << " " << md_result.flops(i) << "\n";
    }
    plot_script_flops << "e\n";
    plot_script_flops.close();

    // Plot for error
    // Plot the comparison of the errors of each scheme - on a log-log plot,
    // so we can capture the slope of the lines == the order of accuracy of the
    // spacial scheme.

    const arma::uword n = num_cells.size();

    arma::vec nc(n);
    for (arma::uword i = 0; i < n; ++i) {
        nc(i) = static_cast<Real>(num_cells[i]);
    }

    arma::vec x_fit = arma::log(1.0 / nc);
    arma::vec y_fd  = arma::log(fd_result.error);
    arma::vec y_md  = arma::log(md_result.error);

    arma::mat X(n, 2, arma::fill::ones);
    X.col(0) = x_fit;

    arma::vec p_fd = arma::solve(X, y_fd);
    arma::vec p_md = arma::solve(X, y_md);

    const Real slope_fd = p_fd(0);
    const Real slope_md = p_md(0);


    std::cout << "Finite Difference Error Convergence Slope:   " << slope_fd << std::endl;
    std::cout << "Mimetic Difference Error Convergence Slope:  " << slope_md << std::endl;

    std::ofstream plot_script_error("plot_error_dx.gnu");
    if (!plot_script_error) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }

    const Real xmin = 1.0 / static_cast<Real>(num_cells.back());
    const Real xmax = 1.0 / static_cast<Real>(num_cells.front());

    plot_script_error << "set title 'Error: FD slope="
                      << slope_fd
                      << ", MD slope="
                      << slope_md
                      << "'\n";
    plot_script_error << "set xlabel 'dx'\n";
    plot_script_error << "set ylabel 'Error'\n";
    plot_script_error << "set logscale xy\n";
    plot_script_error << "set xrange [" << xmin << ":" << xmax << "]\n";
    plot_script_error << "set grid\n";
    plot_script_error << "plot '-' using 1:2 with linespoints lw 2 title 'FD', "
                      << "'-' using 1:2 with linespoints lw 2 title 'Mimetic'\n";

    // Plot fd error
    for (std::size_t i = 0; i < num_cells.size(); ++i) {
        const Real dx_plot = 1.0 / static_cast<Real>(num_cells[i]);
        plot_script_error << dx_plot << " " << fd_result.error(i) << "\n";
    }
    plot_script_error << "e\n";

    // Plot md error
    for (std::size_t i = 0; i < num_cells.size(); ++i) {
        const Real dx_plot = 1.0 / static_cast<Real>(num_cells[i]);
        plot_script_error << dx_plot << " " << md_result.error(i) << "\n";
    }
    plot_script_error << "e\n";
    plot_script_error.close();

    // Plot for walltime
    std::ofstream plot_script_time("plot_time.gnu");
    if (!plot_script_time) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }

    plot_script_time << "set title 'Walltime, MD is order " << k << "'\n";
    plot_script_time << "set xlabel 'num cells'\n";
    plot_script_time << "set ylabel 'walltime [s]'\n";
    plot_script_time << "set grid\n";
    plot_script_time << "set style line 1 lw 2\n";
    plot_script_time << "set style line 2 lw 2\n";

    const Real xmin_time = static_cast<Real>(num_cells.front());
    const Real xmax_time = static_cast<Real>(num_cells.back());
    const Real ymin = std::min(fd_result.walltime.min(), md_result.walltime.min());
    const Real ymax = std::max(fd_result.walltime.max(), md_result.walltime.max());

    plot_script_time << "set xrange [" << xmin_time << ":" << xmax_time << "]\n";
    plot_script_time << "set yrange [" << ymin << ":" << ymax << "]\n";
    plot_script_time << "set key left top\n";
    plot_script_time << "plot '-' using 1:2 with lines ls 1 title 'FD time', "
    << "'-' using 1:2 with lines ls 2 title 'MD time'\n";


    // fd time
    for (std::size_t i = 0; i < num_cells.size(); ++i) {
        plot_script_time << num_cells[i] << " " << fd_result.walltime(i) << "\n";
    }
    plot_script_time << "e\n";

    // md time
    for (std::size_t i = 0; i < num_cells.size(); ++i) {
        plot_script_time << num_cells[i] << " " << md_result.walltime(i) << "\n";
    }
    plot_script_time << "e\n";

    plot_script_time.close();

    // Show all plots
    if (std::system("gnuplot -persist plot_error_dx.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }
    if (std::system("gnuplot -persist plot_flops.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }
    if (std::system("gnuplot -persist plot_time.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }

    return 0;
}
