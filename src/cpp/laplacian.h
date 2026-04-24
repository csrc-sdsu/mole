/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file laplacian.h
 *
 * @brief Mimetic Laplacian Class and Constructors
 *
 * @date 2024/10/15
 * Last Modified: 2026/04/19
 */

#ifndef LAPLACIAN_H
#define LAPLACIAN_H

#include "divergence.h"
#include "gradient.h"

/**
 * @brief Mimetic Laplacian operator
 *
 * Supports both non-periodic and periodic boundary conditions.
 * The BC-aware constructors accept Robin coefficient vectors dc and nc
 * representing a0 and b0 in the condition a0*U + b0*dU/dn = g.
 * An axis is treated as periodic when all of its dc and nc entries are zero.
 */
class Laplacian : public sp_mat {

public:
  using sp_mat::operator=;

  // -----------------------------------------------------------------------
  // Non-periodic constructors
  // -----------------------------------------------------------------------

  /**
   * @brief 1-D Mimetic Laplacian (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells
   * @argument dx Spacing between cells
   */
  Laplacian(u16 k, u32 m, Real dx);

  /**
   * @brief 2-D Mimetic Laplacian (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   */
  Laplacian(u16 k, u32 m, u32 n, Real dx, Real dy);

  /**
   * @brief 3-D Mimetic Laplacian (non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument o  Number of cells in z-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dz Spacing between cells in z-direction
   */
  Laplacian(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);

  // -----------------------------------------------------------------------
  // BC-aware constructors (periodic or non-periodic per axis)
  //
  // An axis is treated as periodic when all dc and nc entries for that axis
  // are zero, encoding the Robin boundary condition a0*U + b0*dU/dn = g
  // with a0 = dc and b0 = nc.  All-zero coefficients imply no boundary is
  // prescribed, which corresponds to a periodic (wrap-around) domain.
  // -----------------------------------------------------------------------

  /**
   * @brief 1-D Mimetic Laplacian (periodic or non-periodic)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells
   * @argument dx Spacing between cells
   * @argument dc Robin coefficient a0; 2-element integer vector [left, right].
   *              All-zero → periodic BC.
   * @argument nc Robin coefficient b0; 2-element integer vector [left, right].
   *              All-zero → periodic BC.
   *
   * Periodic result is m×m; non-periodic result is (m+2)×(m+2).
   */
  Laplacian(u16 k, u32 m, Real dx, const ivec &dc, const ivec &nc);

  /**
   * @brief 2-D Mimetic Laplacian (periodic or non-periodic per axis)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dc Robin coefficient a0; 4-element integer vector
   *              [left, right, bottom, top].
   *              Entries 0-1 all-zero → periodic in x.
   *              Entries 2-3 all-zero → periodic in y.
   * @argument nc Robin coefficient b0; 4-element integer vector
   *              [left, right, bottom, top].
   */
  Laplacian(u16 k, u32 m, u32 n, Real dx, Real dy, const ivec &dc,
            const ivec &nc);

  /**
   * @brief 3-D Mimetic Laplacian (periodic or non-periodic per axis)
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument o  Number of cells in z-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   * @argument dz Spacing between cells in z-direction
   * @argument dc Robin coefficient a0; 6-element integer vector [left, right,
   *              bottom, top, front, back].
   *              Entries 0-1 all-zero → periodic in x.
   *              Entries 2-3 all-zero → periodic in y.
   *              Entries 4-5 all-zero → periodic in z.
   * @argument nc Robin coefficient b0; 6-element integer vector, same ordering
   *              as dc.
   */
  Laplacian(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz,
            const ivec &dc, const ivec &nc);
};

#endif // LAPLACIAN_H
