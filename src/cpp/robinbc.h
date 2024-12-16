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
 */
 
/*
 * @file robinbc.cpp
 * @date 2024/10/15
 * @brief Robin Boundary Condition Class
 * 
 */

#ifndef ROBINBC_H
#define ROBINBC_H

#include "gradient.h"

/**
 * @brief Mimetic Robin Boundary Condition operator
 *
 */
class RobinBC : public sp_mat {

public:
  using sp_mat::operator=;

  /**
  * @brief 1-D Robin boundary constructor
  *
  * @param k mimetic order of accuracy
  * @param m number of cells in x-dimension
  * @param dx cell width in x-direction
  * @param a Coefficient of the Dirichlet function
  * @param b Coefficient of the Neumann function
  *
  */
  RobinBC(u16 k, u32 m, Real dx, Real a, Real b);

  /**
  * @brief 2-D Robin boundary constructor
  *
  * @param k mimetic order of accuracy
  * @param m number of cells in x-dimension
  * @param dx cell width in x-direction
  * @param n number of cells in y-dimension
  * @param dy cell width in y-direction
  * @param a Coefficient of the Dirichlet function
  * @param b Coefficient of the Neumann function
  * 
  * @note Uses 1-D Robin to build the 2-D operator
  *
  */
  RobinBC(u16 k, u32 m, Real dx, u32 n, Real dy, Real a, Real b);


  /**
  * @brief 3-D Robin boundary constructor
  *
  * @param k mimetic order of accuracy
  * @param m number of cells in x-dimension
  * @param dx cell width in x-direction
  * @param n number of cells in y-dimension
  * @param dy cell width in y-direction
  * @param o number of cells in z-dimension
  * @param dz cell width in z-direction
  * @param a Coefficient of the Dirichlet function
  * @param b Coefficient of the Neumann function
  *
  * @note Uses 1-D Robin to build the 3-D operator
  */
  RobinBC(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz, Real a,
          Real b);
};

#endif // ROBINBC_H
