/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/

/*
 * @file weights.cpp
 * 
 * @brief Mimetic Differences Q Weights
 * 
 * @date 2025/10/14
 * 
 */

#include "utils.h"
#include "weightsQ.h"

WeightsQ::WeightsQ(u16 k, u32 m, Real dx)
{
  at(0) = 1.0;
  at(1) = 1.0;
  at(2) = 1.0;
  at(3) = 1.0;
  at(4) = 1.0;
}