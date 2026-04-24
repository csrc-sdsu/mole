/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file laplacian.cpp
 *
 * @brief Mimetic Laplacian Constructors
 *
 * @date 2024/10/15
 * Last Modified: 2026/04/19
 */

#include "laplacian.h"

// ============================================================================
// Non-periodic constructors
// ============================================================================

// 1-D Constructor
Laplacian::Laplacian(u16 k, u32 m, Real dx) {
  Divergence div(k, m, dx);
  Gradient grad(k, m, dx);

  // Dimensions = m+2, m+2
  *this = (sp_mat)div * (sp_mat)grad;
}

// 2-D Constructor
Laplacian::Laplacian(u16 k, u32 m, u32 n, Real dx, Real dy) {
  Divergence div(k, m, n, dx, dy);
  Gradient grad(k, m, n, dx, dy);

  // Dimensions = (m+2)*(n+2), (m+2)*(n+2)
  *this = (sp_mat)div * (sp_mat)grad;
}

// 3-D Constructor
Laplacian::Laplacian(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz) {
  Divergence div(k, m, n, o, dx, dy, dz);
  Gradient grad(k, m, n, o, dx, dy, dz);

  // Dimensions = (m+2)*(n+2)*(o+2), (m+2)*(n+2)*(o+2)
  *this = (sp_mat)div * (sp_mat)grad;
}

// ============================================================================
// BC-aware constructors (periodic or non-periodic per axis)
// ============================================================================

// BC-aware 1-D Constructor
Laplacian::Laplacian(u16 k, u32 m, Real dx, const ivec &dc, const ivec &nc) {
  Divergence div(k, m, dx, dc, nc);
  Gradient grad(k, m, dx, dc, nc);

  *this = (sp_mat)div * (sp_mat)grad;
}

// BC-aware 2-D Constructor
Laplacian::Laplacian(u16 k, u32 m, u32 n, Real dx, Real dy, const ivec &dc,
                     const ivec &nc) {
  Divergence div(k, m, n, dx, dy, dc, nc);
  Gradient grad(k, m, n, dx, dy, dc, nc);

  *this = (sp_mat)div * (sp_mat)grad;
}

// BC-aware 3-D Constructor
Laplacian::Laplacian(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz,
                     const ivec &dc, const ivec &nc) {
  Divergence div(k, m, n, o, dx, dy, dz, dc, nc);
  Gradient grad(k, m, n, o, dx, dy, dz, dc, nc);

  *this = (sp_mat)div * (sp_mat)grad;
}
