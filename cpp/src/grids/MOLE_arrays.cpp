/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research 
 * Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html
 * for details.
 */

/*
 * @file MOLE_arrays.cpp
 *
 * @brief MOLE Arrays Classes with member function implementations 
 *
 * @date 2026/07/14
 *
 */
#include "MOLE_arrays.h"

// -----------
//
//  MOLE Arrays Constructors
//
// -----------
//


// array1D::array1D constructor(numelem, fillVal) creates a 1D array
// of Reals of size numelem and fills with fillVal. 
// It also records errors during memory allocation or other vector
// operations.
//
array1D::array1D(size_t numelem, Real fillVal) {
    try {
        data_.set_size(numelem);
        data_.fill(fillVal);
    } catch (std::bad_alloc& e) {
        string wparams = "numelem = " + to_string(numelem);
        logArrayError(MOLE_ERR_FAILED_ARRAY_ALLOC, 
                        "array1D Construction", wparams);
    }
}

//
// array2D::array2D constructor(rows, cols, fillVal) creates a 2D 
// array of Reals of size rows x cols and fills with fillVal. 
// It also records errors during memory allocation or other vector
// operations.
//
array2D::array2D(size_t rows, size_t cols, Real fillVal) {
    try {
        data_.set_size(rows, cols);
        data_.fill(fillVal);
    } catch (std::bad_alloc& e) {
        string wparams = "rows = " + to_string(rows); 
        wparams += ", cols = " + to_string(cols);
        logArrayError(MOLE_ERR_FAILED_ARRAY_ALLOC, 
                        "array2D Construction", wparams);
    }
}

//
// array3D::array3D constructor(dim1, dim2, dim3, fillVal) creates a 3D array
// of Reals of size rows x cols x depth and fills with fillVal. 
// It also records errors during memory allocation or other vector
// operations.
//
array3D::array3D(size_t dim1, size_t dim2, size_t dim3, Real fillVal) {
    try {
        data_.set_size(dim1, dim2, dim3);
        data_.fill(fillVal);
    } catch (std::bad_alloc& e) {
        string wparams = "dim1 = " + to_string(dim1); 
        wparams += ", dim2 = " + to_string(dim2);
        wparams += ", dim3 = " + to_string(dim3);
        logArrayError(MOLE_ERR_FAILED_ARRAY_ALLOC, 
                        "array3D Construction", wparams);
    }
}

// -----------
//
// Error handling methods for MOLE Arrays
//
// -----------

//
// array1D::logArrayErr records errors in the error stack for 1D 
//arrays.
//
void array1D::logArrayError(size_t errCode, string errLoc, 
                              string errParm) const {
    MOLEerr_log(a_errs, errCode, errLoc, errParm);
}

//
// array1D::hasArrayErrors check whether are issues or 
// errors with the flat2Darray 
//
bool array1D::hasArrayErrors() const {
    return MOLEerr_haserrors(a_errs);
}

//
// array1D::print_ErrorLog prints out errors with the array1D
// to standard output
//
void array1D::print_ErrorLog() const {
    MOLEerr_print(a_errs);
}

//
// array1D::write_ErrorLog prints out errors with the array1D
// to an output file with name starting with MOLEArrayErrors - the 
// full name of the file also includes a timestamp
//
void array1D::write_ErrorLog() const {
    MOLEerr_dumpErrLog(a_errs, "MOLEArrayErrors");
}

//
// array2D::logArrayErr records errors in the error stack for 1D 
//arrays.
//
void array2D::logArrayError(size_t errCode, string errLoc, 
                              string errParm) const {
    MOLEerr_log(a_errs, errCode, errLoc, errParm);
}

//
// array2D::hasArrayErrors check whether are issues or 
// errors with the flat2Darray 
//
bool array2D::hasArrayErrors() const {
    return MOLEerr_haserrors(a_errs);
}

//
// array2D::print_ErrorLog prints out errors with the array2D
// to standard output
//
void array2D::print_ErrorLog() const {
    MOLEerr_print(a_errs);
}

//
// array2D::write_ErrorLog prints out errors with the array2D
// to an output file with name starting with MOLEArrayErrors - the 
// full name of the file also includes a timestamp
//
void array2D::write_ErrorLog() const {
    MOLEerr_dumpErrLog(a_errs, "MOLEArrayErrors");
}

//
// array3D::logArrayErr records errors in the error stack for 1D 
//arrays.
//
void array3D::logArrayError(size_t errCode, string errLoc, 
                              string errParm) const {
    MOLEerr_log(a_errs, errCode, errLoc, errParm);
}

//
// array3D::hasArrayErrors check whether are issues or 
// errors with the flat3Darray 
//
bool array3D::hasArrayErrors() const {
    return MOLEerr_haserrors(a_errs);
}

//
// array3D::print_ErrorLog prints out errors with the array3D
// to standard output
//
void array3D::print_ErrorLog() const {
    MOLEerr_print(a_errs);
}

//
// array3D::write_ErrorLog prints out errors with the array3D
// to an output file with name starting with MOLEArrayErrors - the 
// full name of the file also includes a timestamp
//
void array3D::write_ErrorLog() const {
    MOLEerr_dumpErrLog(a_errs, "MOLEArrayErrors");
}

//
// read_ErrorLog methods read the error on top of the stack of an 
// array data structure. Its intent is to propagate the error up to a
// user facing class like grids or operators. Users can also print the
// errors to standard output or write them to a file.
//
void array1D::read_ErrorLog(int ErrorCode, std::string &location, 
                          std::string &arrayName) {
  if (!a_errs.empty()) {
    MOLE_Errors topError = a_errs.top();
    ErrorCode = topError.errCode;
    location = topError.errLocation;
    arrayName = topError.paramError;
    a_errs.pop(); // Remove the top error after reading
  }
}

void array2D::read_ErrorLog(int ErrorCode, std::string &location, 
                          std::string &arrayName) {
  if (!a_errs.empty()) {
    MOLE_Errors topError = a_errs.top();
    ErrorCode = topError.errCode;
    location = topError.errLocation;
    arrayName = topError.paramError;
    a_errs.pop(); // Remove the top error after reading
  }
}

void array3D::read_ErrorLog(int ErrorCode, std::string &location, 
                          std::string &arrayName) {
  if (!a_errs.empty()) {
    MOLE_Errors topError = a_errs.top();
    ErrorCode = topError.errCode;
    location = topError.errLocation;
    arrayName = topError.paramError;
    a_errs.pop(); // Remove the top error after reading
  }
}
// -------------
//
// General MOLE Array functions (for flat dense arrays)
// When wrapping other libraries, these functions will need to be 
// redefined to work with the other library's data structures.
// 1) validate that an array index is valid (i.e., within bounds)
// 2) array equality, two arrays are == if their dimensions and data 
//    are the same
// 3) array inequality, two arrays are != if they are stored at
//    different memory locations
// 4) array resize, resize an array to a new size, discards old
//    memory and allocates new memory (it is not an array reshape).
//
// -------------

//
// 1D: valid_index checks whether the i index is valid
//
bool array1D::valid_index(size_t i) const {
    return i < data_.n_elem;
}

//
// 2D: valid_indeces checks whether the i, j indeces are valid
//
bool array2D::valid_indeces(size_t i, size_t j) const {
    return i < data_.n_rows && j < data_.n_cols;
}

//
// 3D: valid_indeces checks whether the i, j, k indeces are valid
//
bool array3D::valid_indeces(size_t i, size_t j, size_t k) const {
    return i < data_.n_rows && j < data_.n_cols && k < data_.n_slices;
}

//
// Array1D::operator == Array equality comparison (dimensions
// and data content) Not using Armadillo's operator == to provide a 
// general template for other numerical libraries.
//
bool array1D::operator==(const array1D& other) const {
    bool are_equal = true;
    if (data_.n_elem != other.data_.n_elem) {      // compare sizes
        are_equal = false;
    } 
    else if (data_.memptr() != other.data_.memptr()) { // same ptr?
        const double* __restrict c = data_.memptr();  // fast compare 
        const double* __restrict u = other.data_.memptr();
        for (size_t i = 0; i < data_.n_elem; ++i) {
            if (c[i] != u[i]) {
                are_equal = false;
                break;
            }
        }
    } 
    return are_equal;
}

//
// Array1D::operator != comparing if these are different arrays (i.e, 
// are these arrrays two different memory locations)
//
bool array1D::operator!=(const array1D& other) const {
    return  (data_.memptr() != other.data_.memptr());
}

//
// Array2D::operator == Array equality comparison (dimensions
// and data content) Not using Armadillo's operator == to provide a 
// general template for other numerical libraries.
//
bool array2D::operator==(const array2D& other) const {
    bool are_equal = true;
    if (data_.n_rows != other.data_.n_rows || 
        data_.n_cols != other.data_.n_cols) {      // compare sizes
        are_equal = false;
        } 
    else if (data_.memptr() != other.data_.memptr()) { // same ptr?
        const double* __restrict c = data_.memptr();  // fast compare 
        const double* __restrict u = other.data_.memptr();
        for (size_t i = 0; i < data_.n_rows*data_.n_cols; ++i) {
            if (c[i] != u[i]) {
                are_equal = false;
                break;
            }
        }
    } 
    return are_equal;
}

//
// Array2D::operator != comparing if these are different arrays (i.e, 
// are these arrrays two different memory locations or they don't have
// the same shape)
//
bool array2D::operator!=(const array2D& other) const {
    bool are_not_equal = false;
    if (data_.n_rows != other.data_.n_rows || 
        data_.n_cols != other.data_.n_cols) {      // compare sizes
        are_not_equal = true;
        } 
    else if (data_.memptr() != other.data_.memptr()) { // same ptr?
        are_not_equal = true;
    }
    return are_not_equal;
}

//
// Array3D::operator == Array equality comparison (dimensions
// and data content) Not using Armadillo's operator == to provide a 
// general template for other numerical libraries.
//
bool array3D::operator==(const array3D& other) const {
    bool are_equal = true;
    if (data_.n_rows != other.data_.n_rows || 
        data_.n_cols != other.data_.n_cols || 
        data_.n_slices != other.data_.n_slices) {      // compare sizes
        are_equal = false;
        } 
    else if (data_.memptr() != other.data_.memptr()) { // same ptr?
        const double* __restrict c = data_.memptr();  // fast compare 
        const double* __restrict u = other.data_.memptr();
        for (size_t i = 0; 
                i < data_.n_rows*data_.n_cols*data_.n_slices; ++i) {
            if (c[i] != u[i]) {
                are_equal = false;
                break;
            }
        }
    } 
    return are_equal;
}

//
// Array3D::operator != comparing if these are different arrays (i.e, 
// are these arrrays two different memory locations or they don't have
// the same shape)
//
bool array3D::operator!=(const array3D& other) const {
    bool are_not_equal = false;
    if (data_.n_rows != other.data_.n_rows || 
        data_.n_cols != other.data_.n_cols || 
        data_.n_slices != other.data_.n_slices) {      // compare sizes
        are_not_equal = true;
        } 
    else if (data_.memptr() != other.data_.memptr()) { // same ptr?
        are_not_equal = true;
    }
    return are_not_equal;
}

//
// array1D::resize class method to resize a array1D. This method 
// guards this operation against an overflow. If an overflow occurs,
// an error is logged + the array size is set to 0 (the resize is 
// simply rejected) rather than returning the wrong object.
//
void array1D::resize(size_t numelem, Real fillVal) {
    size_t c_size = data_.n_elem;

    try {
        data_.set_size(numelem);
        data_.fill(fillVal);
    } catch (std::bad_alloc& e) {
        string wparams = "original numelem = " + to_string(c_size);
        wparams += ", requested resize = " + to_string(numelem);
        logArrayError(MOLE_ERR_FAILED_ARRAY_RESIZE,
                "array1D Resize", wparams);
        data_.set_size(0);
    }
}

//
// array2D::resize class method to resize a array2D. This method 
// guards this operation against an overflow. If an overflow occurs,
// an error is logged + the array size is set to 0 (the resize is 
// simply rejected) rather than returning the wrong object.
//
void array2D::resize(size_t rows, size_t cols, Real fillVal) {
    size_t c_rows = data_.n_rows;
    size_t c_cols = data_.n_cols;

    try {
        data_.set_size(rows, cols);
        data_.fill(fillVal);
    } catch (std::bad_alloc& e) {
        string wparams = "original rows = " + to_string(c_rows);
        wparams += ", original cols = " + to_string(c_cols);
        wparams += ", requested rows = " + to_string(rows);
        wparams += ", requested cols = " + to_string(cols);
        logArrayError(MOLE_ERR_FAILED_ARRAY_RESIZE,
                "array2D Resize", wparams);
        data_.set_size(0, 0);
    }
}

//
// array3D::resize class method to resize a array3D. This method 
// guards this operation against an overflow. If an overflow occurs,
// an error is logged + the array size is set to 0 (the resize is 
// simply rejected) rather than returning the wrong object.
//
void array3D::resize(size_t rows, size_t cols, size_t slices, 
                    Real fillVal) {
    size_t c_rows = data_.n_rows;
    size_t c_cols = data_.n_cols;
    size_t c_slices = data_.n_slices;
    try {
        data_.set_size(rows, cols, slices);
        data_.fill(fillVal);
    } catch (std::bad_alloc& e) {
        string wparams = "original rows = " + to_string(c_rows);
        wparams += ", original cols = " + to_string(c_cols);
        wparams += ", original slices = " + to_string(c_slices);
        wparams += ", requested rows = " + to_string(rows);
        wparams += ", requested cols = " + to_string(cols);
        wparams += ", requested slices = " + to_string(slices);
        logArrayError(MOLE_ERR_FAILED_ARRAY_RESIZE,
                "array3D Resize", wparams);
        data_.set_size(0, 0, 0);
    }
}
