/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file flat2DArray.cpp
 *
 * @brief flat2DArr Class member function implementations 
 *
 * @date 2026/07/14
 *
 */
#include "flat2DArray.h"

// -----------
//
// Error handling methods for the Flat2DArray class
//
// -----------

//
// Flat2DArray::logGridErr records an issue in the error log
//
void flat2DArray::logArr2DErr(size_t errCode, string errLoc, 
                              string errParm) const {
    MOLEerr_log(a_errs, errCode, errLoc, errParm);
}

//
// flat2DArray::hasArr2DErrors check whether are issues or 
// errors with the flat2Darray 
//
bool flat2DArray::hasArr2DErrors() const {
    return MOLEerr_haserrors(a_errs);
}

//
// flat2DArray::print_ErrorLog prints out errors with the flat2DArray
// to standard output
//
void flat2DArray::print_ErrorLog() const {
    MOLEerr_print(a_errs);
}

//
// flat2DArray::write_ErrorLog prints out errors with the flat2DArray
// to an output file with name starting with MOLEArr2DErrors - the 
// full name of the file also includes a timestamp
//
void flat2DArray::write_ErrorLog() const {
    MOLEerr_dumpErrLog(a_errs, "MOLEArr2DErrors");
}

// -------------
//
// General flat2DArray functions
//
// -------------
//
// valid_indeces checks whether the i, j indeces are valid
//
bool valid_indeces(size_t i, size_t j, size_t vrows, size_t vcols){
    return i<vrows && j <vcols;
}

//
// safeArraySize2D computes rows*cols and reports (via return value)
// whether the multiplication overflows size_t. On overflow, outSize 
// is left at 0 and the caller is expected to log the MOLE error
// MOLE_ERR_ARRAY_SIZE_OVERFLOW.
//
static bool safeArraySize2D(size_t rows, size_t cols, size_t& outSize) {
    if (rows == 0 || cols == 0) {
        outSize = 0;
        return true; // a 0 x N or N x 0 array is valid (just empty)
    }
    outSize = rows * cols;
    // if the multiplication wrapped around, dividing back out won't
    // reproduce the original operand
    return (outSize / rows) == cols;
}

// -------------
//
// flat2DArray member function and operator implementations
//
// -------------

// 
// flat2DArray::flat2DArray constructor
//
// This constructor uses an overflow guard which logs an error
// MOLE_ERR_ARRAY_SIZE_OVERFLOW + leaves the array empty (rows()==0,
// cols()==0) instead of constructing an inconsistent object. It
// does not throw a C++ exception 
//
flat2DArray::flat2DArray(size_t rows, size_t cols, Real fillVal) {
    size_t total = 0;
    if (!safeArraySize2D(rows, cols, total)) {
        string wparams = "#rows = ";
        wparams += to_string(rows) + " , #cols = " + to_string(cols);
        logArr2DErr(MOLE_ERR_ARRAY_SIZE_OVERFLOW,
                "Flat2DArray Construction", wparams);
        return;
    }
    rows_ = rows;
    cols_ = cols;
    data_.assign(total, fillVal);
}

//
// flat2DArray::operator() - returns flat2DArray(i,j) if i & j are 
// within the row and column bounds, else returns a nan
//
Real& flat2DArray::operator()(size_t i, size_t j) {
    if (valid_indeces(i, j, rows_, cols_)) {
        return data_[i * cols_ + j];
    }
    else {
    // logs an error for invalid indices and returns a NaN
        string wparams = "indeces: i = ";
        wparams += to_string(i) + ", j = " + to_string(j);
        logArr2DErr(MOLE_ERR_INVALID_ARRAY_INDEX, 
                "Flat2DArray Operation", wparams);
        static thread_local Real dnan;
        dnan = nan("");
        return dnan;
    }
}

//
// const flat2DArray::operator() - returns flat2DArray(i,j) if i & j 
// are within the row and column bounds, else returns a nan
// 
const Real& flat2DArray::operator()(size_t i, size_t j) const {
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

//
// flat2DArray::operator== Array equality comparison (dimensions
// and data content)
//
bool flat2DArray::operator==(const flat2DArray& other) const {
    return rows_ == other.rows_ && cols_ == other.cols_ && 
           data_ == other.data_;
}

//
// flat2DArray::operator!= Array address equality comparison (i.e, 
// are these arrrays two different memory locations)
//
bool flat2DArray::operator!=(const flat2DArray& other) const {
    return !(*this == other);
}

//
// flat2DArray::resize class method to resize a flat2DArray
//
// This methods guards this operation against an overflow. If an 
// overflow occurs, an error is logged + the array is left UNCHANGED
// (the resize is simply rejected) rather than throwing or producing 
// a mismatched rows_/cols_ vs. data_ state.
//
void flat2DArray::resize(size_t rows, size_t cols, Real fillVal) {
    size_t total = 0;
    if (!safeArraySize2D(rows, cols, total)) {
        string wparams = "#rows = ";
        wparams += to_string(rows) + " , #cols = " + to_string(cols);
        logArr2DErr(MOLE_ERR_ARRAY_SIZE_OVERFLOW,
                "Flat2DArray Resize", wparams);
        return; // reject the resize; array left as it was
    }
    rows_ = rows;
    cols_ = cols;
    data_.assign(total, fillVal);
}
//
// has_size checks whether a 2D array has the expected size. When it
// is called after a creation of allocation, it guards from overflows
// that fail to allocate the array
//
bool flat2DArray::has_size(const size_t e_rows, const size_t e_cols){
    if (rows() == e_rows && cols() == e_cols){
        return true;
    } else {
        return false;
    }
}

//
// Accessing a flat2DArray using Row-wise access: pointer + length
//
Real* flat2DArray::row(size_t i) {
    if (i < rows_){
        return data_.data() + i * cols_;
    } 
    else {
    // logs an error for invalid row index and returns a nullptr
        string wparams = "row index: i = ";
        wparams += to_string(i) + " >= " + to_string(rows_) + "rows";
        logArr2DErr(MOLE_ERR_INVALID_ARRAY_INDEX, 
                "Flat2DArray Operation", wparams);
        return nullptr;
    }  
}

//
// const flat2DArray::row - Row-wise access: pointer + length
//
const Real* flat2DArray::row(size_t i) const {
    if (i < rows_){
        return data_.data() + i * cols_;
    } 
    else {
    // logs an error for invalid row index and returns a NaN
        string wparams = "row index: i = ";
        wparams += to_string(i) + " >= " + to_string(rows_) + "rows";
        logArr2DErr(MOLE_ERR_INVALID_ARRAY_INDEX, 
                "Flat2DArray Operation", wparams);
        return nullptr;
    }  
}
