/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file curl2D.h
 *
 * @brief Mimetic 2-D Curl Operator
 *
 * @date 2026/04/26
 */

#ifndef CURL2D_H
#define CURL2D_H

#include "utils.h"
#include <cassert>

/**
 * @brief Mimetic 2-D Curl operator (z-component)
 *
 * Computes curl(U, V) = V_x - U_y as a sparse matrix acting on a stacked
 * face-field vector [U_x_faces; V_y_faces]:
 *
 *   Curl * [U; V]  =  D1*V - D2*U  =  V_x - U_y
 *
 * where D1 and D2 are the x- and y-derivative blocks of the 2-D divergence.
 * The matrix is assembled as [-D2 | D1], the direct matrix equivalent of the
 * MATLAB curl2D operator which computes div2D * [V_faces; -U_faces].
 */
class Curl2D : public sp_mat {
public:
  using sp_mat::operator=;

  /**
   * @brief 2-D Mimetic Curl (non-periodic)
   *
   * Produces a matrix of size (m+2)(n+2) x [n(m+1) + m(n+1)].
   * Apply to a stacked vector [U_x_faces; V_y_faces] to obtain the
   * z-component of the curl at all (m+2)(n+2) grid nodes.
   *
   * @argument k  Order of accuracy
   * @argument m  Number of cells in x-direction
   * @argument n  Number of cells in y-direction
   * @argument dx Spacing between cells in x-direction
   * @argument dy Spacing between cells in y-direction
   */
  Curl2D(u16 k, u32 m, u32 n, Real dx, Real dy);
};

#endif // CURL2D_H
