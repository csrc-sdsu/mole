/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/

/*
 * @file gradient.h
 * 
 * @brief Mimetic Gradient Operators
 * 
 * @date 2026/03/16
 * 
 */

#ifndef GRADIENT_H
#define GRADIENT_H

#include "utils.h"
#include <cassert>

/**
 * @brief Mimetic Gradient operator
 *
 * Supports both non-periodic and periodic boundary conditions.
 * The BC-aware constructors accept Robin coefficient vectors dc and nc
 * representing a0 and b0 in the condition a0*U + b0*dU/dn = g.
 * An axis is treated as periodic when all of its dc and nc entries are zero.
 */
class Gradient : public sp_mat {

public:
  using sp_mat::operator=;

  // -----------------------------------------------------------------------
  // Non-periodic constructors
  // -----------------------------------------------------------------------

  /**
   * @brief 1-D Mimetic Gradient (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells
   * @argument dx Spacing between cells
   */
  Gradient(u16 k, u32 m, Real dx);

  /**
   * @brief 2-D Mimetic Gradient (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   */
  Gradient(u16 k, u32 m, u32 n, Real dx, Real dy);

  /**
   * @brief 3-D Mimetic Gradient (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument o  Number of cells in z-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dz Spacing between cells in z-direction
   */
  Gradient(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);

  // -----------------------------------------------------------------------
  // BC-aware constructors (periodic or non-periodic per axis)
  //
  // An axis is treated as periodic when all dc and nc entries for that axis
  // are zero, encoding the Robin boundary condition a0*U + b0*dU/dn = g
  // with a0 = dc and b0 = nc.  All-zero coefficients imply no boundary is
  // prescribed, which corresponds to a periodic (wrap-around) domain.
  // -----------------------------------------------------------------------

  /**
   * @brief 1-D Mimetic Gradient (periodic or non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells
   * @argument dx Spacing between cells
   * @argument dc Robin coefficient a0; 2-element vector [left, right].
   *              All-zero → periodic BC.
   * @argument nc Robin coefficient b0; 2-element vector [left, right].
   *              All-zero → periodic BC.
   *
   * Periodic result is m×m; non-periodic result is (m+1)×(m+2).
   */
  Gradient(u16 k, u32 m, Real dx, const vec& dc, const vec& nc);

  /**
   * @brief 2-D Mimetic Gradient (periodic or non-periodic per axis)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dc Robin coefficient a0; 4-element vector [left, right, bottom, top].
   *              Entries 0-1 all-zero → periodic in x.
   *              Entries 2-3 all-zero → periodic in y.
   * @argument nc Robin coefficient b0; 4-element vector [left, right, bottom, top].
   */
  Gradient(u16 k, u32 m, u32 n, Real dx, Real dy, const vec& dc, const vec& nc);

  /**
   * @brief 3-D Mimetic Gradient (periodic or non-periodic per axis)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument o  Number of cells in z-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dz Spacing between cells in z-direction
   * @argument dc Robin coefficient a0; 6-element vector [left, right, bottom, top, front, back].
   *              Entries 0-1 all-zero → periodic in x.
   *              Entries 2-3 all-zero → periodic in y.
   *              Entries 4-5 all-zero → periodic in z.
   * @argument nc Robin coefficient b0; 6-element vector, same ordering as dc.
   */
  Gradient(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz,
           const vec& dc, const vec& nc);

  /**
   * @brief Returns the weights used in the Mimetic Gradient Operators.
   *
   * @note For informational purposes only; meaningful for non-periodic 1-D
   *       gradients. Returns an empty vector for periodic or multi-D cases.
   */
  vec getP();

private:
  vec P;

  /**
   * Builds a 1-D periodic gradient as an m×m sparse circulant matrix and
   * returns it as sp_mat.  Entry (i, j) equals the stencil value at offset
   * (i - j + m) % m, scaled by 1/dx.
   */
  static sp_mat periodicGrad1D(u16 k, u32 m, Real dx);

  /**
   * Returns true when every entry of dc and nc is zero, indicating that no
   * Robin boundary condition is prescribed for this axis and the domain
   * should be treated as periodic.
   */
  static bool isPeriodic(const vec& dc, const vec& nc);
};

#endif // GRADIENT_H