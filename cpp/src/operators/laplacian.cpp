/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file laplacian.cpp
 *
 * @brief Mimetic Laplacian operator built from MOLE 2.0 grids.
 *
 */

#include "laplacian.h"

#include <new>

// ============================================================================
// Construction checks
// ============================================================================

//
// checkTopology logs an error when the grid is not uniform.
//
void Laplacian::checkTopology(char topology, const string &loc) {
  if (topology != 'u') {
    logOpErr(MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY, loc,
             string("topology = '") + topology + "'");
  }
}

//
// checkCellCount logs an error when an axis has fewer than 2k+1
// cells. L = D * G, so it needs the Divergence minimum.
//
void Laplacian::checkCellCount(u16 k, size_t cells, const string &axis,
                               const string &loc) {
  const size_t required = 2 * static_cast<size_t>(k) + 1;
  if (cells < required) {
    logOpErr(MOLE_ERR_OP_LAP_INSUFFICIENT_CELLS, loc,
             axis + " = " + to_string(cells) + ", requires >= " +
                 to_string(required) + " for k = " + to_string(k));
  }
}

// ============================================================================
// Builder
// ============================================================================

//
// build forms L = D * G. The Laplacian has already checked k, the
// grid and the cell counts, so the Divergence and Gradient built here
// can only fail on allocation. Their error stacks cannot be copied
// onto the Laplacian, so a failure in either is logged as an
// allocation error naming that operator.
//
void Laplacian::build(u16 k, const gridBase &g, const string &loc) {
  Divergence D(k, g);
  Gradient G(k, g);
  if (D.hasOpErrors())
    logOpErr(MOLE_ERR_FAILED_ARRAY_ALLOC, loc, "Divergence");
  if (G.hasOpErrors())
    logOpErr(MOLE_ERR_FAILED_ARRAY_ALLOC, loc, "Gradient");
  if (hasOpErrors())
    return;

  try {
    L = D.getMatrix() * G.getMatrix();
  } catch (std::bad_alloc &e) {
    L.reset();
    logOpErr(MOLE_ERR_FAILED_ARRAY_ALLOC, loc,
             "rows = " + to_string(D.getMatrix().n_rows) +
                 ", cols = " + to_string(G.getMatrix().n_cols));
  }
}

// ============================================================================
// Constructors
// ============================================================================

//
// Laplacian() declares an operator that has not been built from a
// grid. It holds a 0 x 0 matrix and logs MOLE_ERR_OP_NOT_BUILT, so
// hasOpErrors() is true until a built operator is assigned to it.
//
Laplacian::Laplacian() {
  logOpErr(MOLE_ERR_OP_NOT_BUILT, "Laplacian()", "");
}

//
// Laplacian(k, gridBase) checks k and the grid's error state, then the
// topology and cell counts for the grid's dimension, and builds L only
// if every check passes. A grid with errors (including a gridNull,
// whose parameters are not usable) stops construction after its errors
// are copied. On any failure the matrix is left empty (0 x 0); callers
// check hasOpErrors() before calling getMatrix().
//
Laplacian::Laplacian(u16 k, const gridBase &g) {
  const string loc = "Laplacian(k, grid)";

  checkOrder(k, loc);
  if (g.hasGridErrors()) {
    copyGridErrs(g);
    logOpErr(MOLE_ERR_OP_GRID_HAS_ERRORS, loc, "");
    return;
  }

  // A grid without errors has dim set to 1, 2 or 3 by its
  // constructor, so dim identifies its concrete type.
  if (g.dim == 1) {
    const gridParams1D &p = static_cast<const grid1D &>(g).grid;
    checkTopology(p.topology, loc);
    checkCellCount(k, p.m, "m", loc);
  } else if (g.dim == 2) {
    const gridParams2D &p = static_cast<const grid2D &>(g).grid;
    checkTopology(p.topology, loc);
    checkCellCount(k, p.m, "m", loc);
    checkCellCount(k, p.n, "n", loc);
  } else if (g.dim == 3) {
    const gridParams3D &p = static_cast<const grid3D &>(g).grid;
    checkTopology(p.topology, loc);
    checkCellCount(k, p.m, "m", loc);
    checkCellCount(k, p.n, "n", loc);
    checkCellCount(k, p.o, "o", loc);
  } else {
    logOpErr(MOLE_ERR_INVALID_GRID_DIM, loc,
             "dim = " + to_string(g.dim));
  }

  if (hasOpErrors())
    return;

  build(k, g, loc);
}

//
// Laplacian(k, gridVar) forwards the grid held by the variant to the
// gridBase constructor. Every alternative derives from gridBase.
//
Laplacian::Laplacian(u16 k, const gridVar &g)
    : Laplacian(k, std::visit(
                       [](const auto &gr) -> const gridBase & { return gr; },
                       g)) {}

//
// The debug-mode constructors delegate, then apply the mode.
//
Laplacian::Laplacian(u16 k, const gridBase &g, size_t debug_mode)
    : Laplacian(k, g) {
  applyDebugMode(debug_mode);
}

Laplacian::Laplacian(u16 k, const gridVar &g, size_t debug_mode)
    : Laplacian(k, g) {
  applyDebugMode(debug_mode);
}

// ============================================================================
// Accessors
// ============================================================================

const sp_mat &Laplacian::getMatrix() const { return L; }
