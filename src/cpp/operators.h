/** 
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
 **/

/**
 * @file operators.h
 * 
 * @brief Sparse operation inline definitions for mimetic class constructions
 * @date 2024/10/15
 */

#ifndef OPERATORS_H
#define OPERATORS_H

#include "interpol.h"
#include "laplacian.h"
#include "mixedbc.h"
#include "robinbc.h"

inline sp_mat operator*(const Divergence &div, const Gradient &grad) {
  return (sp_mat)div * (sp_mat)grad;
}

inline sp_mat operator+(const Laplacian &lap, const RobinBC &bc) {
  return (sp_mat)lap + (sp_mat)bc;
}

inline sp_mat operator+(const Laplacian &lap, const MixedBC &bc) {
  return (sp_mat)lap + (sp_mat)bc;
}

inline vec operator*(const Divergence &div, const vec &v) {
  return (sp_mat)div * v;
}

inline vec operator*(const Gradient &grad, const vec &v) {
  return (sp_mat)grad * v;
}

inline vec operator*(const Laplacian &lap, const vec &v) {
  return (sp_mat)lap * v;
}

inline vec operator*(const Interpol &I, const vec &v) { 
  return (sp_mat)I * v; 
}

#endif // OPERATORS_H
