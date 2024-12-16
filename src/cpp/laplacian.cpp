/*
 * SPDX-License-Identifier: GPL-3.0-only
 * 
 * Copyright 2008-2024 San Diego State University Research Foundation (SDSURF).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * LICENSE file or on the web GNU General Public License 
 * <https:*www.gnu.org/licenses/> for more details.
 *
 */

/*
 * @file laplacian.cpp
 * 
 * @brief Mimetic Laplacian Constructors
 * 
 * @date 2024/10/15
 * 
 */



#include "laplacian.h"

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
