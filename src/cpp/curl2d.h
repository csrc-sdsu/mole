/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file curl2d.h
 *
 * @brief 2-D Mimetic Curl Operators
 *
 * @date 2024/06/01
 */

#ifndef CURL2D_H
#define CURL2D_H

#include "utils.h"
#include <cassert>

/**
 * @brief 2-D Mimetic Curl operator
 *
 * Non-periodic only, mirroring the MATLAB curl2D reference.
 */
class Curl2D : public sp_mat {
public:
  using sp_mat::operator=;

  /**
   * @brief 2-D Mimetic Curl non-periodic operator
   *
   * Returns the staggered 2-D curl with three output components:
   *   - tangential vertical derivative at horizontal faces
   *   - tangential horizontal derivative at vertical faces
   *   - scalar z-curl at cell centers
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   */
  Curl2D(u16 k, u32 m, u32 n, Real dx, Real dy);

private:
  // Returns the interior rows of the 1-D divergence: rows 2..end-1 of the
  // (dim+2)x(dim+1) operator, leaving a dim x (dim+1) derivative.
  static sp_mat interiorDiv1D(u16 k, u32 dim, Real delta);
};

#endif // CURL2D_H
