/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file gradient.h
 *
 * @brief Mimetic Gradient operator built from MOLE 2.0 grids.
 *
 */

#ifndef MOLE_GRADIENT_H
#define MOLE_GRADIENT_H

#include "MOLE_operators.h"
#include "utils.h"

/**
 * @brief Mimetic Gradient operator for uniform grids.
 *
 * The operator is built from the grid's dimension, per-axis
 * periodicity (bc_isPeriodic), cell counts and spacings, and the
 * order k. The grid's coordinate data is not read or modified.
 *
 * Construction checks, in order: the order k, whether the grid has
 * errors (if so, the grid's errors are copied onto the operator error
 * stack and construction stops), the grid topology, and the number of
 * cells along each axis. Errors are logged on the operator error
 * stack. The matrix returned by getMatrix() is the operator G only
 * when hasOpErrors() is false; after any failure it is empty (0 x 0).
 *
 * Usage:
 *   Gradient G1(k, grid);
 *   if (!G1.hasOpErrors())
 *       G1.getMatrix().print("G");
 *   else
 *       G1.printOpErrors();
 *
 * Matrix sizes match the legacy operators. Along each axis:
 *  - non-periodic: (m+1) x (m+2)
 *  - periodic:     m x m
 * Multi-dimensional operators stack the x, y and z components, with
 * values ordered x fastest, then y, then z.
 */
class Gradient : public mdOperator {
public:
  /**
   * @brief Declares a Gradient that has not been built from a grid.
   *
   * Logs MOLE_ERR_OP_NOT_BUILT; assign Gradient(k, grid) to build it.
   */
  Gradient();

  /**
   * @brief Mimetic Gradient from a grid1D, grid2D or grid3D.
   *
   * @param k Order of accuracy (2, 4, 6 or 8).
   * @param g Uniform grid of any dimension.
   */
  Gradient(u16 k, const gridBase &g);

  /**
   * @brief Mimetic Gradient from the grid returned by gridBuilder.
   *
   * @param k Order of accuracy (2, 4, 6 or 8).
   * @param g Grid variant (grid1D, grid2D, grid3D or gridNull).
   */
  Gradient(u16 k, const gridVar &g);

  /**
   * @brief Read-only access to the operator matrix.
   *
   * Valid only when hasOpErrors() is false; otherwise the matrix is
   * empty (0 x 0).
   */
  const sp_mat &getMatrix() const;

private:
  sp_mat G; // operator matrix

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
  //   Gaxis : 1-D gradient along the axis
  //   Iaxis : identity used when this axis is transverse to the
  //           component being assembled
  void buildGradient(u16 k, size_t cells, Real h, bool periodic,
                     sp_mat &Gaxis, sp_mat &Iaxis);

  // 1-D operators
  sp_mat nonPeriodicGrad1D(u16 k, size_t m, Real dx);
  sp_mat periodicGrad1D(u16 k, size_t m, Real dx);

  // s x (s+2) identity with its first and last rows removed: keeps
  // the s interior centers out of s+2 points.
  static sp_mat trimmedIdentityRows(size_t s);
};

#endif // MOLE_GRADIENT_H
