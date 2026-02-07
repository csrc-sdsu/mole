/**
 * @file cylinder_flow_2D.cpp
 * @brief Solves the 2D incompressible Navier–Stokes equations for channel flow past an obstacle
 *        using a projection (pressure-correction) method.
 *
 * This example demonstrates how to assemble and use MOLE mimetic operators (Laplacian, Divergence,
 * Gradient, and interpolation operators) to advance the 2D incompressible Navier–Stokes equations
 * in time on a structured Cartesian grid. The convective term is advanced with AB2 (AB1 on the first
 * step) and viscous diffusion is treated with Crank–Nicolson. Incompressibility is enforced via a
 * pressure Poisson solve and velocity correction.
 *
 * Equation:
 *   - Momentum:
 *     \f[
 *       \frac{\partial \mathbf{u}}{\partial t} + (\mathbf{u}\cdot\nabla)\mathbf{u}
 *       = -\nabla p + \nu\nabla^{2}\mathbf{u}
 *     \f]
 *   - Incompressibility:
 *     \f[
 *       \nabla\cdot\mathbf{u} = 0
 *     \f]
 *
 * Domain:
 *   - Rectangular channel: \f$ x \in [0,8],\; y \in [-1,1] \f$.
 *   - A solid obstacle is imposed by masking a block of cells near \f$ x/L_x = 1/8 \f$ with size
 *     set by `cylin_size` (note: the obstacle is applied as an axis-aligned cell mask).
 *
 * Boundary Conditions:
 *   - Velocity \f$\mathbf{u}=(u,v)\f$:
 *     - Inlet (left): Dirichlet, \f$ u = U_{\mathrm{init}},\; v=0 \f$.
 *     - Outlet (right): Neumann (zero normal gradient) on velocity.
 *     - Walls (top/bottom): no-slip, \f$ u=v=0 \f$.
 *     - Obstacle: no-slip enforced by zeroing masked cells each step.
 *   - Pressure \f$p\f$:
 *     - Outlet (right): Dirichlet, \f$ p = 0 \f$ (reference).
 *     - Elsewhere: Neumann (zero normal gradient).
 *
 * Build/Run:
 * @code
 *   cd <mole-repo>/build
 *   cmake --build . -j
 *   ./examples/cpp/cylinder_flow_2D
 * @endcode
 *
 * Outputs:
 *   - U_final.csv, V_final.csv, p_final.csv
 *   - speed_final.png (macOS only; generated via 'sips'. Otherwise a PPM is kept.)
 */

#include <armadillo>

// Optional Eigen (for reusable sparse factorization)
#if defined(__has_include)
  #if __has_include(<Eigen/Sparse>) && __has_include(<Eigen/SparseLU>)
    #define HAS_EIGEN 1
    #include <Eigen/Sparse>
    #include <Eigen/SparseLU>
  #else
    #define HAS_EIGEN 0
  #endif
#else
  #define HAS_EIGEN 0
#endif

// Mimetic operator library (in ./cpp)
#include "mole.h"

#include <array>
#include <vector>
#include <string>
#include <iostream>
#include <iomanip>
#include <cmath>
#include <fstream>
#include <stdexcept>
#include <cstdlib> // std::system
#include <cstdio>  // std::remove

using arma::sp_mat;
using arma::vec;
using arma::uvec;
using arma::mat;

// Reusable sparse linear solver
class SparseSolver {
public:
  SparseSolver() = default;

  void factorize(const sp_mat& A) {
    n_ = static_cast<long long>(A.n_rows);
#if HAS_EIGEN
    eigen_A_.resize(static_cast<int>(A.n_rows), static_cast<int>(A.n_cols));
    std::vector<Eigen::Triplet<double>> trip;
    trip.reserve(A.n_nonzero);
    for (auto it = A.begin(); it != A.end(); ++it) {
      trip.emplace_back(static_cast<int>(it.row()), static_cast<int>(it.col()), static_cast<double>(*it));
    }
    eigen_A_.setFromTriplets(trip.begin(), trip.end());
    solver_.analyzePattern(eigen_A_);
    solver_.factorize(eigen_A_);
    if (solver_.info() != Eigen::Success) {
      throw std::runtime_error("Eigen::SparseLU factorization failed");
    }
#else
    A_ = A; // fallback
#endif
  }

  vec solve(const vec& b) const {
    if (static_cast<long long>(b.n_elem) != n_) {
      throw std::runtime_error("SparseSolver::solve dimension mismatch");
    }
#if HAS_EIGEN
    Eigen::Map<const Eigen::VectorXd> rhs(b.memptr(), static_cast<int>(b.n_elem));
    Eigen::VectorXd x = solver_.solve(rhs);
    if (solver_.info() != Eigen::Success) {
      throw std::runtime_error("Eigen::SparseLU solve failed");
    }
    return vec(x.data(), static_cast<arma::uword>(x.size()));
#else
    vec x;
    bool ok = arma::spsolve(x, A_, b);
    if (!ok) {
      throw std::runtime_error("arma::spsolve failed (no Eigen available)");
    }
    return x;
#endif
  }

  static bool using_eigen() {
#if HAS_EIGEN
    return true;
#else
    return false;
#endif
  }

private:
  long long n_{0};
#if HAS_EIGEN
  Eigen::SparseMatrix<double> eigen_A_;
  Eigen::SparseLU<Eigen::SparseMatrix<double>, Eigen::COLAMDOrdering<int>> solver_;
#else
  sp_mat A_;
#endif
};

// Scalar BC wrapper
struct BCSide {
  std::string type;           // Dirichlet/Neumann/Robin
  std::vector<double> coeffs; // {a} or {b} or {a,b}
  bool active{false};
};

static BCSide make_side(double a, double b) {
  BCSide s;
  s.active = (a != 0.0) || (b != 0.0);
  if (!s.active) {
    s.type = "Dirichlet";
    s.coeffs = {0.0};
    return s;
  }
  if (a != 0.0 && b == 0.0) {
    s.type = "Dirichlet";
    s.coeffs = {a};
  } else if (a == 0.0 && b != 0.0) {
    s.type = "Neumann";
    s.coeffs = {b};
  } else {
    s.type = "Robin";
    s.coeffs = {a, b};
  }
  return s;
}

static uvec bc_left_indices(unsigned m, unsigned n) {
  uvec idx(n);
  const unsigned nx = m + 2;
  for (unsigned jj = 0; jj < n; ++jj) {
    unsigned j = jj + 1;
    idx(jj) = 0 + nx * j;
  }
  return idx;
}

static uvec bc_right_indices(unsigned m, unsigned n) {
  uvec idx(n);
  const unsigned nx = m + 2;
  const unsigned i = m + 1;
  for (unsigned jj = 0; jj < n; ++jj) {
    unsigned j = jj + 1;
    idx(jj) = i + nx * j;
  }
  return idx;
}

static uvec bc_bottom_indices(unsigned m, unsigned n) {
  (void)n;
  uvec idx(m + 2);
  for (unsigned i = 0; i < m + 2; ++i) idx(i) = i;
  return idx;
}

static uvec bc_top_indices(unsigned m, unsigned n) {
  uvec idx(m + 2);
  const unsigned nx = m + 2;
  const unsigned j = n + 1;
  for (unsigned i = 0; i < m + 2; ++i) idx(i) = i + nx * j;
  return idx;
}

struct BCSystem {
  sp_mat A_bc;
  vec b0;
  uvec rowsbc;
};

static BCSystem build_scalar_bc_system(
    const sp_mat& A,
    unsigned k, unsigned m, double dx, unsigned n, double dy,
    const std::array<double,4>& dc, const std::array<double,4>& nc,
    const std::array<vec,4>& v) {

  const arma::uword N = A.n_rows;
  if (A.n_rows != A.n_cols) throw std::runtime_error("A must be square");

  const BCSide left   = make_side(dc[0], nc[0]);
  const BCSide right  = make_side(dc[1], nc[1]);
  const BCSide bottom = make_side(dc[2], nc[2]);
  const BCSide top    = make_side(dc[3], nc[3]);

  MixedBC bc_op(static_cast<u16>(k), static_cast<u32>(m), dx,
                static_cast<u32>(n), dy,
                left.type, left.coeffs,
                right.type, right.coeffs,
                bottom.type, bottom.coeffs,
                top.type, top.coeffs);

  std::vector<uvec> pieces;
  if (left.active)   pieces.push_back(bc_left_indices(m, n));
  if (right.active)  pieces.push_back(bc_right_indices(m, n));
  if (bottom.active) pieces.push_back(bc_bottom_indices(m, n));
  if (top.active)    pieces.push_back(bc_top_indices(m, n));

  uvec rowsbc;
  if (!pieces.empty()) {
    rowsbc = pieces[0];
    for (size_t i = 1; i < pieces.size(); ++i) rowsbc = arma::join_cols(rowsbc, pieces[i]);
    rowsbc = arma::unique(rowsbc);
  } else {
    rowsbc.set_size(0);
  }

  sp_mat P = arma::speye<sp_mat>(N, N);
  for (arma::uword ii = 0; ii < rowsbc.n_elem; ++ii) {
    const arma::uword r = rowsbc(ii);
    P(r, r) = 0.0;
  }

  BCSystem out;
  out.A_bc = P * A + static_cast<sp_mat>(bc_op);
  out.b0 = arma::zeros<vec>(N);

  if (left.active)   out.b0.elem(bc_left_indices(m, n))   = v[0];
  if (right.active)  out.b0.elem(bc_right_indices(m, n))  = v[1];
  if (bottom.active) out.b0.elem(bc_bottom_indices(m, n)) = v[2];
  if (top.active)    out.b0.elem(bc_top_indices(m, n))    = v[3];

  out.rowsbc = rowsbc;
  return out;
}

// quick grayscale PPM
static void write_ppm_grayscale(const std::string& filename, const mat& field) {
  const arma::uword nx = field.n_rows;
  const arma::uword ny = field.n_cols;

  double fmin = field.min();
  double fmax = field.max();
  if (!std::isfinite(fmin) || !std::isfinite(fmax) || fmax <= fmin) {
    throw std::runtime_error("write_ppm_grayscale: invalid range");
  }

  std::ofstream os(filename, std::ios::binary);
  if (!os) throw std::runtime_error("Failed to open output image: " + filename);

  os << "P6\n" << nx << " " << ny << "\n255\n";

  for (arma::sword j = static_cast<arma::sword>(ny) - 1; j >= 0; --j) {
    for (arma::uword i = 0; i < nx; ++i) {
      double t = (field(i, static_cast<arma::uword>(j)) - fmin) / (fmax - fmin);
      t = std::min(1.0, std::max(0.0, t));
      unsigned char g = static_cast<unsigned char>(std::lround(255.0 * t));
      unsigned char rgb[3] = {g, g, g};
      os.write(reinterpret_cast<const char*>(rgb), 3);
    }
  }
}

// enforce inlet/outlet/walls + cylinder
static void applyVelocityBCAndMask(
    mat& U, mat& V,
    double Uin,
    int i1, int i2, int j1, int j2) {

  const arma::uword nx = U.n_rows;
  const arma::uword ny = U.n_cols;

  U.row(0).fill(Uin);
  V.row(0).zeros();

  U.row(nx - 1) = U.row(nx - 2);
  V.row(nx - 1) = V.row(nx - 2);

  U.submat(1, 0, nx - 1, 0).zeros();
  V.submat(1, 0, nx - 1, 0).zeros();
  U.submat(1, ny - 1, nx - 1, ny - 1).zeros();
  V.submat(1, ny - 1, nx - 1, ny - 1).zeros();

  U(0, 0) = 0.0;       U(0, ny - 1) = 0.0;
  V(0, 0) = 0.0;       V(0, ny - 1) = 0.0;

  U.submat(i1, j1, i2, j2).zeros();
  V.submat(i1, j1, i2, j2).zeros();
}

int main() {
  // Problem parameters (numerical settings)
  const double Re = 200.0;
  const unsigned k = 2;
  const double tspan = 32.0;
  const double dt = 0.005;

  // Domain and grid
  const double x_start = 0.0, x_end = 8.0;
  const double y_start = -1.0, y_end = 1.0;
  const unsigned m = 481;
  const unsigned n = 121;
  const double dx = (x_end - x_start) / static_cast<double>(m);
  const double dy = (y_end - y_start) / static_cast<double>(n);

  // Obstacle (cylinder) geometry parameters
  const double cylin_pos = 1.0 / 8.0;
  const double cylin_size = 1.0 / 10.0;

  // Physical parameters
  const double rho = 1.0;
  const double D0 = 2.0 * cylin_size;
  const double U_init = 1.0;
  const double nu = U_init * D0 / Re;

  const arma::uword nx = m + 2;
  const arma::uword ny = n + 2;
  const arma::uword Ncell = nx * ny;
  const arma::uword Nfaces_x = (m + 1) * n;
  const arma::uword Nfaces_y = m * (n + 1);
  const arma::uword Nfaces = Nfaces_x + Nfaces_y;

  std::cout << "Ncell=" << Ncell << ", Nfaces=" << Nfaces
            << " (" << Nfaces_x << "+" << Nfaces_y << ")\n";

#if !HAS_EIGEN
  std::cerr << "[warn] Eigen headers not found; using arma::spsolve.\n";
#endif

  // Construct mimetic operators (MOLE)
  Laplacian L(static_cast<u16>(k), static_cast<u32>(m), static_cast<u32>(n), dx, dy);
  Divergence D(static_cast<u16>(k), static_cast<u32>(m), static_cast<u32>(n), dx, dy);
  Gradient   G(static_cast<u16>(k), static_cast<u32>(m), static_cast<u32>(n), dx, dy);

  Interpol I_cf(static_cast<u32>(m), static_cast<u32>(n), 0.5, 0.5);
  Interpol Ix_fc(true, static_cast<u32>(m), 0.5);
  Interpol Iy_fc(true, static_cast<u32>(n), 0.5);

  sp_mat Im(nx, m);
  Im.submat(1, 0, m, m - 1) = arma::speye<sp_mat>(m, m);

  sp_mat In(ny, n);
  In.submat(1, 0, n, n - 1) = arma::speye<sp_mat>(n, n);

  sp_mat Sx = Utils::spkron(In, static_cast<sp_mat>(Ix_fc));
  sp_mat Sy = Utils::spkron(static_cast<sp_mat>(Iy_fc), Im);

  // AB2 + CN diffusion
  sp_mat Icell = arma::speye<sp_mat>(Ncell, Ncell);
  sp_mat M  = Icell - (0.5 * dt * nu) * static_cast<sp_mat>(L);
  sp_mat Mp = Icell + (0.5 * dt * nu) * static_cast<sp_mat>(L);

  // Initial conditions / fields
  mat U(nx, ny, arma::fill::ones);
  U *= U_init;
  mat V(nx, ny, arma::fill::zeros);

  const int m_unit = static_cast<int>(std::floor(cylin_pos * static_cast<double>(m)));
  const int halfN1 = static_cast<int>(0.5 * static_cast<double>(n + 3));
  const int rad = static_cast<int>(std::floor(cylin_size * static_cast<double>(m_unit)));

  const int i1 = (m_unit - rad) - 1;
  const int i2 = (m_unit + rad) - 1;
  const int j1 = (halfN1 - rad) - 1;
  const int j2 = (halfN1 + rad) - 1;

  U.submat(i1, j1, i2, j2).zeros();
  V.submat(i1, j1, i2, j2).zeros();

  vec U_flat = arma::vectorise(U);
  vec V_flat = arma::vectorise(V);

  vec AdvU_prev(Ncell, arma::fill::zeros);
  vec AdvV_prev(Ncell, arma::fill::zeros);
  vec p_new_flat(Ncell, arma::fill::zeros);

  // Velocity Helmholtz operator boundary conditions
  const std::array<double,4> dcU = {1, 0, 1, 1};
  const std::array<double,4> ncU = {0, 1, 0, 0};
  std::array<vec,4> vU = {
    vec(n, arma::fill::ones),
    vec(n, arma::fill::zeros),
    vec(nx, arma::fill::zeros),
    vec(nx, arma::fill::zeros)
  };

  const std::array<double,4> dcV = {1, 0, 1, 1};
  const std::array<double,4> ncV = {0, 1, 0, 0};
  std::array<vec,4> vV = {
    vec(n, arma::fill::zeros),
    vec(n, arma::fill::zeros),
    vec(nx, arma::fill::zeros),
    vec(nx, arma::fill::zeros)
  };

  BCSystem bcU = build_scalar_bc_system(M, k, m, dx, n, dy, dcU, ncU, vU);
  BCSystem bcV = build_scalar_bc_system(M, k, m, dx, n, dy, dcV, ncV, vV);

  SparseSolver Au_solver, Av_solver;
  Au_solver.factorize(bcU.A_bc);
  Av_solver.factorize(bcV.A_bc);

  // Pressure Poisson operator boundary conditions
  const std::array<double,4> dcP = {0, 1, 0, 0};
  const std::array<double,4> ncP = {1, 0, 1, 1};
  std::array<vec,4> vP = {
    vec(n, arma::fill::zeros),
    vec(n, arma::fill::zeros),
    vec(nx, arma::fill::zeros),
    vec(nx, arma::fill::zeros)
  };

  BCSystem bcP = build_scalar_bc_system(static_cast<sp_mat>(L), k, m, dx, n, dy, dcP, ncP, vP);
  SparseSolver Ap_solver;
  Ap_solver.factorize(bcP.A_bc);

  const int nSteps = static_cast<int>(std::llround(tspan / dt));
  const int plotEvery = 100;

  // Time integration loop
  for (int step = 1; step <= nSteps; ++step) {
    vec U_faces = static_cast<sp_mat>(I_cf) * U_flat;
    vec V_faces = static_cast<sp_mat>(I_cf) * V_flat;

    vec U_on_u = U_faces.head(Nfaces_x);
    vec U_on_v = U_faces.tail(Nfaces_y);

    vec V_on_u = V_faces.head(Nfaces_x);
    vec V_on_v = V_faces.tail(Nfaces_y);

    vec UU_on_u = U_on_u % U_on_u;
    vec UV_on_u = U_on_u % V_on_u;

    vec VV_on_v = V_on_v % V_on_v;
    vec UV_on_v = U_on_v % V_on_v;

    vec u_div = arma::join_cols(UU_on_u, UV_on_v);
    vec v_div = arma::join_cols(UV_on_u, VV_on_v);

    vec AdvU_n = static_cast<sp_mat>(D) * u_div;
    vec AdvV_n = static_cast<sp_mat>(D) * v_div;

    vec AdvU_ab, AdvV_ab;
    if (step == 1) {
      AdvU_ab = AdvU_n;
      AdvV_ab = AdvV_n;
    } else {
      AdvU_ab = 1.5 * AdvU_n - 0.5 * AdvU_prev;
      AdvV_ab = 1.5 * AdvV_n - 0.5 * AdvV_prev;
    }

    vec rhsU = Mp * U_flat - dt * AdvU_ab;
    vec rhsV = Mp * V_flat - dt * AdvV_ab;

    rhsU.elem(bcU.rowsbc).zeros();
    rhsV.elem(bcV.rowsbc).zeros();
    rhsU += bcU.b0;
    rhsV += bcV.b0;

    vec U_star_flat = Au_solver.solve(rhsU);
    vec V_star_flat = Av_solver.solve(rhsV);

    mat U_star = arma::reshape(U_star_flat, nx, ny);
    mat V_star = arma::reshape(V_star_flat, nx, ny);

    U_star.submat(i1, j1, i2, j2).zeros();
    V_star.submat(i1, j1, i2, j2).zeros();
    U_star(0, 0) = 0.0;      U_star(0, ny - 1) = 0.0;
    V_star(0, 0) = 0.0;      V_star(0, ny - 1) = 0.0;

    U_star_flat = arma::vectorise(U_star);
    V_star_flat = arma::vectorise(V_star);

    vec U_star_faces = static_cast<sp_mat>(I_cf) * U_star_flat;
    vec V_star_faces = static_cast<sp_mat>(I_cf) * V_star_flat;

    vec U_star_on_u = U_star_faces.head(Nfaces_x);
    vec V_star_on_v = V_star_faces.tail(Nfaces_y);

    vec UV_star_div = arma::join_cols(U_star_on_u, V_star_on_v);
    vec RHS = (rho / dt) * (static_cast<sp_mat>(D) * UV_star_div);

    RHS.elem(bcP.rowsbc).zeros();
    RHS += bcP.b0;

    p_new_flat = Ap_solver.solve(RHS);

    vec gradp_faces = static_cast<sp_mat>(G) * p_new_flat;
    vec gradp_x = gradp_faces.head(Nfaces_x);
    vec gradp_y = gradp_faces.tail(Nfaces_y);

    vec u_corr = Sx * gradp_x;
    vec v_corr = Sy * gradp_y;

    vec U_new_flat = U_star_flat - (dt / rho) * u_corr;
    vec V_new_flat = V_star_flat - (dt / rho) * v_corr;

    mat U_new = arma::reshape(U_new_flat, nx, ny);
    mat V_new = arma::reshape(V_new_flat, nx, ny);

    applyVelocityBCAndMask(U_new, V_new, U_init, i1, i2, j1, j2);

    U_flat = arma::vectorise(U_new);
    V_flat = arma::vectorise(V_new);
    AdvU_prev = AdvU_n;
    AdvV_prev = AdvV_n;

    if ((step % plotEvery) == 0 || step == 1 || step == nSteps) {
      const double maxU = arma::abs(U_new).max();
      const double maxV = arma::abs(V_new).max();
      const double umax = maxU;
      const double vmax = maxV;
      const double CFL  = dt * (umax / dx + vmax / dy);
      const double inletMean = arma::mean(U_new.row(0));

      std::cout << "step " << std::setw(6) << step << "/" << std::setw(6) << nSteps
                << " | t=" << std::fixed << std::setprecision(6) << (dt * step)
                << " | CFL~" << std::setprecision(3) << CFL
                << " | max|U|=" << std::scientific << std::setprecision(3) << maxU
                << " | max|V|=" << std::scientific << std::setprecision(3) << maxV
                << " | mean(U_in)=" << std::fixed << std::setprecision(3) << inletMean
                << "\n";
    }
  }

  // Output: save fields and a quick visualization image
  {
    mat U_final = arma::reshape(U_flat, nx, ny);
    mat V_final = arma::reshape(V_flat, nx, ny);
    mat p_final = arma::reshape(p_new_flat, nx, ny);

    U_final.save("U_final.csv", arma::csv_ascii);
    V_final.save("V_final.csv", arma::csv_ascii);
    p_final.save("p_final.csv", arma::csv_ascii);

    mat speed = arma::sqrt(arma::square(U_final) + arma::square(V_final));

    const std::string ppmFile = "speed_final.ppm";
    const std::string pngFile = "speed_final.png";
    write_ppm_grayscale(ppmFile, speed);

#ifdef __APPLE__
    {
      std::string cmd = "sips -s format png " + ppmFile + " --out " + pngFile + " >/dev/null 2>&1";
      int rc = std::system(cmd.c_str());
      if (rc == 0) {
        std::remove(ppmFile.c_str());
      } else {
        std::cerr << "[warn] PNG conversion failed (sips). Kept " << ppmFile << "\n";
      }
    }
#else
    std::cerr << "[warn] PNG conversion uses macOS 'sips'. Kept " << ppmFile << "\n";
#endif

    std::cout << "Wrote U_final.csv, V_final.csv, p_final.csv, speed_final.png\n";
  }

  return 0;
}
