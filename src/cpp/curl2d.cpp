/*
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */
/*
 * @file curl2D.cpp
 *
 * @brief Mimetic 2-D Curl Operator
 *
 * @date 2026/04/26
 */

#include "curl2d.h"
#include "divergence.h"

// Returns an (s+2)×s sparse matrix: the (s+2)×(s+2) identity with its
// first and last columns removed, leaving only the s interior columns.
static sp_mat trimmedIdentity_cols(u32 s) {
  sp_mat I = speye(s + 2, s + 2);
  I.shed_col(0);
  I.shed_col(s); // original last col (s+1) is now at index s after first shed
  return I;      // (s+2)×s
}

// ============================================================================
// 2-D Constructor
// ============================================================================

Curl2D::Curl2D(u16 k, u32 m, u32 n, Real dx, Real dy) {
  Divergence Dx(k, m, dx); // (m+2)×(m+1)
  Divergence Dy(k, n, dy); // (n+2)×(n+1)

  sp_mat Im = trimmedIdentity_cols(m); // (m+2)×m
  sp_mat In = trimmedIdentity_cols(n); // (n+2)×n

  // D1 = kron(In, Dx):  (n+2)(m+2) × n(m+1)  —  d/dx block
  // D2 = kron(Dy, Im):  (n+2)(m+2) × (n+1)m  —  d/dy block
  sp_mat D1 = Utils::spkron(In, Dx);
  sp_mat D2 = Utils::spkron(Dy, Im);

  // curl(U, V) = V_x - U_y = D1*V - D2*U = [-D2 | D1] * [U; V]
  *this = Utils::spjoin_rows(-D2, D1);
}
