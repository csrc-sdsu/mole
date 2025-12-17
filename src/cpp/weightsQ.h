/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/
 
 /*
 * @file weights.h
 * 
 * @brief Mimetic Differences Weights
 * 
 * @date 2025/10/14
 * 
 */

#ifndef WEIGHTSQ_H
#define WEIGHTSQ_H

#include "utils.h"
#include <cassert>

/**
 * @brief Generate Q Weights
 *
 */
class WeightsQ : public sp_vec {

public:
  using sp_vec::operator=;

  /**
   * @brief Q Weights Constructor
   *
   * @param k Order of accuracy
   * @param m Number of cells
   * @param dx Spacing between cells
   */  
  WeightsQ(u16 k, u32 m, Real dx);

};


#endif // WEIGHTSQ_H
