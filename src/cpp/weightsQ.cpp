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
#include "divergence.h"
#include "weightsQ.h"

WeightsQ::WeightsQ(u16 k, u32 m, Real dx)
{
  Divergence D(k, m, dx);
  std::cout << "D initially:" << std::endl;
  D.print_dense();
  D.shed_row(0);
  D.shed_row(m);
  std::cout << "D after sheding rows:" << std::endl;
  D.print_dense();

  vec b(m+1);
  b.at(0) = -1.0;
  b.at(m) = 1.0;
  std::cout << "b" << std::endl;
  b.print();
   
  sp_mat Dtranspose = D.t();
  std::cout << "D after shedding transpose:" << std::endl;
  Dtranspose.print_dense();
  sp_vec Q = Utils::spsolve_eigen(Dtranspose,b);
  std::cout << "Q" << std::endl;
  Q.print_dense();
}