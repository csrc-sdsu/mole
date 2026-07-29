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

//
// safeArraySize3D computes dim1*dim2*dim3 and returns whether the
// multiplication overflows size_t. Checked as two
// chained multiplications (dim1*dim2, then that result*dim3) so an
// overflow in either step is caught. On overflow, outSize is left at
// 0 and the caller logs a MOLE_ERR_ARRAY_SIZE_OVERFLOW error instead
// of throwing.
//
static bool safeArraySize3D(size_t dim1, size_t dim2, size_t dim3,
                             size_t& outSize) {
    if (dim1 == 0 || dim2 == 0 || dim3 == 0) {
        outSize = 0;
        return true; // any zero dimension is a valid, empty array
    }
    size_t d12 = dim1 * dim2;
    if (d12 / dim1 != dim2) return false; // dim1*dim2 overflowed

    outSize = d12 * dim3;
    if (outSize / d12 != dim3) return false; // *dim3 overflowed

    return true;
}

// -------------
//
// flat3DArray member function and operator implementations
//
// -------------
//

//
// flat3DArray::flat3DArray constructor
//
// This constructor attempts to allocate an array of size dim1 x dim2
// x dim3. It guards from overflow when an array of a size that can't
// be stored in a size_t. Instead of throwing an exception, it logs a
// MOLE error, MOLE_ERR_ARRAY_SIZE_OVERFLOW, and leaves the array 
// empty (dim1()==dim2()==dim3()==0).
//
flat3DArray::flat3DArray(size_t dim1, size_t dim2, size_t dim3,
                          Real fillVal) {
    size_t total = 0;
    if (!safeArraySize3D(dim1, dim2, dim3, total)) {
        string errmsg = "dim1 = " + to_string(dim1);
        errmsg += ", dim2 = " + to_string(dim2);
        errmsg += ", dim3 = " + to_string(dim3);
        logArr3DErr(MOLE_ERR_ARRAY_SIZE_OVERFLOW,
                    "Flat3DArray Construction", errmsg);
        return;
    }
    dim1_ = dim1;
    dim2_ = dim2;
    dim3_ = dim3;
    data_.assign(total, fillVal);
}

//
// flat3DArray::operator() - returns flat3DArray(i,j,k)
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
// flat3DArray::resize class method to resize a flat3DArray
//
// It uses the same safeArraySize3D() to guard overflows, if these
// occur, an error is logged and the resize is rejected, leaving the 
// array unchanged.
//
void flat3DArray::resize(size_t dim1, size_t dim2, size_t dim3, 
    Real fillVal) {
    size_t total = 0;
    if (!safeArraySize3D(dim1, dim2, dim3, total)) {
        string errmsg = "dim1 = " + to_string(dim1);
        errmsg += ", dim2 = " + to_string(dim2);
        errmsg += ", dim3 = " + to_string(dim3);
        logArr3DErr(MOLE_ERR_ARRAY_SIZE_OVERFLOW,
                    "Flat3DArray Resize", errmsg);
        return; // reject the resize; array left as it was
    }
    dim1_ = dim1;
    dim2_ = dim2;
    dim3_ = dim3;
    data_.assign(total, fillVal);
}

//
// has_size checks whether a 3D array has the expected size. When it
// is called after a creation of allocation, it guards from overflows 
// that fail to allocate the array
//
bool flat3DArray::has_size(const size_t edim1, const size_t edim2, 
                            const size_t edim3) const {
    if (dim1() == edim1 && dim2() == edim2 && dim3() == edim3){
        return true;
    } else {
        return false;
    }
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