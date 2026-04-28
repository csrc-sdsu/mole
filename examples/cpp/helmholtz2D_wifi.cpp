#include <armadillo>
#include "mole.h"
#include "addscalarbc.h"
#include <iostream>
#include <fstream>
#include <complex>
#include <cstdlib>

using namespace arma;

// --------------------------------------------------
// Helper: extract sparse principal submatrix A(keep,keep)
// for Armadillo builds that do not support SpMat::submat(uvec,uvec)
// --------------------------------------------------
static sp_cx_mat extract_sparse_principal_submatrix(
    const sp_cx_mat& A,
    const uvec& keep
) {
    const uword n_keep = keep.n_elem;

    // Map old global indices -> new reduced indices
    uvec old_to_new(A.n_rows, fill::zeros);
    umat is_kept(A.n_rows, 1, fill::zeros);

    for (uword k = 0; k < n_keep; ++k) {
        old_to_new(keep(k)) = k;
        is_kept(keep(k), 0) = 1;
    }

    // Worst-case allocation: every nonzero survives
    umat locations(2, A.n_nonzero);
    cx_vec values(A.n_nonzero);

    uword count = 0;
    for (sp_cx_mat::const_iterator it = A.begin(); it != A.end(); ++it) {
        const uword i = it.row();
        const uword j = it.col();

        if (is_kept(i, 0) && is_kept(j, 0)) {
            locations(0, count) = old_to_new(i);
            locations(1, count) = old_to_new(j);
            values(count) = (*it);
            ++count;
        }
    }

    locations.resize(2, count);
    values.resize(count);

    return sp_cx_mat(locations, values, n_keep, n_keep);
}

int main() {
    // --------------------------------------------------
    // Problem parameters
    // --------------------------------------------------
    const double aa = 0.7;
    const double bb = 0.9 * 0.5;
    const double wn = 6.0;

    const double hsx = 2.0;
    const double hsy = 20.0;
    const double hsr = 1.0;

    const uint16_t k = 2;
    const uint32_t m = 500;
    const uint32_t n = 500;

    const double a  = 0.0;
    const double b  = 40.0;
    const double c0 = 0.0;
    const double d  = 40.0;

    const uword Nx = m + 2;
    const uword Ny = n + 2;
    const uword N  = Nx * Ny;

    const double dx = (b - a)  / static_cast<double>(m);
    const double dy = (d - c0) / static_cast<double>(n);

    // --------------------------------------------------
    // 2D staggered grid
    // --------------------------------------------------
    vec xgrid(Nx, fill::zeros);
    vec ygrid(Ny, fill::zeros);

    xgrid(0) = a;
    for (uword i = 1; i <= m; ++i) {
        xgrid(i) = a + dx / 2.0 + (i - 1) * dx;
    }
    xgrid(m + 1) = b;

    ygrid(0) = c0;
    for (uword j = 1; j <= n; ++j) {
        ygrid(j) = c0 + dy / 2.0 + (j - 1) * dy;
    }
    ygrid(n + 1) = d;

    // --------------------------------------------------
    // Meshgrid-style arrays
    // --------------------------------------------------
    mat X = repmat(xgrid, 1, Ny);
    mat Y = repmat(ygrid.t(), Nx, 1);

    // --------------------------------------------------
    // Wall mask
    // --------------------------------------------------
    umat WALL = conv_to<umat>::from(
        ((X >= 10.0) % (X <= 39.0) % (Y >= 20.0) % (Y <= 21.0)) ||
        ((X >= 30.0) % (X <= 31.0) % (Y >= 1.0 ) % (Y <= 16.0)) ||
        ((X <= 0.5)  || (X >= 39.5) || (Y <= 0.5) || (Y >= 39.5))
    );

    // --------------------------------------------------
    // Complex coefficient
    // --------------------------------------------------
    const std::complex<double> wall_coeff(aa, bb);
    cx_mat C = (wn * wn) / square(1.0 + wall_coeff * conv_to<mat>::from(WALL));
    cx_vec cvec = vectorise(C);

    // --------------------------------------------------
    // Hotspot mask
    // --------------------------------------------------
    mat HSmat = conv_to<mat>::from(
        square(X - hsx) + square(Y - hsy) < (hsr * hsr)
    );
    vec HS = vectorise(HSmat);

    uvec ind = find(HS > 0.5);

    uvec is_hotspot(N, fill::zeros);
    is_hotspot.elem(ind).ones();
    uvec freenodes = find(is_hotspot == 0);

    // --------------------------------------------------
    // Mimetic Laplacian
    // --------------------------------------------------
    Laplacian Lreal(k, m, n, dx, dy);
    sp_mat Llap = sp_mat(Lreal);

    // --------------------------------------------------
    // Boundary-condition matrix using addScalarBClhs
    // homogeneous Neumann on all four sides
    // --------------------------------------------------
    vec dc = zeros<vec>(4);
    vec nc = ones<vec>(4);

    sp_mat Al, Ar, Ab, At;
    AddScalarBC::addScalarBClhs(k, m, dx, n, dy, dc, nc, Al, Ar, Ab, At);

    sp_mat Lbc = Al + Ar + Ab + At;

    // --------------------------------------------------
    // Full operator
    // --------------------------------------------------
    sp_cx_mat L = conv_to<sp_cx_mat>::from(Llap);
    L += sp_cx_mat(diagmat(cvec));
    L += conv_to<sp_cx_mat>::from(Lbc);

    // --------------------------------------------------
    // Reduced-system solve
    // RHS = -L*HS
    // SOL(freenodes) = Lff \ RHS(freenodes)
    // SOL(ind) = 1
    // --------------------------------------------------
    cx_vec HS_cx = conv_to<cx_vec>::from(HS);
    cx_vec RHS   = -L * HS_cx;

    sp_cx_mat Lff = extract_sparse_principal_submatrix(L, freenodes);
    cx_vec RHSf   = RHS.elem(freenodes);

    cx_vec SOL(N, fill::zeros);
    cx_vec SOLf;

    bool ok = spsolve(SOLf, Lff, RHSf, "superlu");
    if (!ok) {
        std::cerr << "Error: Reduced sparse solve failed.\n";
        return 1;
    }

    SOL.elem(freenodes) = SOLf;
    SOL.elem(ind).ones();

    // --------------------------------------------------
    // Plot quantity
    // --------------------------------------------------
    vec logSOL = log(abs(SOL) + 1.0e-14);
    mat LOGSOL = reshape(logSOL, Nx, Ny);

    // --------------------------------------------------
    // Output solution data
    // --------------------------------------------------
    std::ofstream data_file("helmholtz2d_logsol.dat");
    if (!data_file) {
        std::cerr << "Error: Failed to create solution data file.\n";
        return 1;
    }

    for (uword i = 0; i < Nx; ++i) {
        for (uword j = 0; j < Ny; ++j) {
            data_file << X(i, j) << " "
                      << Y(i, j) << " "
                      << LOGSOL(i, j) << "\n";
        }
        data_file << "\n";
    }
    data_file.close();

    // --------------------------------------------------
    // GNUplot script
    // --------------------------------------------------
    std::ofstream plot_script("plot.gnu");
    if (!plot_script) {
        std::cerr << "Error: Failed to create GNUplot script.\n";
        return 1;
    }

    plot_script << "set title \"2D Helmholtz: log(|SOL| + 1e-14)\"\n";
    plot_script << "set xlabel 'x'\n";
    plot_script << "set ylabel 'y'\n";
    plot_script << "set view map\n";
    plot_script << "set pm3d at b\n";
    plot_script << "set colorbox\n";
    plot_script << "set size ratio -1\n";
    plot_script << "splot 'helmholtz2d_logsol.dat' with pm3d notitle\n";

    plot_script.close();

    if (system("gnuplot -persist plot.gnu") != 0) {
        std::cerr << "Error: Failed to execute GNUplot.\n";
        return 1;
    }

    return 0;
}





