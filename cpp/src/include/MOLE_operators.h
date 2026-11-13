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
//               ORDER OF ACCURACY
//
// ----------------------------------------------------------------//

// Currently MOLE supports an even number for the order of
// accuracy k = 2, 4, 6, and 8. The function isValidOrder
// will need a revision whenever more orders of accuracy
// are implemented in MOLE.
constexpr int kMinOrder = 2;
constexpr int kMaxOrder = 8;
constexpr bool isValidOrder(int k) {
    return k >= kMinOrder && k <= kMaxOrder && k % 2 == 0;
}

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

        //
        // drainArrayErrors moves the errors logged on a MOLE array
        // (array1D, array2D, array3D) used inside an operator onto
        // the operator's error stack. The array's own error stack is
        // left empty.
        //
        template <typename ArrayT>
        void drainArrayErrors(ArrayT& a) {
            while (a.hasArrayErrors()) {
                int errCode;
                string location, msgparam;
                a.read_ErrorLog(errCode, location, msgparam);
                logOpErr(errCode, location, msgparam);
            }
        }

        // applies a MOLE debug mode to an operator with errors
        void applyDebugMode(size_t debug_mode) const;

        // logs an error when k is not a supported order of accuracy
        void checkOrder(u16 k, const string &loc);

        // periodic stencil weights V of order k on m cells, shared
        // by the periodic Gradient and Divergence
        vec periodicStencil(u16 k, size_t m);
    public:
        virtual ~mdOperator() = default;
        void logOpErr(size_t errCode, string errLoc, 
                        string errParm);
        bool hasOpErrors() const;
        void printOpErrors() const;
        void print_ErrorLog() const;
        void write_ErrorLog();
        void copyGridErrs(const gridBase& grid);
  };

#endif // MOLE_OPERATORS_H
