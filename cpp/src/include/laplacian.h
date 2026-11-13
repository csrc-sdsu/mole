/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file laplacian.h
 *
 * @brief Mimetic Laplacian operator built from MOLE 2.0 grids.
 *
 */

#ifndef MOLE_LAPLACIAN_H
#define MOLE_LAPLACIAN_H

#include "MOLE_operators.h"
#include "divergence.h"
#include "gradient.h"

/**
 * @brief Mimetic Laplacian operator for uniform grids.
 *
 * The operator is L = D * G, with D and G the mimetic Divergence and
 * Gradient of order k built from the same grid.
 *
 * Construction checks, in order: the order k, whether the grid has
 * errors (if so, the grid's errors are copied onto the operator error
 * stack and construction stops), the grid topology, and the number of
 * cells along each axis. Errors are logged on the operator error
 * stack. The matrix returned by getMatrix() is the operator L only
 * when hasOpErrors() is false; after any failure it is empty (0 x 0).
 *
 * Usage:
 *   Laplacian L1(k, grid);
 *   if (!L1.hasOpErrors())
 *       L1.getMatrix().print("L");
 *   else
 *       L1.printOpErrors();
 *
 * Matrix sizes match the legacy operators. L is square, with one row
 * and column per grid value. Along each axis:
 *  - non-periodic: m+2 values (m centers plus both boundary points)
 *  - periodic:     m values
 * Multi-dimensional operators order values x fastest, then y, then z.
 *
 * At k = 8 the Divergence is not mimetic, so neither is L.
 */
class Laplacian : public mdOperator {
public:
  /**
   * @brief Declares a Laplacian that has not been built from a grid.
   *
   * Logs MOLE_ERR_OP_NOT_BUILT; assign Laplacian(k, grid) to build it.
   */
  Laplacian();

  /**
   * @brief Mimetic Laplacian from a grid1D, grid2D or grid3D.
   *
   * @param k Order of accuracy (2, 4, 6 or 8).
   * @param g Uniform grid of any dimension.
   */
  Laplacian(u16 k, const gridBase &g);

  /**
   * @brief Mimetic Laplacian from the grid returned by gridBuilder.
   *
   * @param k Order of accuracy (2, 4, 6 or 8).
   * @param g Grid variant (grid1D, grid2D, grid3D or gridNull).
   */
  Laplacian(u16 k, const gridVar &g);

  /// @brief Like Laplacian(k, g), then applies a MOLE debug mode.
  Laplacian(u16 k, const gridBase &g, size_t debug_mode);

  /// @brief Like Laplacian(k, g), then applies a MOLE debug mode.
  Laplacian(u16 k, const gridVar &g, size_t debug_mode);

  /**
   * @brief Read-only access to the operator matrix.
   *
   * Valid only when hasOpErrors() is false; otherwise the matrix is
   * empty (0 x 0).
   */
  const sp_mat &getMatrix() const;

private:
  sp_mat L; // operator matrix

  // Construction checks. Each logs onto the operator error stack.
  void checkTopology(char topology, const string &loc);
  void checkCellCount(u16 k, size_t cells, const string &axis,
                      const string &loc);

  // Builds L = D * G, called after the grid checks pass
  void build(u16 k, const gridBase &g, const string &loc);
};

#endif // MOLE_LAPLACIAN_H
