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

// -------------
//
// flat2DArray member function and operator implementations
//
// -------------

// 
// flat2DArray::flat2DArray constructor
//
flat2DArray::flat2DArray(size_t rows, size_t cols, Real fillVal)
    : rows_(rows), cols_(cols), data_(rows * cols, fillVal){}

//
// flat2DArray::operator() - returns flat2DArray(i,j)
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
        static Real dnan = nan("");
        return dnan;
    }
}

//
// const flat2DArray::operator() - returns flat2DArray(i,j)
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
// flat2DArray::resize class method to resize a falt2DArray
// 
void flat2DArray::resize(size_t rows, size_t cols, Real fillVal) {
    if (rows < 0 || cols < 0){
        // log an error for invalid size for flat2DArray
        string wparams = "#rows = ";
        wparams += to_string(rows) + " , #cols = " + to_string(cols);
        logArr2DErr(MOLE_ERR_INVALID_ARRAY_SIZE, 
                "Flat2DArray Resize", wparams);  
    } 
    else {
        size_t tsize =  static_cast<size_t>(rows) * 
                        static_cast<size_t>(cols);
        // Guard against overflow: rows*cols shouldn't wrap around
        if (cols != 0 && ( tsize / static_cast<size_t>(cols) != 
                            static_cast<size_t>(rows))) {
        // log an error for overflow
        string wparams = "#rows = ";
        wparams += to_string(rows) + " , #cols = " + to_string(cols);
        logArr2DErr(MOLE_ERR_ARRAY_SIZE_OVERFLOW, 
                "Flat2DArray Resize", wparams);   
        }
        else{
            rows_ = rows;
            cols_ = cols;
            data_.assign(rows * cols, fillVal);
        }
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
    // logs an error for invalid row index and returns a NaN
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
