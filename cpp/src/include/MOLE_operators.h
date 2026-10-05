/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file MOLE_operators.h
 *
 * @brief Mimetic Difference Operators: Gradient, Divergence, 
 * Laplacian and Curl.
 *
 * @date 2026/10/05
 *
 */

#ifndef MOLE_OPERATORS_H
#define MOLE_OPERATORS_H

#include "MOLE_grids.h"

// ----------------------------------------------------------------//
//
//               MOLE OPERATOR BASE CLASS
//
// mdOperator is the base class for all mimetic operators;  Gradient,
// Divergence, Laplacian and Curl. It provides support for error 
// handling and propagation.
// ----------------------------------------------------------------//

class mdOperator{
    protected:
        stack<MOLE_Errors> o_errs; // for error detection+backtracking
    public:
        virtual ~mdOperator() = default;
        void logOpErr(size_t errCode, string errLoc, 
                        string errParm);
        bool hasOpErrors() const;
        void print_ErrorLog() const;
        void write_ErrorLog();
        void copyGridErrs(const gridBase& grid);
  };

#endif // MOLE_OPERATORS_H
