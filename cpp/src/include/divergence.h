/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file divergence.h
 *
 * @brief Mimetic Divergence operator built from MOLE 2.0 grids.
 *
 */

#ifndef MOLE_DIVERGENCE_H
#define MOLE_DIVERGENCE_H

#include "MOLE_operators.h"
#include "utils.h"

/**
 * @brief Mimetic Divergence operator for uniform grids.
 *
 * The operator is built from the grid's dimension, per-axis
 * periodicity (bc_isPeriodic), cell counts and spacings, and the
 * order k. The grid's coordinate data is not read or modified.
 *
 * Construction checks, in order: the order k, whether the grid has
 * errors (if so, the grid's errors are copied onto the operator error
 * stack and construction stops), the grid topology, and the number of
 * cells along each axis. Errors are logged on the operator error
 * stack. The matrix returned by getMatrix() is the operator D only
 * when hasOpErrors() is false; after any failure it is empty (0 x 0).
 *
 * Usage:
 *   Divergence D1(k, grid);
 *   if (!D1.hasOpErrors())
 *       D1.getMatrix().print("D");
 *   else
 *       D1.printOpErrors();
 *
 * Matrix sizes match the legacy operators. Along each axis:
 *  - non-periodic: (m+2) x (m+1)
 *  - periodic:     m x m
 * Multi-dimensional operators join the x, y and z components side by
 * side, with values ordered x fastest, then y, then z.
 *
 * At k = 8 the weights Q lose positive definiteness, so D is not mimetic.
 */
class Divergence : public mdOperator {
public:
  /**
   * @brief Declares a Divergence that has not been built from a grid.
   *
   * Logs MOLE_ERR_OP_NOT_BUILT; assign Divergence(k, grid) to build it.
   */
  Divergence();

  /**
   * @brief Mimetic Divergence from a grid1D, grid2D or grid3D.
   *
   * @param k Order of accuracy (2, 4, 6 or 8).
   * @param g Uniform grid of any dimension.
   */
  Divergence(u16 k, const gridBase &g);

  /**
   * @brief Mimetic Divergence from the grid returned by gridBuilder.
   *
   * @param k Order of accuracy (2, 4, 6 or 8).
   * @param g Grid variant (grid1D, grid2D, grid3D or gridNull).
   */
  Divergence(u16 k, const gridVar &g);

  /// @brief Like Divergence(k, g), then applies a MOLE debug mode.
  Divergence(u16 k, const gridBase &g, size_t debug_mode);

  /// @brief Like Divergence(k, g), then applies a MOLE debug mode.
  Divergence(u16 k, const gridVar &g, size_t debug_mode);

  /**
   * @brief Read-only access to the operator matrix.
   *
   * Valid only when hasOpErrors() is false; otherwise the matrix is
   * empty (0 x 0).
   */
  const sp_mat &getMatrix() const;

private:
  sp_mat D; // operator matrix

  // Construction checks. Each logs onto the operator error stack.
  void checkOrder(u16 k, const string &loc);
  void checkTopology(char topology, const string &loc);
  void checkCellCount(u16 k, size_t cells, const string &axis,
                      const string &loc);

  // Builders per dimension, called after the grid checks pass
  void build1D(u16 k, const gridParams1D &p, const string &loc);
  void build2D(u16 k, const gridParams2D &p, const string &loc);
  void build3D(u16 k, const gridParams3D &p, const string &loc);

  // Builds the pieces for one axis:
  //   Daxis : 1-D divergence along the axis
  //   Iaxis : identity used when this axis is transverse to the
  //           component being assembled
  void buildDivergence(u16 k, size_t cells, Real h, bool periodic,
                       sp_mat &Daxis, sp_mat &Iaxis);

  // 1-D operators
  sp_mat nonPeriodicDiv1D(u16 k, size_t m, Real dx);
  sp_mat periodicDiv1D(u16 k, size_t m, Real dx);

  // (s+2) x s identity with its first and last columns removed: maps
  // the s interior centers into s+2 points.
  static sp_mat trimmedIdentityCols(size_t s);
};

#endif // MOLE_DIVERGENCE_H
