/**
 * @file cylinder_flow_2D.cpp
 * @brief Solves the 2D incompressible Navier-Stokes equations in a channel with an immersed cylinder obstacle
 *
 * The equations being solved are:
 *      $$ \nabla \cdot \mathbf{u} = 0 $$
 *      $$ \rho \frac{\partial \mathbf{u}}{\partial t}
 *         + \rho \nabla \cdot (\mathbf{u} \otimes \mathbf{u})
 *         = - \nabla p + \mu \nabla^2 \mathbf{u} $$
 *
 * A projection method is used:
 * - Pressure correction to enforce incompressibility
 *
 * ## Spatial Domain:
 * - The computational domain is $x \in [0, 8]$, $y \in [-1, 1]$
 * - The channel contains an internal obstacle represented by a cell mask
 * - The grid uses $m = 481$ cells in the $x$-direction and $n = 121$ cells in the $y$-direction
 *
 * ## Boundary Conditions:
 * - Inlet: prescribed horizontal velocity profile, $u = U_{\mathrm{init}}$, $v = 0$
 * - Outlet: prescribed pressure, $p = 0$
 * - Top and bottom walls: no-slip, $u = 0$, $v = 0$
 * - Obstacle region: masked velocity, $u = 0$, $v = 0$
 *
 * The discrete operators are built using MOLE operators.
 *
 * The final velocity and pressure fields are displayed in a single gnuplot figure:
 * - top:    heatmap of `U`
 * - middle: heatmap of `V`
 * - bottom: heatmap of `p`
 *
 * Extra note:
 *   Re-apply velocity boundary values and obstacle mask after projection.
 *   The pressure-correction step updates the full cell-centered field,
 *   so inlet/wall/corner/masked values are enforced again strongly here.
 */

#include <cmath>
#include <cstdio>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <vector>
#include "mole.h"

using namespace arma;

static uvec bc_left_indices(u32 m, u32 n) {
  uvec idx(n);
  u32 nx = m + 2;

  for (u32 jj = 0; jj < n; ++jj) {
    u32 j = jj + 1;
    idx(jj) = nx * j;
  }

  return idx;
}

static uvec bc_right_indices(u32 m, u32 n) {
  uvec idx(n);
  u32 nx = m + 2;
  u32 i = m + 1;

  for (u32 jj = 0; jj < n; ++jj) {
    u32 j = jj + 1;
    idx(jj) = i + nx * j;
  }

  return idx;
}

static uvec bc_bottom_indices(u32 m) {
  uvec idx(m + 2);

  for (u32 i = 0; i < m + 2; ++i) {
    idx(i) = i;
  }

  return idx;
}

static uvec bc_top_indices(u32 m, u32 n) {
  uvec idx(m + 2);
  u32 nx = m + 2;
  u32 j = n + 1;

  for (u32 i = 0; i < m + 2; ++i) {
    idx(i) = i + nx * j;
  }

  return idx;
}

static void applyVelocityBCAndMask(mat& U, mat& V, double Uin, int i1, int i2,
                                   int j1, int j2) {
  U.row(0).fill(Uin);
  V.row(0).zeros();

  U.row(U.n_rows - 1) = U.row(U.n_rows - 2);
  V.row(V.n_rows - 1) = V.row(V.n_rows - 2);

  U.submat(1, 0, U.n_rows - 1, 0).zeros();
  V.submat(1, 0, V.n_rows - 1, 0).zeros();

  U.submat(1, U.n_cols - 1, U.n_rows - 1, U.n_cols - 1).zeros();
  V.submat(1, V.n_cols - 1, V.n_rows - 1, V.n_cols - 1).zeros();

  U(0, 0) = 0.0;
  U(0, U.n_cols - 1) = 0.0;
  V(0, 0) = 0.0;
  V(0, V.n_cols - 1) = 0.0;

  U.submat(i1, j1, i2, j2).zeros();
  V.submat(i1, j1, i2, j2).zeros();
}

static void writeFieldToGnuplot(FILE* gp, const mat& F, const vec& xgrid,
                                const vec& ygrid, double x_start,
                                double y_start) {
  for (uword i = 1; i < F.n_rows - 1; ++i) {
    for (uword j = 1; j < F.n_cols - 1; ++j) {
      const double x_phys = x_start + xgrid(i);
      const double y_phys = y_start + ygrid(j);
      std::fprintf(gp, "%.16e %.16e %.16e\n", x_phys, y_phys, F(i, j));
    }
    std::fprintf(gp, "\n");
  }
  std::fprintf(gp, "e\n");
}

static void plotFinalFields(const mat& U_final, const mat& V_final,
                            const mat& p_final, const vec& xgrid,
                            const vec& ygrid, double x_start, double x_end,
                            double y_start, double y_end) {
  FILE* gp = popen("gnuplot -persist", "w");
  if (!gp) {
    throw std::runtime_error("Failed to launch gnuplot. Make sure gnuplot is installed and available in PATH.");
  }

  // Use the system default interactive terminal. On macOS, if needed, you can
  // uncomment one of the following lines depending on your gnuplot build:
  // std::fprintf(gp, "set term qt\n");
  // std::fprintf(gp, "set term aqua\n");

  std::fprintf(gp, "unset key\n");
  std::fprintf(gp, "set multiplot layout 3,1 title 'Final fields: U, V, p'\n");
  std::fprintf(gp, "set xrange [%.16e:%.16e]\n", x_start, x_end);
  std::fprintf(gp, "set yrange [%.16e:%.16e]\n", y_start, y_end);
  std::fprintf(gp, "set tics out\n");
  std::fprintf(gp, "set size ratio -1\n");
  std::fprintf(gp, "set palette rgbformulae 22,13,-31\n");

  std::fprintf(gp, "set title 'U velocity'\n");
  std::fprintf(gp, "set xlabel ''\n");
  std::fprintf(gp, "set ylabel 'y'\n");
  std::fprintf(gp, "set autoscale cb\n");
  std::fprintf(gp, "plot '-' using 1:2:3 with image\n");
  writeFieldToGnuplot(gp, U_final, xgrid, ygrid, x_start, y_start);

  std::fprintf(gp, "set title 'V velocity'\n");
  std::fprintf(gp, "set xlabel ''\n");
  std::fprintf(gp, "set ylabel 'y'\n");
  std::fprintf(gp, "set autoscale cb\n");
  std::fprintf(gp, "plot '-' using 1:2:3 with image\n");
  writeFieldToGnuplot(gp, V_final, xgrid, ygrid, x_start, y_start);

  std::fprintf(gp, "set title 'Pressure'\n");
  std::fprintf(gp, "set xlabel 'x'\n");
  std::fprintf(gp, "set ylabel 'y'\n");
  std::fprintf(gp, "set autoscale cb\n");
  std::fprintf(gp, "plot '-' using 1:2:3 with image\n");
  writeFieldToGnuplot(gp, p_final, xgrid, ygrid, x_start, y_start);

  std::fprintf(gp, "unset multiplot\n");
  std::fflush(gp);
  pclose(gp);
}

int main() {
  double Re = 200.0;
  u16 k = 2;
  double tspan = 32.0;
  double dt = 0.005;

  double x_start = 0.0;
  double x_end = 8.0;
  double y_start = -1.0;
  double y_end = 1.0;

  u32 m = 481;
  u32 n = 121;

  double dx = (x_end - x_start) / static_cast<double>(m);
  double dy = (y_end - y_start) / static_cast<double>(n);

  vec xgrid(m + 2, fill::zeros);
  vec ygrid(n + 2, fill::zeros);

  xgrid(0) = 0.0;
  xgrid(m + 1) = x_end - x_start;
  for (u32 i = 1; i <= m; ++i) {
    xgrid(i) = (static_cast<double>(i) - 0.5) * dx;
  }

  ygrid(0) = 0.0;
  ygrid(n + 1) = y_end - y_start;
  for (u32 j = 1; j <= n; ++j) {
    ygrid(j) = (static_cast<double>(j) - 0.5) * dy;
  }

  mat X(m + 2, n + 2, fill::zeros);
  mat Y(m + 2, n + 2, fill::zeros);
  for (u32 i = 0; i < m + 2; ++i) {
    for (u32 j = 0; j < n + 2; ++j) {
      X(i, j) = xgrid(i);
      Y(i, j) = ygrid(j);
    }
  }

  double cylin_pos = 1.0 / 8.0;
  double cylin_size = 1.0 / 10.0;

  double rho = 1.0;
  double D0 = 2.0 * cylin_size;
  double U_init = 1.0;
  double nu = U_init * D0 / Re;

  Laplacian L(k, m, n, dx, dy);
  Divergence D(k, m, n, dx, dy);
  Gradient G(k, m, n, dx, dy);

  Interpol I(m, n, 0.5, 0.5);

  Interpol Ix(true, m, 0.5);
  Interpol Iy(true, n, 0.5);

  sp_mat Im(m + 2, m);
  sp_mat In(n + 2, n);
  Im.submat(1, 0, m, m - 1) = speye<sp_mat>(m, m);
  In.submat(1, 0, n, n - 1) = speye<sp_mat>(n, n);

  sp_mat Sx = Utils::spkron(In, sp_mat(Ix));
  sp_mat Sy = Utils::spkron(sp_mat(Iy), Im);

  uword Ncell = static_cast<uword>(m + 2) * static_cast<uword>(n + 2);
  uword Nfaces_x = static_cast<uword>(m + 1) * static_cast<uword>(n);
  uword Nfaces_y = static_cast<uword>(m) * static_cast<uword>(n + 1);

  sp_mat II(2 * Ncell, Nfaces_x + Nfaces_y);
  II.submat(0, 0, Ncell - 1, Nfaces_x - 1) = Sx;
  II.submat(Ncell, Nfaces_x, 2 * Ncell - 1, Nfaces_x + Nfaces_y - 1) = Sy;

  sp_mat Icell = speye<sp_mat>(Ncell, Ncell);
  sp_mat M = Icell - 0.5 * dt * nu * sp_mat(L);
  sp_mat Mp = Icell + 0.5 * dt * nu * sp_mat(L);

  mat U = 0.0 * X + U_init;
  mat V = 0.0 * X;

  int m_unit = static_cast<int>(std::floor(cylin_pos * static_cast<double>(m)));
  int halfN1 = static_cast<int>(0.5 * static_cast<double>(n + 3));
  int rad = static_cast<int>(std::floor(cylin_size * static_cast<double>(m_unit)));

  int i1 = m_unit - rad - 1;
  int i2 = m_unit + rad - 1;
  int j1 = halfN1 - rad - 1;
  int j2 = halfN1 + rad - 1;

  U.submat(i1, j1, i2, j2).zeros();
  V.submat(i1, j1, i2, j2).zeros();

  vec U_flat = vectorise(U);
  vec V_flat = vectorise(V);

  vec AdvU_prev(Ncell, fill::zeros);
  vec AdvV_prev(Ncell, fill::zeros);
  vec p_new_flat(Ncell, fill::zeros);

  uvec rowsbc_left = bc_left_indices(m, n);
  uvec rowsbc_right = bc_right_indices(m, n);
  uvec rowsbc_bottom = bc_bottom_indices(m);
  uvec rowsbc_top = bc_top_indices(m, n);

  uvec rowsbcU = unique(join_cols(join_cols(rowsbc_left, rowsbc_right),
                                  join_cols(rowsbc_bottom, rowsbc_top)));
  uvec rowsbcV = rowsbcU;
  uvec rowsbcP = rowsbcU;

  sp_mat PU = speye<sp_mat>(Ncell, Ncell);
  sp_mat PV = speye<sp_mat>(Ncell, Ncell);
  sp_mat PP = speye<sp_mat>(Ncell, Ncell);

  for (uword i = 0; i < rowsbcU.n_elem; ++i) {
    PU(rowsbcU(i), rowsbcU(i)) = 0.0;
    PV(rowsbcV(i), rowsbcV(i)) = 0.0;
    PP(rowsbcP(i), rowsbcP(i)) = 0.0;
  }

  MixedBC bcU_op(k, m, dx, n, dy, "Dirichlet", {1.0}, "Neumann", {1.0},
                 "Dirichlet", {1.0}, "Dirichlet", {1.0});
  MixedBC bcV_op(k, m, dx, n, dy, "Dirichlet", {1.0}, "Neumann", {1.0},
                 "Dirichlet", {1.0}, "Dirichlet", {1.0});
  MixedBC bcP_op(k, m, dx, n, dy, "Neumann", {1.0}, "Dirichlet", {1.0},
                 "Neumann", {1.0}, "Neumann", {1.0});

  sp_mat Au = PU * M + sp_mat(bcU_op);
  sp_mat Av = PV * M + sp_mat(bcV_op);
  sp_mat Ap = PP * sp_mat(L) + sp_mat(bcP_op);

  vec bU0(Ncell, fill::zeros);
  vec bV0(Ncell, fill::zeros);
  vec bP0(Ncell, fill::zeros);

  bU0.elem(rowsbc_left).fill(U_init);
  bU0.elem(rowsbc_right).zeros();
  bU0.elem(rowsbc_bottom).zeros();
  bU0.elem(rowsbc_top).zeros();

  bV0.elem(rowsbc_left).zeros();
  bV0.elem(rowsbc_right).zeros();
  bV0.elem(rowsbc_bottom).zeros();
  bV0.elem(rowsbc_top).zeros();

  bP0.elem(rowsbc_left).zeros();
  bP0.elem(rowsbc_right).zeros();
  bP0.elem(rowsbc_bottom).zeros();
  bP0.elem(rowsbc_top).zeros();

  arma::spsolve_factoriser Au_fac;
  arma::spsolve_factoriser Av_fac;
  arma::spsolve_factoriser Ap_fac;

  if (!Au_fac.factorise(Au)) {
    throw std::runtime_error("Failed to factorize Au");
  }

  if (!Av_fac.factorise(Av)) {
    throw std::runtime_error("Failed to factorize Av");
  }

  if (!Ap_fac.factorise(Ap)) {
    throw std::runtime_error("Failed to factorize Ap");
  }

  int nSteps = static_cast<int>(std::llround(tspan / dt));
  int plotEvery = 100;

  for (int t_step = 1; t_step <= nSteps; ++t_step) {
    vec U_stag = sp_mat(I) * U_flat;
    vec U_on_u = U_stag.rows(0, Nfaces_x - 1);
    vec U_on_v = U_stag.rows(Nfaces_x, Nfaces_x + Nfaces_y - 1);

    vec V_stag = sp_mat(I) * V_flat;
    vec V_on_u = V_stag.rows(0, Nfaces_x - 1);
    vec V_on_v = V_stag.rows(Nfaces_x, Nfaces_x + Nfaces_y - 1);

    vec UU_on_u = U_on_u % U_on_u;
    vec UV_on_u = U_on_u % V_on_u;
    vec VV_on_v = V_on_v % V_on_v;
    vec UV_on_v = U_on_v % V_on_v;

    vec u_div = join_cols(UU_on_u, UV_on_v);
    vec v_div = join_cols(UV_on_u, VV_on_v);

    vec AdvU_n = sp_mat(D) * u_div;
    vec AdvV_n = sp_mat(D) * v_div;

    vec AdvU_ab(Ncell, fill::zeros);
    vec AdvV_ab(Ncell, fill::zeros);
    if (t_step == 1) {
      AdvU_ab = AdvU_n;
      AdvV_ab = AdvV_n;
    } else {
      AdvU_ab = 1.5 * AdvU_n - 0.5 * AdvU_prev;
      AdvV_ab = 1.5 * AdvV_n - 0.5 * AdvV_prev;
    }

    vec rhsU = Mp * U_flat - dt * AdvU_ab;
    vec rhsV = Mp * V_flat - dt * AdvV_ab;

    vec rhsU_bc = rhsU;
    vec rhsV_bc = rhsV;
    rhsU_bc.elem(rowsbcU).zeros();
    rhsV_bc.elem(rowsbcV).zeros();
    rhsU_bc += bU0;
    rhsV_bc += bV0;

    mat U_star_mat;
    mat V_star_mat;

    if (!Au_fac.solve(U_star_mat, rhsU_bc)) {
      throw std::runtime_error("Failed to solve for U_star_flat");
    }

    if (!Av_fac.solve(V_star_mat, rhsV_bc)) {
      throw std::runtime_error("Failed to solve for V_star_flat");
    }

    vec U_star_flat = vectorise(U_star_mat);
    vec V_star_flat = vectorise(V_star_mat);

    mat U_star = reshape(U_star_flat, m + 2, n + 2);
    mat V_star = reshape(V_star_flat, m + 2, n + 2);

    U_star.submat(i1, j1, i2, j2).zeros();
    V_star.submat(i1, j1, i2, j2).zeros();

    U_star(0, 0) = 0.0;
    U_star(0, U_star.n_cols - 1) = 0.0;
    V_star(0, 0) = 0.0;
    V_star(0, V_star.n_cols - 1) = 0.0;

    U_star_flat = vectorise(U_star);
    V_star_flat = vectorise(V_star);

    vec U_star_stag = sp_mat(I) * U_star_flat;
    vec U_star_on_u = U_star_stag.rows(0, Nfaces_x - 1);

    vec V_star_stag = sp_mat(I) * V_star_flat;
    vec V_star_on_v = V_star_stag.rows(Nfaces_x, Nfaces_x + Nfaces_y - 1);

    vec UV_star_div = join_cols(U_star_on_u, V_star_on_v);
    vec RHS = (rho / dt) * (sp_mat(D) * UV_star_div);

    vec RHS_bc = RHS;
    RHS_bc.elem(rowsbcP).zeros();
    RHS_bc += bP0;

    mat p_new_mat;
    if (!Ap_fac.solve(p_new_mat, RHS_bc)) {
      throw std::runtime_error("Failed to solve for p_new_flat");
    }

    p_new_flat = vectorise(p_new_mat);

    vec U_V_star_flat = join_cols(U_star_flat, V_star_flat);
    vec U_V_flat = U_V_star_flat - (dt / rho) * (II * (sp_mat(G) * p_new_flat));

    mat U_new = reshape(U_V_flat.rows(0, Ncell - 1), m + 2, n + 2);
    mat V_new = reshape(U_V_flat.rows(Ncell, 2 * Ncell - 1), m + 2, n + 2);

    applyVelocityBCAndMask(U_new, V_new, U_init, i1, i2, j1, j2);

    U_flat = vectorise(U_new);
    V_flat = vectorise(V_new);

    AdvU_prev = AdvU_n;
    AdvV_prev = AdvV_n;

    if ((t_step % plotEvery) == 0 || t_step == 1 || t_step == nSteps) {
      double maxU = abs(U_new).max();
      double maxV = abs(V_new).max();
      double CFL = dt * (maxU / dx + maxV / dy);
      double inletMean = mean(U_new.row(0));

      std::cout << "step " << std::setw(6) << t_step << "/" << std::setw(6)
                << nSteps << " | t=" << std::fixed << std::setprecision(6)
                << dt * static_cast<double>(t_step) << " | CFL~"
                << std::setprecision(3) << CFL << " | max|U|="
                << std::scientific << std::setprecision(3) << maxU
                << " | max|V|=" << maxV << " | mean(U_in)="
                << std::fixed << std::setprecision(3) << inletMean << '\n';
    }
  }

  mat U_final = reshape(U_flat, m + 2, n + 2);
  mat V_final = reshape(V_flat, m + 2, n + 2);
  mat p_final = reshape(p_new_flat, m + 2, n + 2);

  std::cout << "Displaying final fields with gnuplot..." << std::endl;
  plotFinalFields(U_final, V_final, p_final, xgrid, ygrid,
                  x_start, x_end, y_start, y_end);

  return 0;
}