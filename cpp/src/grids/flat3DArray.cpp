/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file flat3DArray.cpp
 *
 * @brief flat3DArr Class member function implementations 
 *
 * @date 2026/07/14
 *
 */
#include "flat3DArray.h"

// -----------
//
// Error handling methods for the flat3DArray class
//
// -----------

//
// Flat3DArray::logArr3DErr records an issue in the error log
// for the flat3DArray class
//
void flat3DArray::logArr3DErr(size_t errCode, string errLoc, 
            string errParm) const {
    MOLEerr_log(a_errs, errCode, errLoc, errParm);
}

//
// flat3DArray::hasArr3DErrors check whether are issues or 
// errors with the flat3Darray 
//
bool flat3DArray::hasArr3DErrors() const {
    return MOLEerr_haserrors(a_errs);
}

//
// flat3DArray::print_ErrorLog prints out errors with the 
// flat3DArray to standard output
//
void flat3DArray::print_ErrorLog() const {
    MOLEerr_print(a_errs);
}

//
// flat3DArray::write_ErrorLog prints out errors with the flat3DArray
// to an output file with name starting with MOLEArr3DErrors - the 
// full name of the file also includes a timestamp
//
void flat3DArray::write_ErrorLog() const {
    MOLEerr_dumpErrLog(a_errs, "MOLEArr3Errors");
}

// -------------
//
// General flat3DArray functions
//
// -------------

//
// valid_indeces3 checks whether the i, j, k indeces are valid
//
static bool valid_indeces3(size_t i, size_t j, size_t k,
                            size_t vd1, size_t vd2, size_t vd3) {
    return i < vd1 && j < vd2 && k < vd3;
}


// -------------
//
// flat3DArray member function and operator implementations
//
// -------------
//

//
// flat2DArray::operator() - returns flat3DArray(i,j,k)
// 
Real& flat3DArray::operator()(size_t i, size_t j, size_t k) {
    if (valid_indeces3(i, j, k, dim1_, dim2_, dim3_)) {
        return data_[(i * dim2_ + j) * dim3_ + k];
    }
    else {
        string wparams = "indeces: i = ";
        wparams += to_string(i);
        wparams += ", j = ";
        wparams += to_string(j);
        wparams += ", k = ";
        wparams += to_string(k);
        logArr3DErr(MOLE_ERR_INVALID_ARRAY_INDEX,
                "Flat3DArray Operation", wparams);
        static thread_local Real dnan;
        dnan = nan("");
        return dnan;
    }
}

//
// const flat3DArray::operator() - returns flat3DArray(i,j,k)
// 
const Real& flat3DArray::operator()(size_t i, size_t j, size_t k)
const {
    if (valid_indeces3(i, j, k, dim1_, dim2_, dim3_)) {
        return data_[(i * dim2_ + j) * dim3_ + k];
    }
    else {
        string wparams = "indeces: i = ";
        wparams += to_string(i);
        wparams += ", j = ";
        wparams += to_string(j);
        wparams += ", k = ";
        wparams += to_string(k);
        logArr3DErr(MOLE_ERR_INVALID_ARRAY_INDEX,
                "Flat3DArray Operation", wparams);
        static const Real dnan = nan("");
        return dnan;
    }
}

//
// flat3DArray::operator== Array equality comparison (dimensions
// and data content)
//
bool flat3DArray::operator==(const flat3DArray& other) const {
    return dim1_ == other.dim1_ && dim2_ == other.dim2_ && 
           dim3_ == other.dim3_ && data_ == other.data_;
}

//
// flat3DArray::operator!= Array address equality comparison (i.e, 
// are these arrrays two different memory locations)
//
bool flat3DArray::operator!=(const flat3DArray& other) const {
    return !(*this == other);
}

//
// flat3DArray::resize class method to resize a falt3DArray
// 
void flat3DArray::resize(size_t dim1, size_t dim2, size_t dim3, 
    Real fillVal) {
    dim1_ = dim1;
    dim2_ = dim2;
    dim3_ = dim3;
    data_.assign(dim1 * dim2 * dim3, fillVal);
}

// Accessing a full i-plane: 
// pointer + length (dim2_ * dim3_ elements)
Real* flat3DArray::plane(size_t i) {
    if (i >= dim1_){
        // logs an error for invalid index and returns nullptr
        string errmsg = "index ( i = " + to_string(i);
        errmsg += " ) is out of bounds (dim1 = " + to_string(dim1_);
        errmsg += " ) ";
        logArr3DErr(MOLE_ERR_ARRAY_INDEX_OUTBOUNDS,
                    "flat3DArray:plane", errmsg );
        return nullptr;
    }
    else {
        return data_.data() + i * dim2_ * dim3_;
    }
}

const Real* flat3DArray::plane(size_t i) const {
    if (i >= dim1_){
        // logs an error for invalid index and returns nullptr
        string errmsg = "index ( i = " + to_string(i);
        errmsg += " ) is out of bounds (dim1 = " + to_string(dim1_);
        errmsg += " ) ";
        logArr3DErr(MOLE_ERR_ARRAY_INDEX_OUTBOUNDS,
                    "flat3DArray:plane", errmsg );
        return nullptr;
    }
    else {
        return data_.data() + i * dim2_ * dim3_;
    }
}

// Accessing a single (i,j) 
// row: pointer + length (dim3_ elements) 
Real* flat3DArray::row(size_t i, size_t j) {
    if (i >= dim1_ || j >= dim2_){
        // logs an error for invalid indices and returns nullptr
        string errmsg = "indeces ( i = " + to_string(i);
        errmsg += ", j = " + to_string(j) + " ) are out of bounds.";
        errmsg += " (dim1 = " + to_string(dim1_) + ", dim2 = ";
        errmsg += to_string(dim2_) + " ) ";
        logArr3DErr(MOLE_ERR_ARRAY_INDEX_OUTBOUNDS,
                    "flat3DArray::row", errmsg );
        return nullptr;
    }
    else {
        return data_.data() + (i * dim2_ + j) * dim3_;
    }

}

const Real* flat3DArray::row(size_t i, size_t j) const {
    if (i >= dim1_ || j >= dim2_){
        // logs an error for invalid indices and returns nullptr
        string errmsg = "indeces ( i = " + to_string(i);
        errmsg += ", j = " + to_string(j) + " ) are out of bounds.";
        errmsg += " (dim1 = " + to_string(dim1_) + ", dim2 = ";
        errmsg += to_string(dim2_) + " ) ";
        logArr3DErr(MOLE_ERR_ARRAY_INDEX_OUTBOUNDS,
                    "flat3DArray::row", errmsg );
        return nullptr;
    }
    else {
        return data_.data() + (i * dim2_ + j) * dim3_;
    }

}