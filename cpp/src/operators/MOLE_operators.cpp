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
    MOLEerr_log(o_errs, errCode, errLoc, errParm);
}

//
// mdOperator::hasOpErrors check whether there are issues or 
// errors with the mdOperator 
//
bool mdOperator::hasOpErrors() const{
    return MOLEerr_haserrors(o_errs);
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
