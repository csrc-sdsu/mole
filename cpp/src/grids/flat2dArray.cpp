/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file array2d.cpp
 *
 * @brief Flat2DArr Class member function implementations 
 *
 * @date 2026/06/24
 *
 */
#include "MOLE_Errors.h"
#include "flat2dArray.h"

// Error handling for the Flat2DArray class
// gridBase::logGridErr logs errors for all Grid classes 
void Flat2DArray::logArr2DErr(int errCode, string errLoc, 
            string errParm) const {
    MOLEerr_log(errs, errCode, errLoc, errParm);
}

// gridBase::reportErrors prints out all generated errors 
bool Flat2DArray::hasArr2DErrors(){
    return MOLEerr_haserrors(errs);
}

// gridBase::reportErrors prints out all generated errors 
void Flat2DArray::print_ErrorLog(){
    MOLEerr_print(errs);
}

// This method writes the contents of an errorlog stack to a file
void Flat2DArray::write_ErrorLog(){
    MOLEerr_dumpErrLog(errs, "MOLEArr2Errors");
}

// 2D Array functions

// valid_indeces checks whether the i, j indeces are valid
bool valid_indeces(size_t i, size_t j, size_t vrows, size_t vcols){
    return i<vrows && j <vcols;
}

// valid_index checks whether the i, j indeces are valid
bool valid_index(size_t i, size_t vsize){
    return i<vsize;
}

Real& Flat2DArray::operator()(size_t i, size_t j) {
    if (valid_indeces(i, j, rows_, cols_)) {
        return data_[i * cols_ + j];
    }
    else {
    // logs an error for invalid indices and returns a NaN
        string wparams = "indeces: i = ";
        wparams += to_string(i) + ", j = " + to_string(j);
        logArr2DErr(MOLE_ERR_INVALID_ARRAY_INDEX, 
                "Flat2DArray Operation", wparams);
        static Real dnan = nan("");
        return dnan;
    }
}

const Real& Flat2DArray::operator()(size_t i, size_t j) const {
    if (valid_indeces(i, j, rows_, cols_)) {
        return data_[i * cols_ + j];
    }
    else {
    // logs an error for invalid indices and returns a NaN
        string wparams = "indeces: i = ";
        wparams += to_string(i) + ", j = " + to_string(j);
        logArr2DErr(MOLE_ERR_INVALID_ARRAY_INDEX, 
                "Flat2DArray Operation", wparams);
        static const Real dnan = nan("");
        return dnan ;
    }
}

void Flat2DArray::resize(size_t rows, size_t cols, Real fillVal) {
        rows_ = rows;
        cols_ = cols;
        data_.assign(rows * cols, fillVal);
}

// --- Accessing the 2D using Row-wise access: pointer + length ---
Real* Flat2DArray::row(size_t i) {
    assert(i < rows_);
    return data_.data() + i * cols_;
}

const Real* Flat2DArray::row(size_t i) const {
    assert(i < rows_);
    return data_.data() + i * cols_;
}