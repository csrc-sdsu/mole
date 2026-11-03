/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file divergence.cpp
 *
 * @brief Mimetic Divergence operator built from MOLE 2.0 grids.
 *
 */

#include "divergence.h"

#include <new>

// ============================================================================
// Construction checks
// ============================================================================

//
// checkOrder logs an error when k is not one of the supported orders.
//
void Divergence::checkOrder(u16 k, const string &loc) {
  if (k != 2 && k != 4 && k != 6 && k != 8) {
    logOpErr(MOLE_ERR_OP_INVALID_ORDER, loc, "k = " + to_string(k));
  }
}

//
// checkTopology logs an error when the grid is not uniform.
//
void Divergence::checkTopology(char topology, const string &loc) {
  if (topology != 'u') {
    logOpErr(MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY, loc,
             string("topology = '") + topology + "'");
  }
}

//
// checkCellCount logs an error when an axis has fewer than 2k+1
// cells, which the divergence stencils of order k need.
//
void Divergence::checkCellCount(u16 k, size_t cells, const string &axis,
                                const string &loc) {
  const size_t required = 2 * static_cast<size_t>(k) + 1;
  if (cells < required) {
    logOpErr(MOLE_ERR_OP_DIV_INSUFFICIENT_CELLS, loc,
             axis + " = " + to_string(cells) + ", requires >= " +
                 to_string(required) + " for k = " + to_string(k));
  }
}

// ============================================================================
// Helpers
// ============================================================================

sp_mat Divergence::trimmedIdentityCols(size_t s) {
  sp_mat I = speye(s + 2, s + 2);
  I.shed_col(0);
  I.shed_col(s); // original last column (s+1) is at index s after the
                 // first shed
  return I;      // (s+2) x s
}

//
// buildDivergence selects the periodic or non-periodic form for one
// axis.
//
//   non-periodic: Daxis is (m+2) x (m+1), Iaxis is the (m+2) x m
//                 trimmed identity.
//   periodic:     Daxis is m x m, Iaxis is the m x m identity.
//
void Divergence::buildDivergence(u16 k, size_t cells, Real h,
                                 bool periodic, sp_mat &Daxis,
                                 sp_mat &Iaxis) {
  if (periodic) {
    Daxis = periodicDiv1D(k, cells, h);
    Iaxis = speye(cells, cells);
  } else {
    Daxis = nonPeriodicDiv1D(k, cells, h);
    Iaxis = trimmedIdentityCols(cells);
  }
}

// ============================================================================
// 1-D operators
// ============================================================================

//
// nonPeriodicDiv1D builds the (m+2) x (m+1) operator mapping the m+1
// faces to the m interior centers plus both boundary points. The first
// and last rows are zero. Requires m >= 2k+1, which the constructors
// check before calling it. If allocation fails, the error is logged
// and an empty matrix is returned.
//
sp_mat Divergence::nonPeriodicDiv1D(u16 k, size_t m, Real dx) {
  sp_mat Dm;
  try {
    Dm.set_size(m + 2, m + 1);
    switch (k) {
    case 2:
      for (size_t i = 1; i < m + 1; i++) {
        Dm.at(i, i - 1) = -1.0;
        Dm.at(i, i) = 1.0;
      }
      break;

    case 4:
      Dm.at(1, 0) = -11.0 / 12.0;
      Dm.at(1, 1) = 17.0 / 24.0;
      Dm.at(1, 2) = 3.0 / 8.0;
      Dm.at(1, 3) = -5.0 / 24.0;
      Dm.at(1, 4) = 1.0 / 24.0;
      Dm.at(m, m) = 11.0 / 12.0;
      Dm.at(m, m - 1) = -17.0 / 24.0;
      Dm.at(m, m - 2) = -3.0 / 8.0;
      Dm.at(m, m - 3) = 5.0 / 24.0;
      Dm.at(m, m - 4) = -1.0 / 24.0;
      for (size_t i = 2; i < m; i++) {
        Dm.at(i, i - 2) = 1.0 / 24.0;
        Dm.at(i, i - 1) = -9.0 / 8.0;
        Dm.at(i, i) = 9.0 / 8.0;
        Dm.at(i, i + 1) = -1.0 / 24.0;
      }
      break;

    case 6:
      Dm.at(1, 0) = -1627.0 / 1920.0;
      Dm.at(1, 1) = 211.0 / 640.0;
      Dm.at(1, 2) = 59.0 / 48.0;
      Dm.at(1, 3) = -235.0 / 192.0;
      Dm.at(1, 4) = 91.0 / 128.0;
      Dm.at(1, 5) = -443.0 / 1920.0;
      Dm.at(1, 6) = 31.0 / 960.0;
      Dm.at(2, 0) = 31.0 / 960.0;
      Dm.at(2, 1) = -687.0 / 640.0;
      Dm.at(2, 2) = 129.0 / 128.0;
      Dm.at(2, 3) = 19.0 / 192.0;
      Dm.at(2, 4) = -3.0 / 32.0;
      Dm.at(2, 5) = 21.0 / 640.0;
      Dm.at(2, 6) = -3.0 / 640.0;
      Dm.at(m, m) = 1627.0 / 1920.0;
      Dm.at(m, m - 1) = -211.0 / 640.0;
      Dm.at(m, m - 2) = -59.0 / 48.0;
      Dm.at(m, m - 3) = 235.0 / 192.0;
      Dm.at(m, m - 4) = -91.0 / 128.0;
      Dm.at(m, m - 5) = 443.0 / 1920.0;
      Dm.at(m, m - 6) = -31.0 / 960.0;
      Dm.at(m - 1, m) = -31.0 / 960.0;
      Dm.at(m - 1, m - 1) = 687.0 / 640.0;
      Dm.at(m - 1, m - 2) = -129.0 / 128.0;
      Dm.at(m - 1, m - 3) = -19.0 / 192.0;
      Dm.at(m - 1, m - 4) = 3.0 / 32.0;
      Dm.at(m - 1, m - 5) = -21.0 / 640.0;
      Dm.at(m - 1, m - 6) = 3.0 / 640.0;
      for (size_t i = 3; i < m - 1; i++) {
        Dm.at(i, i - 3) = -3.0 / 640.0;
        Dm.at(i, i - 2) = 25.0 / 384.0;
        Dm.at(i, i - 1) = -75.0 / 64.0;
        Dm.at(i, i) = 75.0 / 64.0;
        Dm.at(i, i + 1) = -25.0 / 384.0;
        Dm.at(i, i + 2) = 3.0 / 640.0;
      }
      break;

    case 8:
      Dm.at(1, 0) = -1423.0 / 1792.0;
      Dm.at(1, 1) = -491.0 / 7168.0;
      Dm.at(1, 2) = 7753.0 / 3072.0;
      Dm.at(1, 3) = -18509.0 / 5120.0;
      Dm.at(1, 4) = 3535.0 / 1024.0;
      Dm.at(1, 5) = -2279.0 / 1024.0;
      Dm.at(1, 6) = 953.0 / 1024.0;
      Dm.at(1, 7) = -1637.0 / 7168.0;
      Dm.at(1, 8) = 2689.0 / 107520.0;
      Dm.at(2, 0) = 2689.0 / 107520.0;
      Dm.at(2, 1) = -36527.0 / 35840.0;
      Dm.at(2, 2) = 4259.0 / 5120.0;
      Dm.at(2, 3) = 6497.0 / 15360.0;
      Dm.at(2, 4) = -475.0 / 1024.0;
      Dm.at(2, 5) = 1541.0 / 5120.0;
      Dm.at(2, 6) = -639.0 / 5120.0;
      Dm.at(2, 7) = 1087.0 / 35840.0;
      Dm.at(2, 8) = -59.0 / 17920.0;
      Dm.at(3, 0) = -59.0 / 17920.0;
      Dm.at(3, 1) = 1175.0 / 21504.0;
      Dm.at(3, 2) = -1165.0 / 1024.0;
      Dm.at(3, 3) = 1135.0 / 1024.0;
      Dm.at(3, 4) = 25.0 / 3072.0;
      Dm.at(3, 5) = -251.0 / 5120.0;
      Dm.at(3, 6) = 25.0 / 1024.0;
      Dm.at(3, 7) = -45.0 / 7168.0;
      Dm.at(3, 8) = 5.0 / 7168.0;
      Dm.at(m, m) = 1423.0 / 1792.0;
      Dm.at(m, m - 1) = 491.0 / 7168.0;
      Dm.at(m, m - 2) = -7753.0 / 3072.0;
      Dm.at(m, m - 3) = 18509.0 / 5120.0;
      Dm.at(m, m - 4) = -3535.0 / 1024.0;
      Dm.at(m, m - 5) = 2279.0 / 1024.0;
      Dm.at(m, m - 6) = -953.0 / 1024.0;
      Dm.at(m, m - 7) = 1637.0 / 7168.0;
      Dm.at(m, m - 8) = -2689.0 / 107520.0;
      Dm.at(m - 1, m) = -2689.0 / 107520.0;
      Dm.at(m - 1, m - 1) = 36527.0 / 35840.0;
      Dm.at(m - 1, m - 2) = -4259.0 / 5120.0;
      Dm.at(m - 1, m - 3) = -6497.0 / 15360.0;
      Dm.at(m - 1, m - 4) = 475.0 / 1024.0;
      Dm.at(m - 1, m - 5) = -1541.0 / 5120.0;
      Dm.at(m - 1, m - 6) = 639.0 / 5120.0;
      Dm.at(m - 1, m - 7) = -1087.0 / 35840.0;
      Dm.at(m - 1, m - 8) = 59.0 / 17920.0;
      Dm.at(m - 2, m) = 59.0 / 17920.0;
      Dm.at(m - 2, m - 1) = -1175.0 / 21504.0;
      Dm.at(m - 2, m - 2) = 1165.0 / 1024.0;
      Dm.at(m - 2, m - 3) = -1135.0 / 1024.0;
      Dm.at(m - 2, m - 4) = -25.0 / 3072.0;
      Dm.at(m - 2, m - 5) = 251.0 / 5120.0;
      Dm.at(m - 2, m - 6) = -25.0 / 1024.0;
      Dm.at(m - 2, m - 7) = 45.0 / 7168.0;
      Dm.at(m - 2, m - 8) = -5.0 / 7168.0;
      for (size_t i = 4; i < m - 2; i++) {
        Dm.at(i, i - 4) = 5.0 / 7168.0;
        Dm.at(i, i - 3) = -49.0 / 5120.0;
        Dm.at(i, i - 2) = 245.0 / 3072.0;
        Dm.at(i, i - 1) = -1225.0 / 1024.0;
        Dm.at(i, i) = 1225.0 / 1024.0;
        Dm.at(i, i + 1) = -245.0 / 3072.0;
        Dm.at(i, i + 2) = 49.0 / 5120.0;
        Dm.at(i, i + 3) = -5.0 / 7168.0;
      }
      break;
    default: // unreachable: k is validated by checkOrder() first
      break;
    }
    Dm /= dx;
  } catch (std::bad_alloc &e) {
    logOpErr(MOLE_ERR_FAILED_ARRAY_ALLOC, "Divergence::nonPeriodicDiv1D",
             "rows = " + to_string(m + 2) +
                 ", cols = " + to_string(m + 1));
    return sp_mat();
  }
  return Dm;
}

//
// periodicDiv1D builds the m x m circulant operator mapping the m
// faces to the m centers. It is the negative transpose of the periodic
// Gradient: with the Gradient stencil weights V,
//
//   G(i,j) = V[(i - j + 1) mod m]   =>   D(i,j) = -V[(j - i + 1) mod m].
//
// V is the Gradient stencil (kept here as in the legacy code). Requires
// m >= 2k+1, which the constructors check before calling it. If
// allocation fails, the error is logged and an empty matrix is
// returned.
//
sp_mat Divergence::periodicDiv1D(u16 k, size_t m, Real dx) {
  array1D V(m, 0.0);
  if (V.hasArrayErrors()) {
    drainArrayErrors(V);
    return sp_mat();
  }
  vec &v = V.data_;
  switch (k) {
  case 2:
    v(1) = 1.0;
    v(2) = -1.0;
    break;
  case 4:
    v(0) = -1.0 / 24.0;
    v(1) = 9.0 / 8.0;
    v(2) = -9.0 / 8.0;
    v(3) = 1.0 / 24.0;
    break;
  case 6:
    v(0) = -25.0 / 384.0;
    v(1) = 75.0 / 64.0;
    v(2) = -75.0 / 64.0;
    v(3) = 25.0 / 384.0;
    v(4) = -3.0 / 640.0;
    v(m - 1) = 3.0 / 640.0;
    break;
  case 8:
    v(0) = -245.0 / 3072.0;
    v(1) = 1225.0 / 1024.0;
    v(2) = -1225.0 / 1024.0;
    v(3) = 245.0 / 3072.0;
    v(4) = -49.0 / 5120.0;
    v(5) = 5.0 / 7168.0;
    v(m - 2) = -5.0 / 7168.0;
    v(m - 1) = 49.0 / 5120.0;
    break;
  default: // unreachable: k is validated by checkOrder() first
    break;
  }

  sp_mat Dm;
  try {
    Dm.set_size(m, m);
    for (size_t i = 0; i < m; i++) {
      for (size_t j = 0; j < m; j++) {
        const Real val = v((j + m + 1 - i) % m);
        if (val != 0.0) {
          Dm(i, j) = -val;
        }
      }
    }
    Dm /= dx;
  } catch (std::bad_alloc &e) {
    logOpErr(MOLE_ERR_FAILED_ARRAY_ALLOC, "Divergence::periodicDiv1D",
             "rows = " + to_string(m) + ", cols = " + to_string(m));
    return sp_mat();
  }
  return Dm;
}

// ============================================================================
// Constructors
// ============================================================================

//
// Divergence() declares an operator that has not been built from a
// grid. It holds a 0 x 0 matrix and logs MOLE_ERR_OP_NOT_BUILT, so
// hasOpErrors() is true until a built operator is assigned to it.
//
Divergence::Divergence() {
  logOpErr(MOLE_ERR_OP_NOT_BUILT, "Divergence()", "");
}

//
// Divergence(k, gridBase) checks k and the grid's error state, then
// dispatches on the grid dimension. A grid with errors (including a
// gridNull, whose parameters are not usable) stops construction after
// its errors are copied. On any failure the matrix is left empty
// (0 x 0); callers check hasOpErrors() before calling getMatrix().
//
Divergence::Divergence(u16 k, const gridBase &g) {
  const string loc = "Divergence(k, grid)";

  checkOrder(k, loc);
  if (g.hasGridErrors()) {
    copyGridErrs(g);
    logOpErr(MOLE_ERR_OP_GRID_HAS_ERRORS, loc, "");
    return;
  }

  // A grid without errors has dim set to 1, 2 or 3 by its
  // constructor, so dim identifies its concrete type.
  if (g.dim == 1)
    build1D(k, static_cast<const grid1D &>(g).grid, loc);
  else if (g.dim == 2)
    build2D(k, static_cast<const grid2D &>(g).grid, loc);
  else if (g.dim == 3)
    build3D(k, static_cast<const grid3D &>(g).grid, loc);
  else
    logOpErr(MOLE_ERR_INVALID_GRID_DIM, loc,
             "dim = " + to_string(g.dim));
}

//
// Divergence(k, gridVar) forwards the grid held by the variant to the
// gridBase constructor. Every alternative derives from gridBase.
//
Divergence::Divergence(u16 k, const gridVar &g)
    : Divergence(k, std::visit(
                        [](const auto &gr) -> const gridBase & { return gr; },
                        g)) {}

//
// The debug-mode constructors delegate, then apply the mode.
//
Divergence::Divergence(u16 k, const gridBase &g, size_t debug_mode)
    : Divergence(k, g) {
  applyDebugMode(debug_mode);
}

Divergence::Divergence(u16 k, const gridVar &g, size_t debug_mode)
    : Divergence(k, g) {
  applyDebugMode(debug_mode);
}

// ============================================================================
// Builders per dimension
// ============================================================================

void Divergence::build1D(u16 k, const gridParams1D &p, const string &loc) {
  checkTopology(p.topology, loc);
  checkCellCount(k, p.m, "m", loc);

  if (hasOpErrors())
    return;

  sp_mat Dx;
  sp_mat Ix;
  buildDivergence(k, p.m, p.dx, p.bc_isPeriodic, Dx, Ix);
  if (!hasOpErrors())
    D = Dx;
}

void Divergence::build2D(u16 k, const gridParams2D &p, const string &loc) {
  const bool xPer = p.bc_isPeriodic[0];
  const bool yPer = p.bc_isPeriodic[1];

  checkTopology(p.topology, loc);
  checkCellCount(k, p.m, "m", loc);
  checkCellCount(k, p.n, "n", loc);

  if (hasOpErrors())
    return;

  sp_mat Dx;
  sp_mat Ix;
  sp_mat Dy;
  sp_mat Iy;
  buildDivergence(k, p.m, p.dx, xPer, Dx, Ix);
  buildDivergence(k, p.n, p.dy, yPer, Dy, Iy);
  if (!hasOpErrors()) {
    // x-component: Dx along x for every y; y-component: Dy along y
    // for every x. Values are ordered with x varying fastest.
    sp_mat D1 = Utils::spkron(o_errs, Iy, Dx);
    sp_mat D2 = Utils::spkron(o_errs, Dy, Ix);
    if (!hasOpErrors())
      D = Utils::spjoin_rows(o_errs, D1, D2);
  }
}

void Divergence::build3D(u16 k, const gridParams3D &p, const string &loc) {
  const bool xPer = p.bc_isPeriodic[0];
  const bool yPer = p.bc_isPeriodic[1];
  const bool zPer = p.bc_isPeriodic[2];

  checkTopology(p.topology, loc);
  checkCellCount(k, p.m, "m", loc);
  checkCellCount(k, p.n, "n", loc);
  checkCellCount(k, p.o, "o", loc);

  if (hasOpErrors())
    return;

  sp_mat Dx;
  sp_mat Ix;
  sp_mat Dy;
  sp_mat Iy;
  sp_mat Dz;
  sp_mat Iz;
  buildDivergence(k, p.m, p.dx, xPer, Dx, Ix);
  buildDivergence(k, p.n, p.dy, yPer, Dy, Iy);
  buildDivergence(k, p.o, p.dz, zPer, Dz, Iz);
  if (!hasOpErrors()) {
    // Components along x, y and z; values ordered x fastest, then
    // y, then z.
    sp_mat D1 = Utils::spkron(o_errs, Utils::spkron(o_errs, Iz, Iy), Dx);
    sp_mat D2 = Utils::spkron(o_errs, Utils::spkron(o_errs, Iz, Dy), Ix);
    sp_mat D3 = Utils::spkron(o_errs, Utils::spkron(o_errs, Dz, Iy), Ix);
    if (!hasOpErrors()) {
      sp_mat D12 = Utils::spjoin_rows(o_errs, D1, D2);
      if (!hasOpErrors())
        D = Utils::spjoin_rows(o_errs, D12, D3);
    }
  }
}

// ============================================================================
// Accessors
// ============================================================================

const sp_mat &Divergence::getMatrix() const { return D; }
