/**
 * Solving the 2D Parabolic Diffusion Equation with Dirichlet Boundary Conditions
 *
 * Equation: u_t = alpha * (u_xx + u_yy)
 * Domain:   0 < x,y < 2 on an (nx+2) x (ny+2) grid
 * Initial Condition:
 *   u(x,y,0) = 2 on a centered square region, and 0 elsewhere
 * Boundary Conditions:
 *   u = 0 on all boundaries
 *
 * Time integration is done using either:
 *   - Explicit Euler
 *   - Implicit Euler
 *
 * The solution is saved as animation frames and displayed with GNUplot
 * as a shaded 3D surface.
 */

#include <armadillo>
#include "mole.h"
#include "addscalarbc.h"
#include <iostream>
#include <string>
#include <cmath>
#include <fstream>
#include <cstdlib>
#include <sstream>
#include <iomanip>

using namespace std;
using namespace arma;
using namespace AddScalarBC;

// Write one animation frame as (x,y,u) triples.
static bool write_frame(
    const string& filename,
    const vec& xgrid,
    const vec& ygrid,
    const mat& U
) {
    ofstream data_file(filename);

    if (!data_file) {
        cerr << "Error: Failed to create " << filename << "\n";
        return false;
    }

    for (uint32_t i = 0; i < U.n_rows; ++i) {
        for (uint32_t j = 0; j < U.n_cols; ++j) {
            data_file << xgrid(i) << " "
                      << ygrid(j) << " "
                      << U(i, j) << "\n";
        }
        data_file << "\n";
    }

    return true;
}

// Build frame filename.
static string frame_name(uint32_t frame_id) {
    ostringstream name;

    name << "frames/frame_"
         << setw(4)
         << setfill('0')
         << frame_id
         << ".dat";

    return name.str();
}

int main() {
    string method = "implicit";

    constexpr uint16_t k = 2;
    constexpr uint32_t nx = 40;
    constexpr uint32_t ny = 50;
    constexpr double alpha = 0.1;

    constexpr double xL = 0.0;
    constexpr double xR = 2.0;
    constexpr double yL = 0.0;
    constexpr double yR = 2.0;

    const double dx = (xR - xL) / nx;
    const double dy = (yR - yL) / ny;

    const double tf = 3.0;
    const double dt = (method == "explicit") ? 0.001 : 0.01;

    const uint32_t frame_stride = (method == "explicit") ? 20 : 5;

    if (system("mkdir -p frames") != 0) {
        cerr << "Error: Failed to create frames directory.\n";
        return 1;
    }

    // Storage grid
    vec xgrid(nx + 2, fill::zeros);
    vec ygrid(ny + 2, fill::zeros);

    xgrid(0) = xL;

    for (uint32_t i = 1; i <= nx; ++i) {
        xgrid(i) = xL + dx / 2.0 + (i - 1) * dx;
    }

    xgrid(nx + 1) = xR;

    ygrid(0) = yL;

    for (uint32_t j = 1; j <= ny; ++j) {
        ygrid(j) = yL + dy / 2.0 + (j - 1) * dy;
    }

    ygrid(ny + 1) = yR;

    // Initial condition
    mat U = zeros(nx + 2, ny + 2);

    const double xA = 0.75;
    const double xB = 1.25;
    const double yA = 0.75;
    const double yB = 1.25;

    for (uint32_t i = 0; i < U.n_rows; ++i) {
        for (uint32_t j = 0; j < U.n_cols; ++j) {
            if (xgrid(i) >= xA && xgrid(i) <= xB &&
                ygrid(j) >= yA && ygrid(j) <= yB) {
                U(i, j) = 2.0;
            }
        }
    }

    vec u = vectorise(U);

    // Construct mimetic Laplacian
    Laplacian L(k, nx, ny, dx, dy);

    // Dirichlet boundary conditions
    BC2D bc;

    bc.dc = ones<vec>(4);
    bc.nc = zeros<vec>(4);

    bc.v[0] = zeros<vec>(ny + 2);  // left
    bc.v[1] = zeros<vec>(ny + 2);  // right
    bc.v[2] = zeros<vec>(nx + 2);  // bottom
    bc.v[3] = zeros<vec>(nx + 2);  // top

    addScalarBC(L, u, k, nx, dx, ny, dy, bc);

    // Build time-stepping operator
    sp_mat A;

    if (method == "explicit") {
        A = speye<sp_mat>(size(L)) + alpha * dt * L;
    } else {
        A = speye<sp_mat>(size(L)) - alpha * dt * L;
    }

    // Time integration with frame output
    const uint32_t nsteps = static_cast<uint32_t>(round(tf / dt));

    uint32_t frame_id = 0;

    for (uint32_t it = 0; it <= nsteps; ++it) {
        U = reshape(u, nx + 2, ny + 2);

        if (it % frame_stride == 0 || it == nsteps) {
            if (!write_frame(frame_name(frame_id), xgrid, ygrid, U)) {
                return 1;
            }

            ++frame_id;
        }

        if (it == nsteps) {
            break;
        }

        if (method == "explicit") {
            u = A * u;
        } else {
            vec unew;

            bool ok = spsolve(unew, A, u, "superlu");

            if (!ok) {
                cerr << "Sparse solve failed at step " << it << "\n";
                return 1;
            }

            u = unew;
        }
    }

    // Save final solution
    U = reshape(u, nx + 2, ny + 2);

    ofstream final_file("solution_xyz.dat");

    if (!final_file) {
        cerr << "Error: Failed to create solution_xyz.dat\n";
        return 1;
    }

    for (uint32_t i = 0; i < U.n_rows; ++i) {
        for (uint32_t j = 0; j < U.n_cols; ++j) {
            final_file << xgrid(i) << " "
                       << ygrid(j) << " "
                       << U(i, j) << "\n";
        }

        final_file << "\n";
    }

    final_file.close();

    // Create GNUplot 3D animation script
    ofstream plot_script("plot_animation.gnu");

    if (!plot_script) {
        cerr << "Error: Failed to create plot_animation.gnu\n";
        return 1;
    }

    plot_script << "set term qt size 800,700 persist\n";
    plot_script << "set xlabel 'x'\n";
    plot_script << "set ylabel 'y'\n";
    plot_script << "set zlabel 'u'\n";

    plot_script << "set xrange [" << xL << ":" << xR << "]\n";
    plot_script << "set yrange [" << yL << ":" << yR << "]\n";
    plot_script << "set zrange [0:2.1]\n";
    plot_script << "set cbrange [0:2.1]\n";

    plot_script << "set hidden3d\n";
    plot_script << "set pm3d\n";
    plot_script << "set palette rgb 33,13,10\n";

    plot_script << "set view 60,45\n";
    plot_script << "set ticslevel 0\n";
    plot_script << "set xyplane 0\n";
    plot_script << "set size square\n";

    plot_script << "unset key\n";
    plot_script << "set colorbox\n";

    plot_script << "nframes = " << frame_id << "\n";
    plot_script << "frame_dt = " << frame_stride * dt << "\n";

    plot_script << "do for [i=0:nframes-1] {\n";
    plot_script << "    set title sprintf('2D Diffusion, t = %.3f', i*frame_dt)\n";
    plot_script << "    splot sprintf('frames/frame_%04d.dat', i) using 1:2:3 with pm3d notitle\n";
    plot_script << "    pause 0.125\n";
    plot_script << "}\n";

    plot_script.close();

    // Run animation

    if (system("gnuplot -persist plot_animation.gnu") != 0) {
        cerr << "Error: Failed to execute GNUplot animation.\n";
        return 1;
    }

    return 0;
}
