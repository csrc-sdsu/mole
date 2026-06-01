/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file curl2d.cpp
 *
 * @brief 2-D Mimetic Curl Operators
 *
 * @date 2026/06/01
 */

#include "curl2d.h"
#include "divergence.h"

// Interior rows of the 1-D divergence, matching Dx = div(...); Dx(2:end-1,:)
// in the MATLAB curl2D. div is (dim+2)x(dim+1); shedding the first and last
// rows leaves the dim x (dim+1) interior derivative.
sp_mat Curl2D::interiorDiv1D(u16 k, u32 dim, Real delta) {
  sp_mat D = Divergence(k, dim, delta);
  D.shed_row(0);
  D.shed_row(dim); // original last row (dim+1) is now at index dim
  return D;
}

Curl2D::Curl2D(u16 k, u32 m, u32 n, Real dx, Real dy) {
  // Interior 1-D derivatives: Dx is m x (m+1), Dy is n x (n+1).
  sp_mat Dx = interiorDiv1D(k, m, dx);
  sp_mat Dy = interiorDiv1D(k, n, dy);

  // Identities sized for the Kronecker assembly.
  sp_mat Imp1 = speye(m + 1, m + 1);
  sp_mat Inp1 = speye(n + 1, n + 1);
  sp_mat Im = speye(m, m);
  sp_mat In = speye(n, n);

  // Component blocks with the same sign pattern as MATLAB curl2D.
  // First component: tangential vertical derivative at horizontal faces.
  sp_mat C1 = Utils::spkron(Dy, Imp1); // n(m+1) x (n+1)(m+1)

  // Second component: tangential horizontal derivative at vertical faces.
  sp_mat C2 = -Utils::spkron(Inp1, Dx); // (n+1)m x (n+1)(m+1)

  // Third component: scalar curl = d(u_y)/dx - d(u_x)/dy at cell centers.
  sp_mat C3a = -Utils::spkron(Dy, Im); // nm x (n+1)m, acts on u_x
  sp_mat C3b = Utils::spkron(In, Dx);  // nm x n(m+1), acts on u_y

  // Column-segment widths: A = u_x faces, B = u_y faces, C = scalar nodes.
  const u32 colsA = (n + 1) * m;
  const u32 colsB = n * (m + 1);
  const u32 colsC = (n + 1) * (m + 1);

  // Row-block heights.
  const u32 rows1 = n * (m + 1);
  const u32 rows2 = (n + 1) * m;
  const u32 rows3 = m * n;

  // Row-block 1: [ 0_A | 0_B | C1 ]
  sp_mat row1 = Utils::spjoin_rows(
      Utils::spjoin_rows(sp_mat(rows1, colsA), sp_mat(rows1, colsB)), C1);

  // Row-block 2: [ 0_A | 0_B | C2 ]
  sp_mat row2 = Utils::spjoin_rows(
      Utils::spjoin_rows(sp_mat(rows2, colsA), sp_mat(rows2, colsB)), C2);

  // Row-block 3: [ C3a | C3b | 0_C ]
  sp_mat row3 = Utils::spjoin_rows(Utils::spjoin_rows(C3a, C3b),
                                   sp_mat(rows3, colsC));

  // Stack the three row-blocks.
  *this = Utils::spjoin_cols(Utils::spjoin_cols(row1, row2), row3);
}
