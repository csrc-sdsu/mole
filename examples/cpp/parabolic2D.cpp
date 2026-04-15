 /**
 * Solving the 2D Parabolic Diffusion Equation with Dirichlet Boundary Conditions
 *
 * Equation: u_t = alpha * (u_xx + u_yy)
 * Domain:   0 < x,y < 2 on an (nx+2) x (ny+2) grid
 * Initial Condition:
 *   u(x,y,0) = 2 on [1,1.5] x [1,1.5], and 0 elsewhere
 * Boundary Conditions:
 *   u = 0 on all boundaries
 *
 * Time integration is done using either:
 *   - Explicit Euler
 *   - Implicit Euler
 *
 * The final solution is written as (x,y,u) triples to "solution_xyz.dat"
 * and plotted with GNUplot as a shaded 3D surface.
 */

#include <armadillo>
#include "mole.h"
#include <iostream>
#include <string>
#include <cmath>
#include <fstream>
#include <cstdlib>

using namespace arma;

int main() {
    std::string method = "implicit";

    constexpr uint16_t k = 2;
    constexpr uint32_t nx = 40;
    constexpr uint32_t ny = 50;
    constexpr double alpha = 0.1;

    constexpr double xL = 0.0, xR = 2.0;
    constexpr double yL = 0.0, yR = 2.0;

    const double dx = (xR - xL) / nx;
    const double dy = (yR - yL) / ny;

    const double tf = 3.0;
    const double dt = (method == "explicit") ? 0.001 : 0.01;

    // --------------------------------------------------
    // Storage grid
    // --------------------------------------------------
    vec xgrid(nx + 2, fill::zeros);
    vec ygrid(ny + 2, fill::zeros);

    xgrid(0) = xL;
    for (uint32_t i = 1; i <= nx; ++i) {
        xgrid(i) = dx / 2.0 + (i - 1) * dx;
    }
    xgrid(nx + 1) = xR;

    ygrid(0) = yL;
    for (uint32_t j = 1; j <= ny; ++j) {
        ygrid(j) = dy / 2.0 + (j - 1) * dy;
    }
    ygrid(ny + 1) = yR;

    // --------------------------------------------------
    // Initial condition
    // --------------------------------------------------
    mat U = zeros(nx + 2, ny + 2);

    for (uint32_t i = 0; i < U.n_rows; ++i) {
        for (uint32_t j = 0; j < U.n_cols; ++j) {
            if (xgrid(i) >= 1.0 && xgrid(i) <= 1.5 &&
                ygrid(j) >= 1.0 && ygrid(j) <= 1.5) {
                U(i, j) = 2.0;
            }
        }
    }

    vec u = vectorise(U);

    // --------------------------------------------------
    // Construct mimetic Laplacian
    // --------------------------------------------------
    Laplacian L(k, nx, ny, dx, dy);

    // --------------------------------------------------
    // Boundary conditions
    // Dirichlet on all boundaries: u = 0
    // Use full edge lengths including corners
    // --------------------------------------------------
    AddScalarBC::BC2D bc;
    bc.dc = ones<vec>(4);
    bc.nc = zeros<vec>(4);

    bc.v[0] = zeros<vec>(ny + 2);  // left
    bc.v[1] = zeros<vec>(ny + 2);  // right
    bc.v[2] = zeros<vec>(nx + 2);  // bottom
    bc.v[3] = zeros<vec>(nx + 2);  // top

    // Apply BCs to the spatial operator first
    AddScalarBC::addScalarBC(L, u, k, nx, dx, ny, dy, bc);

    // --------------------------------------------------
    // Build time-stepping operator
    // --------------------------------------------------
    sp_mat A;
    if (method == "explicit") {
        A = speye<sp_mat>(size(L)) + alpha * dt * L;
    } else {
        A = speye<sp_mat>(size(L)) - alpha * dt * L;
    }

    // --------------------------------------------------
    // Time integration
    // --------------------------------------------------
    const uint32_t nsteps = static_cast<uint32_t>(std::round(tf / dt));

    for (uint32_t it = 0; it <= nsteps; ++it) {
        const double t = it * dt;
        std::cout << "time = " << t << std::endl;

        if (method == "explicit") {
            u = A * u;
        } else {
            vec unew;
            bool ok = spsolve(unew, A, u, "superlu");
            if (!ok) {
                std::cerr << "Sparse solve failed at step " << it << std::endl;
                return 1;
            }
            u = unew;
        }

        U = reshape(u, nx + 2, ny + 2);
    }

    // --------------------------------------------------
    // Save final solution as (x, y, u) triples
    // --------------------------------------------------
    U = reshape(u, nx + 2, ny + 2);

    std::ofstream data_file("solution_xyz.dat");
    if (!data_file) {
        std::cerr << "Error: Failed to create solution data file.\n";
        return 1;
    }

    for (uint32_t i = 0; i < U.n_rows; ++i) {
        for (uint32_t j = 0; j < U.n_cols; ++j) {
            data_file << xgrid(i) << " " << ygrid(j) << " " << U(i, j) << "\n";
        }
        data_file << "\n";
    }
    data_file.close();

    // --------------------------------------------------
    // Create GNUplot script for shaded 3D surface
    // --------------------------------------------------
    std::ofstream plot_script("plot.gnu");
    if (!plot_script) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }

    plot_script << "set title \"2D Diffusion Final Solution\"\n";
    plot_script << "set xlabel 'x'\n";
    plot_script << "set ylabel 'y'\n";
    plot_script << "set zlabel 'u'\n";
    plot_script << "set hidden3d\n";
    plot_script << "set pm3d\n";
    plot_script << "set palette rgb 33,13,10\n";
    plot_script << "set view 60,45\n";
    plot_script << "splot 'solution_xyz.dat' with pm3d notitle\n";

    plot_script.close();

    // --------------------------------------------------
    // Execute GNUplot
    // --------------------------------------------------
    if (system("gnuplot -persist plot.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }

    return 0;
}


