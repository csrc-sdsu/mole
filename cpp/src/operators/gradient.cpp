/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file gradient.cpp
 *
 * @brief Mimetic Gradient operator built from MOLE 2.0 grids.
 *
 */

#include "gradient.h"

#include <new>

// ============================================================================
// Construction checks
// ============================================================================

//
// checkOrder logs an error when k is not one of the supported orders.
//
void Gradient::checkOrder(u16 k, const string &loc) {
  if (k != 2 && k != 4 && k != 6 && k != 8) {
    logOpErr(MOLE_ERR_OP_INVALID_ORDER, loc, "k = " + to_string(k));
  }
}

//
// checkTopology logs an error when the grid is not uniform.
//
void Gradient::checkTopology(char topology, const string &loc) {
  if (topology != 'u') {
    logOpErr(MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY, loc,
             string("topology = '") + topology + "'");
  }
}

//
// checkCellCount logs an error when an axis has fewer than 2k cells,
// which the stencils of order k need.
//
void Gradient::checkCellCount(u16 k, size_t cells, const string &axis,
                              const string &loc) {
  const size_t required = 2 * static_cast<size_t>(k);
  if (cells < required) {
    logOpErr(MOLE_ERR_OP_INSUFFICIENT_CELLS, loc,
             axis + " = " + to_string(cells) + ", requires >= " +
                 to_string(required) + " for k = " + to_string(k));
  }
}

// ============================================================================
// Helpers
// ============================================================================

sp_mat Gradient::trimmedIdentityRows(size_t s) {
  sp_mat I = speye(s + 2, s + 2);
  I.shed_row(0);
  I.shed_row(s); // original last row (s+1) is at index s after the
                 // first shed
  return I;      // s x (s+2)
}

//
// buildGradient selects the periodic or non-periodic form for one
// axis.
//
//   non-periodic: Gaxis is (m+1) x (m+2), Iaxis is the m x (m+2)
//                 trimmed identity.
//   periodic:     Gaxis is m x m, Iaxis is the m x m identity.
//
void Gradient::buildGradient(u16 k, size_t cells, Real h, bool periodic,
                             sp_mat &Gaxis, sp_mat &Iaxis) {
  if (periodic) {
    Gaxis = periodicGrad1D(k, cells, h);
    Iaxis = speye(cells, cells);
  } else {
    Gaxis = nonPeriodicGrad1D(k, cells, h);
    Iaxis = trimmedIdentityRows(cells);
  }
}

// ============================================================================
// 1-D operators
// ============================================================================

//
// nonPeriodicGrad1D builds the (m+1) x (m+2) operator acting on the m
// interior centers plus both boundary points. Requires m >= 2k, which
// the constructors check before calling it. If allocation fails, the
// error is logged and an empty matrix is returned.
//
sp_mat Gradient::nonPeriodicGrad1D(u16 k, size_t m, Real dx) {
  sp_mat Gm;
  try {
    Gm.set_size(m + 1, m + 2);
    switch (k) {
    case 2:
      Gm.at(0, 0) = -8.0 / 3.0;
      Gm.at(0, 1) = 3.0;
      Gm.at(0, 2) = -1.0 / 3.0;
      Gm.at(m, m + 1) = 8.0 / 3.0;
      Gm.at(m, m) = -3.0;
      Gm.at(m, m - 1) = 1.0 / 3.0;
      for (size_t i = 1; i < m; i++) {
        Gm.at(i, i) = -1.0;
        Gm.at(i, i + 1) = 1.0;
      }
      break;
    case 4:
      Gm.at(0, 0) = -352.0 / 105.0;
      Gm.at(0, 1) = 35.0 / 8.0;
      Gm.at(0, 2) = -35.0 / 24.0;
      Gm.at(0, 3) = 21.0 / 40.0;
      Gm.at(0, 4) = -5.0 / 56.0;
      Gm.at(1, 0) = 16.0 / 105.0;
      Gm.at(1, 1) = -31.0 / 24.0;
      Gm.at(1, 2) = 29.0 / 24.0;
      Gm.at(1, 3) = -3.0 / 40.0;
      Gm.at(1, 4) = 1.0 / 168.0;
      Gm.at(m, m + 1) = 352.0 / 105.0;
      Gm.at(m, m) = -35.0 / 8.0;
      Gm.at(m, m - 1) = 35.0 / 24.0;
      Gm.at(m, m - 2) = -21.0 / 40.0;
      Gm.at(m, m - 3) = 5.0 / 56.0;
      Gm.at(m - 1, m + 1) = -16.0 / 105.0;
      Gm.at(m - 1, m) = 31.0 / 24.0;
      Gm.at(m - 1, m - 1) = -29.0 / 24.0;
      Gm.at(m - 1, m - 2) = 3.0 / 40.0;
      Gm.at(m - 1, m - 3) = -1.0 / 168.0;
      for (size_t i = 2; i < m - 1; i++) {
        Gm.at(i, i - 1) = 1.0 / 24.0;
        Gm.at(i, i) = -9.0 / 8.0;
        Gm.at(i, i + 1) = 9.0 / 8.0;
        Gm.at(i, i + 2) = -1.0 / 24.0;
      }
      break;

    case 6:
      Gm.at(0, 0) = -13016.0 / 3465.0;
      Gm.at(0, 1) = 693.0 / 128.0;
      Gm.at(0, 2) = -385.0 / 128.0;
      Gm.at(0, 3) = 693.0 / 320.0;
      Gm.at(0, 4) = -495.0 / 448.0;
      Gm.at(0, 5) = 385.0 / 1152.0;
      Gm.at(0, 6) = -63.0 / 1408.0;
      Gm.at(1, 0) = 496.0 / 3465.0;
      Gm.at(1, 1) = -811.0 / 640.0;
      Gm.at(1, 2) = 449.0 / 384.0;
      Gm.at(1, 3) = -29.0 / 960.0;
      Gm.at(1, 4) = -11.0 / 448.0;
      Gm.at(1, 5) = 13.0 / 1152.0;
      Gm.at(1, 6) = -37.0 / 21120.0;
      Gm.at(2, 0) = -8.0 / 385.0;
      Gm.at(2, 1) = 179.0 / 1920.0;
      Gm.at(2, 2) = -153.0 / 128.0;
      Gm.at(2, 3) = 381.0 / 320.0;
      Gm.at(2, 4) = -101.0 / 1344.0;
      Gm.at(2, 5) = 1.0 / 128.0;
      Gm.at(2, 6) = -3.0 / 7040.0;
      Gm.at(m, m + 1) = 13016.0 / 3465.0;
      Gm.at(m, m) = -693.0 / 128.0;
      Gm.at(m, m - 1) = 385.0 / 128.0;
      Gm.at(m, m - 2) = -693.0 / 320.0;
      Gm.at(m, m - 3) = 495.0 / 448.0;
      Gm.at(m, m - 4) = -385.0 / 1152.0;
      Gm.at(m, m - 5) = 63.0 / 1408.0;
      Gm.at(m - 1, m + 1) = -496.0 / 3465.0;
      Gm.at(m - 1, m) = 811.0 / 640.0;
      Gm.at(m - 1, m - 1) = -449.0 / 384.0;
      Gm.at(m - 1, m - 2) = 29.0 / 960.0;
      Gm.at(m - 1, m - 3) = 11.0 / 448.0;
      Gm.at(m - 1, m - 4) = -13.0 / 1152.0;
      Gm.at(m - 1, m - 5) = 37.0 / 21120.0;
      Gm.at(m - 2, m + 1) = 8.0 / 385.0;
      Gm.at(m - 2, m) = -179.0 / 1920.0;
      Gm.at(m - 2, m - 1) = 153.0 / 128.0;
      Gm.at(m - 2, m - 2) = -381.0 / 320.0;
      Gm.at(m - 2, m - 3) = 101.0 / 1344.0;
      Gm.at(m - 2, m - 4) = -1.0 / 128.0;
      Gm.at(m - 2, m - 5) = 3.0 / 7040.0;
      for (size_t i = 3; i < m - 2; i++) {
        Gm.at(i, i - 2) = -3.0 / 640.0;
        Gm.at(i, i - 1) = 25.0 / 384.0;
        Gm.at(i, i) = -75.0 / 64.0;
        Gm.at(i, i + 1) = 75.0 / 64.0;
        Gm.at(i, i + 2) = -25.0 / 384.0;
        Gm.at(i, i + 3) = 3.0 / 640.0;
      }
      break;

    case 8:
      Gm.at(0, 0) = -4856215.0 / 1200963.0;
      Gm.at(0, 1) = 45858154.0 / 7297397.0;
      Gm.at(0, 2) = -23409299.0 / 4789435.0;
      Gm.at(0, 3) = 3799178.0 / 719717.0;
      Gm.at(0, 4) = -4892189.0 / 1089890.0;
      Gm.at(0, 5) = 1789111.0 / 658879.0;
      Gm.at(0, 6) = -1406819.0 / 1289899.0;
      Gm.at(0, 7) = 1154863.0 / 4436807.0;
      Gm.at(0, 8) = -2936602.0 / 105142673.0;
      Gm.at(1, 0) = 86048.0 / 675675.0;
      Gm.at(1, 1) = -131093.0 / 107520.0;
      Gm.at(1, 2) = 5503131.0 / 5166017.0;
      Gm.at(1, 3) = 305249.0 / 2136437.0;
      Gm.at(1, 4) = -1763845.0 / 8250973.0;
      Gm.at(1, 5) = 1562032.0 / 10745723.0;
      Gm.at(1, 6) = -270419.0 / 4422611.0;
      Gm.at(1, 7) = 2983.0 / 199680.0;
      Gm.at(1, 8) = -2621.0 / 1612800.0;
      Gm.at(2, 0) = -3776.0 / 225225.0;
      Gm.at(2, 1) = 8707.0 / 107520.0;
      Gm.at(2, 2) = -17947.0 / 15360.0;
      Gm.at(2, 3) = 29319.0 / 25600.0;
      Gm.at(2, 4) = -533.0 / 21504.0;
      Gm.at(2, 5) = -263.0 / 9216.0;
      Gm.at(2, 6) = 903.0 / 56320.0;
      Gm.at(2, 7) = -283.0 / 66560.0;
      Gm.at(2, 8) = 257.0 / 537600.0;
      Gm.at(3, 0) = 32.0 / 9009.0;
      Gm.at(3, 1) = -543.0 / 35840.0;
      Gm.at(3, 2) = 265.0 / 3072.0;
      Gm.at(3, 3) = -1233.0 / 1024.0;
      Gm.at(3, 4) = 8625.0 / 7168.0;
      Gm.at(3, 5) = -775.0 / 9216.0;
      Gm.at(3, 6) = 639.0 / 56320.0;
      Gm.at(3, 7) = -15.0 / 13312.0;
      Gm.at(3, 8) = 1.0 / 21504.0;
      Gm.at(m, m + 1) = 4856215.0 / 1200963.0;
      Gm.at(m, m) = -45858154.0 / 7297397.0;
      Gm.at(m, m - 1) = 23409299.0 / 4789435.0;
      Gm.at(m, m - 2) = -3799178.0 / 719717.0;
      Gm.at(m, m - 3) = 4892189.0 / 1089890.0;
      Gm.at(m, m - 4) = -1789111.0 / 658879.0;
      Gm.at(m, m - 5) = 1406819.0 / 1289899.0;
      Gm.at(m, m - 6) = -1154863.0 / 4436807.0;
      Gm.at(m, m - 7) = 2936602.0 / 105142673.0;
      Gm.at(m - 1, m + 1) = -86048.0 / 675675.0;
      Gm.at(m - 1, m) = 131093.0 / 107520.0;
      Gm.at(m - 1, m - 1) = -5503131.0 / 5166017.0;
      Gm.at(m - 1, m - 2) = -305249.0 / 2136437.0;
      Gm.at(m - 1, m - 3) = 1763845.0 / 8250973.0;
      Gm.at(m - 1, m - 4) = -1562032.0 / 10745723.0;
      Gm.at(m - 1, m - 5) = 270419.0 / 4422611.0;
      Gm.at(m - 1, m - 6) = -2983.0 / 199680.0;
      Gm.at(m - 1, m - 7) = 2621.0 / 1612800.0;
      Gm.at(m - 2, m + 1) = 3776.0 / 225225.0;
      Gm.at(m - 2, m) = -8707.0 / 107520.0;
      Gm.at(m - 2, m - 1) = 17947.0 / 15360.0;
      Gm.at(m - 2, m - 2) = -29319.0 / 25600.0;
      Gm.at(m - 2, m - 3) = 533.0 / 21504.0;
      Gm.at(m - 2, m - 4) = 263.0 / 9216.0;
      Gm.at(m - 2, m - 5) = -903.0 / 56320.0;
      Gm.at(m - 2, m - 6) = 283.0 / 66560.0;
      Gm.at(m - 2, m - 7) = -257.0 / 537600.0;
      Gm.at(m - 3, m + 1) = -32.0 / 9009.0;
      Gm.at(m - 3, m) = 543.0 / 35840.0;
      Gm.at(m - 3, m - 1) = -265.0 / 3072.0;
      Gm.at(m - 3, m - 2) = 1233.0 / 1024.0;
      Gm.at(m - 3, m - 3) = -8625.0 / 7168.0;
      Gm.at(m - 3, m - 4) = 775.0 / 9216.0;
      Gm.at(m - 3, m - 5) = -639.0 / 56320.0;
      Gm.at(m - 3, m - 6) = 15.0 / 13312.0;
      Gm.at(m - 3, m - 7) = -1.0 / 21504.0;
      for (size_t i = 4; i < m - 3; i++) {
        Gm.at(i, i - 3) = 5.0 / 7168.0;
        Gm.at(i, i - 2) = -49.0 / 5120.0;
        Gm.at(i, i - 1) = 245.0 / 3072.0;
        Gm.at(i, i) = -1225.0 / 1024.0;
        Gm.at(i, i + 1) = 1225.0 / 1024.0;
        Gm.at(i, i + 2) = -245.0 / 3072.0;
        Gm.at(i, i + 3) = 49.0 / 5120.0;
        Gm.at(i, i + 4) = -5.0 / 7168.0;
      }
      break;
    default: // unreachable: k is validated by checkOrder() first
      break;
    }
    Gm /= dx;
  } catch (std::bad_alloc &e) {
    logOpErr(MOLE_ERR_FAILED_ARRAY_ALLOC, "Gradient::nonPeriodicGrad1D",
             "rows = " + to_string(m + 1) +
                 ", cols = " + to_string(m + 2));
    return sp_mat();
  }
  return Gm;
}

//
// periodicGrad1D builds the m x m circulant operator acting on the m
// interior centers. Row i is the derivative at node i (x = i*dx).
//
// V holds the stencil weights by offset: G(i,j) = V[(i - j + 1) mod m],
// so V[1] multiplies u_i, V[2] multiplies u_(i-1), V[0] multiplies
// u_(i+1), and V[m-1], V[m-2] multiply u_(i+2), u_(i+3). Requires
// m >= 2k, which the constructors check before calling it. If
// allocation fails, the error is logged and an empty matrix is
// returned.
//
sp_mat Gradient::periodicGrad1D(u16 k, size_t m, Real dx) {
  array1D V(m, 0.0);
  if (V.hasArrayErrors()) {
    drainArrayErrors(V);
    return sp_mat();
  }
  vec &v = V.data_;
  switch (k) {
  case 2:
    // second order: (u_i - u_(i-1)) / dx
    v(1) = 1.0;
    v(2) = -1.0;
    break;
  case 4:
    // fourth order: offsets u_(i+1) .. u_(i-2)
    v(0) = -1.0 / 24.0;
    v(1) = 9.0 / 8.0;
    v(2) = -9.0 / 8.0;
    v(3) = 1.0 / 24.0;
    break;
  case 6:
    // sixth order: offsets u_(i+2) .. u_(i-3); u_(i+2) wraps to V[m-1]
    v(0) = -25.0 / 384.0;
    v(1) = 75.0 / 64.0;
    v(2) = -75.0 / 64.0;
    v(3) = 25.0 / 384.0;
    v(4) = -3.0 / 640.0;
    v(m - 1) = 3.0 / 640.0;
    break;
  case 8:
    // eighth order: offsets u_(i+3) .. u_(i-4); u_(i+2), u_(i+3) wrap
    // to V[m-1], V[m-2]
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

  sp_mat Gm;
  try {
    Gm.set_size(m, m);
    for (size_t i = 0; i < m; i++) {
      for (size_t j = 0; j < m; j++) {
        const Real val = v((i + m + 1 - j) % m);
        if (val != 0.0) {
          Gm(i, j) = val;
        }
      }
    }
    Gm /= dx;
  } catch (std::bad_alloc &e) {
    logOpErr(MOLE_ERR_FAILED_ARRAY_ALLOC, "Gradient::periodicGrad1D",
             "rows = " + to_string(m) + ", cols = " + to_string(m));
    return sp_mat();
  }
  return Gm;
}

// ============================================================================
// Constructors
// ============================================================================

//
// Gradient() declares an operator that has not been built from a
// grid. It holds a 0 x 0 matrix and logs MOLE_ERR_OP_NOT_BUILT, so
// hasOpErrors() is true until a built operator is assigned to it.
//
Gradient::Gradient() {
  logOpErr(MOLE_ERR_OP_NOT_BUILT, "Gradient()", "");
}

//
// Gradient(k, gridBase) checks k and the grid's error state, then
// dispatches on the grid dimension. A grid with errors (including a
// gridNull, whose parameters are not usable) stops construction after
// its errors are copied. On any failure the matrix is left empty
// (0 x 0); callers check hasOpErrors() before calling getMatrix().
//
Gradient::Gradient(u16 k, const gridBase &g) {
  const string loc = "Gradient(k, grid)";

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
// Gradient(k, gridVar) forwards the grid held by the variant to the
// gridBase constructor. Every alternative derives from gridBase.
//
Gradient::Gradient(u16 k, const gridVar &g)
    : Gradient(k, std::visit(
                      [](const auto &gr) -> const gridBase & { return gr; },
                      g)) {}

// ============================================================================
// Builders per dimension
// ============================================================================

void Gradient::build1D(u16 k, const gridParams1D &p, const string &loc) {
  checkTopology(p.topology, loc);
  checkCellCount(k, p.m, "m", loc);

  if (hasOpErrors())
    return;

  sp_mat Gx;
  sp_mat Ix;
  buildGradient(k, p.m, p.dx, p.bc_isPeriodic, Gx, Ix);
  if (!hasOpErrors())
    G = Gx;
}

void Gradient::build2D(u16 k, const gridParams2D &p, const string &loc) {
  const bool xPer = p.bc_isPeriodic[0];
  const bool yPer = p.bc_isPeriodic[1];

  checkTopology(p.topology, loc);
  checkCellCount(k, p.m, "m", loc);
  checkCellCount(k, p.n, "n", loc);

  if (hasOpErrors())
    return;

  sp_mat Gx;
  sp_mat Ix;
  sp_mat Gy;
  sp_mat Iy;
  buildGradient(k, p.m, p.dx, xPer, Gx, Ix);
  buildGradient(k, p.n, p.dy, yPer, Gy, Iy);
  if (!hasOpErrors()) {
    // x-component: Gx along x for every y; y-component: Gy along y
    // for every x. Values are ordered with x varying fastest.
    sp_mat G1 = Utils::spkron(o_errs, Iy, Gx);
    sp_mat G2 = Utils::spkron(o_errs, Gy, Ix);
    if (!hasOpErrors())
      G = Utils::spjoin_cols(o_errs, G1, G2);
  }
}

void Gradient::build3D(u16 k, const gridParams3D &p, const string &loc) {
  const bool xPer = p.bc_isPeriodic[0];
  const bool yPer = p.bc_isPeriodic[1];
  const bool zPer = p.bc_isPeriodic[2];

  checkTopology(p.topology, loc);
  checkCellCount(k, p.m, "m", loc);
  checkCellCount(k, p.n, "n", loc);
  checkCellCount(k, p.o, "o", loc);

  if (hasOpErrors())
    return;

  sp_mat Gx;
  sp_mat Ix;
  sp_mat Gy;
  sp_mat Iy;
  sp_mat Gz;
  sp_mat Iz;
  buildGradient(k, p.m, p.dx, xPer, Gx, Ix);
  buildGradient(k, p.n, p.dy, yPer, Gy, Iy);
  buildGradient(k, p.o, p.dz, zPer, Gz, Iz);
  if (!hasOpErrors()) {
    // Components along x, y and z; values ordered x fastest, then
    // y, then z.
    sp_mat G1 = Utils::spkron(o_errs, Utils::spkron(o_errs, Iz, Iy), Gx);
    sp_mat G2 = Utils::spkron(o_errs, Utils::spkron(o_errs, Iz, Gy), Ix);
    sp_mat G3 = Utils::spkron(o_errs, Utils::spkron(o_errs, Gz, Iy), Ix);
    if (!hasOpErrors()) {
      sp_mat G12 = Utils::spjoin_cols(o_errs, G1, G2);
      if (!hasOpErrors())
        G = Utils::spjoin_cols(o_errs, G12, G3);
    }
  }
}

// ============================================================================
// Accessors
// ============================================================================

const sp_mat &Gradient::getMatrix() const { return G; }
