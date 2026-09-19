/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file divergence.h
 *
 * @brief Mimetic Divergence Operators
 *
 * @date 2024/10/15
 * Last Modified: 2026/03/31
 */

#ifndef DIVERGENCE_H
#define DIVERGENCE_H

#include "utils.h"
#include <cassert>

/**
 * @brief Mimetic Divergence operator
 *
 * Supports both non-periodic and periodic boundary conditions.
 * The BC-aware constructors accept Robin coefficient vectors dc and nc
 * representing a0 and b0 in the condition a0*U + b0*dU/dn = g.
 * An axis is treated as periodic when all of its dc and nc entries are zero.
 * WARNING:
 *    At the 8th order, the weight matrix Q loses positive definiteness, 
 *    so the inner product induced by Q is no longer well-defined. If 
 *    the inner product is not valid, the discrete integration by parts 
 *    identity has no meaning, which breaks the structure that makes 
 *    the divergence mimetic.
 */
class Divergence : public sp_mat {
public:
  using sp_mat::operator=;

  // -----------------------------------------------------------------------
  // Non-periodic constructors
  // -----------------------------------------------------------------------

  /**
   * @brief 1-D Mimetic Divergence (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells
   * @argument dx Spacing between cells
   */
  Divergence(u16 k, u32 m, Real dx);

  /**
   * @brief 2-D Mimetic Divergence (non-periodic)
   *
   *  @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   */
  Divergence(u16 k, u32 m, u32 n, Real dx, Real dy);

  // -----------------------------------------------------------------------
  // 3-D Mimetic Divergence (non-periodic)
  // -----------------------------------------------------------------------
  /**
   * @brief 3-D Mimetic Divergence (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument o  Number of cells in z-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dz Spacing between cells in z-direction
   */
  Divergence(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);

  // -----------------------------------------------------------------------
  // BC-aware constructors (periodic or non-periodic per axis)
  //
  // An axis is treated as periodic when all dc and nc entries for that axis
  // are zero, encoding the Robin boundary condition a0*U + b0*dU/dn = g
  // with a0 = dc and b0 = nc.  All-zero coefficients imply no boundary is
  // prescribed, which corresponds to a periodic (wrap-around) domain.
  // -----------------------------------------------------------------------

  /**
   * @brief 1-D Mimetic Divergence (periodic or non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells
   * @argument dx Spacing between cells
   * @argument dc Robin coefficient a0; 2-element integer vector [left, right].
   *              All-zero → periodic BC.
   * @argument nc Robin coefficient b0; 2-element integer vector [left, right].
   *              All-zero → periodic BC.
   *
   * Periodic result is m×m; non-periodic result is (m+2)×(m+1).
   */
  Divergence(u16 k, u32 m, Real dx, const ivec &dc, const ivec &nc);

  /**
   * @brief 2-D Mimetic Divergence (periodic or non-periodic per axis)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dc Robin coefficient a0; 4-element integer vector [left, right,
   * bottom, top]. Entries 0-1 all-zero → periodic in x. Entries 2-3 all-zero →
   * periodic in y.
   * @argument nc Robin coefficient b0; 4-element integer vector [left, right,
   * bottom, top].
   */
  Divergence(u16 k, u32 m, u32 n, Real dx, Real dy, const ivec &dc,
             const ivec &nc);

  /**
   * @brief 3-D Mimetic Divergence (periodic or non-periodic per axis)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument o  Number of cells in z-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dz Spacing between cells in z-direction
   * @argument dc Robin coefficient a0; 6-element integer vector [left, right,
   * bottom, top, front, back]. Entries 0-1 all-zero → periodic in x. Entries
   * 2-3 all-zero → periodic in y. Entries 4-5 all-zero → periodic in z.
   * @argument nc Robin coefficient b0; 6-element integer vector, same ordering
   * as dc.
   */
  Divergence(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz,
             const ivec &dc, const ivec &nc);

  /**
   * @brief Returns the weights used in the Mimetic Divergence Operators.
   *
   * @note For informational purposes only; meaningful for non-periodic 1-D
   *       divergence operators. Returns an empty vector for periodic or multi-D
   * cases.
   */
  vec getQ();

private:
  vec Q;

  /**
   * Builds a 1-D periodic divergence as an m×m sparse matrix and returns it
   * as sp_mat.  The periodic divergence is the negative transpose of the
   * periodic gradient circulant, so entry (i, j) equals the negated stencil
   * value at offset (j - i + m) % m, scaled by 1/dx.
   */
  static sp_mat periodicDiv1D(u16 k, u32 m, Real dx);

  /**
   * Returns 1 when every entry of dc and nc is zero, indicating that no
   * Robin boundary condition is prescribed for this axis and the domain
   * should be treated as periodic.  Returns 0 otherwise.
   */
  static int isPeriodic(const ivec &dc, const ivec &nc);

  // Populates D_m and I for one axis; selects periodic or non-periodic form.
  static void build_divergence(sp_mat &D_m, sp_mat &I, u16 k, u32 dim,
                               Real delta, int periodic);
};

#endif // DIVERGENCE_H
