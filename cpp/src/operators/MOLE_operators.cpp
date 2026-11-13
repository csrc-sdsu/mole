/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research 
 * Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html
 * for details.
 */

/*
 * @file MOLE_operators.cpp
 *
 * @brief MOLE Base class for MD Operators Classes with member 
 * function implementations 
 *
 * @date 2026/10/05
 *
 */
#include "MOLE_operators.h"


// -----------
//
// Error handling methods for MOLE Operators
//
// -----------

//
// mdOperator::logOpErr records errors in the error stack for MD 
// operators.
//
void mdOperator::logOpErr(size_t errCode, string errLoc, 
                              string errParm) {
    // MOLE error codes are stored as int (MOLE_Errors::errCode)
    MOLEerr_log(o_errs, static_cast<int>(errCode), errLoc, errParm);
}

//
// mdOperator::hasOpErrors check whether there are issues or 
// errors with the mdOperator 
//
bool mdOperator::hasOpErrors() const{
    return MOLEerr_haserrors(o_errs);
}

//
// mdOperator::printOpErrors prints the errors logged on the
// mdOperator to standard output
//
void mdOperator::printOpErrors() const {
    MOLEerr_print(o_errs);
}

//
// mdOperator::print_ErrorLog prints out errors with the mdOperator
// to standard output
//
void mdOperator::print_ErrorLog() const {
    MOLEerr_print(o_errs);
}

//
// mdOperator::write_ErrorLog prints out errors with the mdOperator
// to an output file with name starting with MOLEOperatorErrors - the 
// full name of the file also includes a timestamp
//
void mdOperator::write_ErrorLog() {
    string fn = "MOLEOperatorErrors";
    MOLEerr_dumpErrLog(o_errs, fn);
}

//
// mdOperator::copyGridErrs appends the errors logged in a grid to
// the error stack of the mdOperator, preserving their original 
// order. The grid classes (grid1D, grid2D, grid3D) can be passed 
// directly, since they derive from gridBase.
//
void mdOperator::copyGridErrs(const gridBase& grid) {
    grid.addGridErrs2Stack(o_errs);
}

//
// mdOperator::applyDebugMode applies a MOLE debug mode to the
// operator's error stack
//
void mdOperator::applyDebugMode(size_t debug_mode) const {
    MOLEerr_applyDebugMode(o_errs, debug_mode);
}

//
// mdOperator::checkOrder checks whether a MOLE supported order of
// accuracy is requested, else it logs a MOLE error.
//
void mdOperator::checkOrder(u16 k, const string &loc) {
    if (!isValidOrder(k)) {
        logOpErr(MOLE_ERR_OP_INVALID_ORDER, loc,
                 "k = " + to_string(k) +
                 " (Order value must be an even number between [" +
                 to_string(kMinOrder) + ", " + to_string(kMaxOrder) +
                 "])");
    }
}

// -----------
//
// Shared stencils for MOLE Operators
//
// -----------

//
// mdOperator::periodicStencil returns the m weights V of the periodic
// mimetic stencil of order k. The periodic Gradient reads it as
// G(i,j) = V[(i - j + 1) mod m] and the periodic Divergence as
// D(i,j) = -V[(j - i + 1) mod m], so D = -G^T. Entry V[(1 - s) mod m]
// is the weight at offset s = j - i; positive offsets wrap to the end
// of V. Requires m >= 2k, which the operator constructors check
// before calling it. If allocation fails, the error is logged and an
// empty vector is returned.
//
vec mdOperator::periodicStencil(u16 k, size_t m) {
    array1D V(m, 0.0);
    if (V.hasArrayErrors()) {
        drainArrayErrors(V);
        return vec();
    }
    vec &v = V.data_;
    switch (k) {
    case 2:
        // offsets 0 .. -1
        v(1) = 1.0;
        v(2) = -1.0;
        break;
    case 4:
        // offsets +1 .. -2
        v(0) = -1.0 / 24.0;
        v(1) = 9.0 / 8.0;
        v(2) = -9.0 / 8.0;
        v(3) = 1.0 / 24.0;
        break;
    case 6:
        // offsets +2 .. -3; offset +2 wraps to V[m-1]
        v(0) = -25.0 / 384.0;
        v(1) = 75.0 / 64.0;
        v(2) = -75.0 / 64.0;
        v(3) = 25.0 / 384.0;
        v(4) = -3.0 / 640.0;
        v(m - 1) = 3.0 / 640.0;
        break;
    case 8:
        // offsets +3 .. -4; offsets +2, +3 wrap to V[m-1], V[m-2]
        v(0) = -245.0 / 3072.0;
        v(1) = 1225.0 / 1024.0;
        v(2) = -1225.0 / 1024.0;
        v(3) = 245.0 / 3072.0;
        v(4) = -49.0 / 5120.0;
        v(5) = 5.0 / 7168.0;
        v(m - 2) = -5.0 / 7168.0;
        v(m - 1) = 49.0 / 5120.0;
        break;
    default: // unreachable: k is validated by checkOrder() first
        break;
    }
    return v;
}
