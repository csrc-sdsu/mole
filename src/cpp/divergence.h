/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/
 
 /*
 * @file divergence.h
 * 
 * @brief Mimetic Divergence Operators
 * 
 * @date 2024/10/15
 * 
 */

#ifndef DIVERGENCE_H
#define DIVERGENCE_H

#include "utils.h"
#include <cassert>

/**
 * @brief Mimetic Divergence operator
 *
 */
class Divergence : public sp_mat {

public:
  using sp_mat::operator=;

  /**
   * @brief 1-D Mimetic Divergence Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells
   * @param dx Spacing between cells
   */  
  Divergence(u16 k, u32 m, Real dx);

  /**
   * @brief 2-D Mimetic Divergence Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param dx Spacing between cells in x-direction
   * @param dy Spacing between cells in y-direction
   */ 
  Divergence(u16 k, u32 m, u32 n, Real dx, Real dy);

  /**
   * @brief 3-D Mimetic Divergence Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells in x-direction
   * @param n Number of cells in y-direction
   * @param o Number of cells in z-direction
   * @param dx Spacing between cells in x-direction
   * @param dy Spacing between cells in y-direction
   * @param dz Spacing between cells in z-direction
   */  
  Divergence(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);
};
  

#endif // DIVERGENCE_H
