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
#include "gradient.h"
#include "weightsQ.h"

WeightsQ::WeightsQ(u16 k, u32 m, Real dx): sp_vec(m + 1) 
{
  Divergence D(k, m, dx);
  D.shed_row(0);
  D.shed_row(m);

  vec b(m+1);
  b.at(0) = -1.0;
  b.at(m) = 1.0;

  sp_mat Dtranspose = D.t();
  sp_vec Q_prime = Utils::spsolve_eigenQR(Dtranspose, b);
  sp_vec Q(m+2);
  Q.at(0) = 1.0;
  Q.at(m+1) = 1.0;
  for (int i = 1; i < m+1; ++i) {
    Q.at(i) = Q_prime.at(i-1);
  }

  *this = Q;

}

