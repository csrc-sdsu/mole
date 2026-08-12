/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file MOLE_arrays.h
 *
 * @brief These classes define flat arrays for the MOLE library.
 * These flat C++ arrays/vectors to optimize memory access, instead 
 * of using nested c++ vectors (e.g., std::vector<std:vector<Real>>) 
 * To preserve compatibility with exising MOLE code, the flat arrays
 * are designed to wrapped around the Armadillo library, which is 
 * used for some sparse and dense linear algebra operations. These
 * interfaces should be extended in the future to work with other
 * numerical libraries, such as PETSc (PETSc vectors and matrices),
 * and libraries in the Trilinos project (Tpetra, Epetra, etc.).
 *
 * @date 2026/07/14
 *
 */

#ifndef MOLE_ARRAYS_H
#define MOLE_ARRAYS_H

#include <type_traits>
#include <limits>
#include <cmath>
#include <armadillo>
#include "MOLE_errors.h"

using Real = double;

// array1D is a class designed to be compatible with other MOLE flat 
// arrays and previous versions of MOLE that use Armadillo's vectors.
// The class also records errors during memory allocation or other
// vector operations.
class array1D {
protected:
    mutable stack<MOLE_Errors> a_errs; // err detection+backtracking
public:
    arma::vec data_; // flat array of doubles
    array1D() = default; // default constructor (empty array)
    // constructor for syntax array1D A(numelem, fillval)
    array1D(size_t numelem, Real fillVal = 0.0);
    // Array equality comparison (checks data + dimensions)
    bool operator==(const array1D& other) const;
    // Array inequality (stored at different memory locations)
    bool operator!=(const array1D& other) const;
    // Checks whether an index is valid for this array
    bool valid_index(size_t i) const;
    // resize a 1D array + check successful mem reallocation
    void resize(size_t numelem, Real fillVal = 0.0);
    // error handling methods
    void logArrayError(size_t errCode, string errLoc, 
                     string errParm) const;
    bool hasArrayErrors() const;
    void print_ErrorLog() const;
    void write_ErrorLog() const;
    void read_ErrorLog(int ErrorCode, std::string &location, 
                      std::string &arrayName);
};

// array2D is a class designed to perform better than the 2D nested
// vectors in C++, which stores everything by rows of elements. These
// flat array implementations uses a memory heap to store all the 
// elements of the two dimensional array. It also records errors
// during memory allocation. It also records errors during memory
// allocation or other vector operations. It is compatible with 
// Armadillo's 2D matrix class (mat).

class array2D {
protected:
    mutable stack<MOLE_Errors> a_errs; // err detection+backtracking
public:
    arma::mat data_; // flat array of doubles
    array2D() = default; // default constructor (empty array)
    // constructor for syntax array2D A(rows, cols, fillval)
    array2D(size_t rows, size_t cols, Real fillVal = 0.0);
    // Array equality comparison (checks data + dimensions)
    bool operator==(const array2D& other) const;
    // Array inequality (stored at different memory locations)
    bool operator!=(const array2D& other) const;
    // Checks whether a pair of indeces are valid for this array
    bool valid_indeces(size_t i, size_t j) const;
    // resize a 2D array + check successful mem reallocation
    void resize(size_t rows, size_t cols, Real fillVal = 0.0);
    void logArrayError(size_t errCode, string errLoc, 
                     string errParm) const;
    bool hasArrayErrors() const;
    void print_ErrorLog() const;
    void write_ErrorLog() const;
    void read_ErrorLog(int ErrorCode, std::string &location, 
                      std::string &arrayName);
};

// array3D is a class designed to perform better than the 3D nested
// vectors in C++, which stores everything by rows of elements. These
// flat array implementations uses a memory heap to store all the 
// elements of the three dimensional array. It also records errors
// during memory allocation. It also records errors during memory
// allocation or other vector operations. It is compatible with 
// Armadillo's 3D matrix class (cube).
class array3D {
protected:
    mutable stack<MOLE_Errors> a_errs; // err detection+backtracking
public:
    arma::cube data_; // flat array of doubles
    array3D() = default; // default constructor (empty array)
    // constructor for syntax array3D A(dim1, dim2, dim3, fillval)
    array3D(size_t dim1, size_t dim2, size_t dim3, Real fillVal = 0.0);
    bool operator==(const array3D& other) const;
    // Array inequality (stored at different memory locations)
    bool operator!=(const array3D& other) const;
    // Checks whether a triplet of indeces are valid for this array
    bool valid_indeces(size_t i, size_t j, size_t k) const;
    // resize a 3D array + check successful mem reallocation
    void resize(size_t dim1, size_t dim2, size_t dim3, 
                Real fillVal = 0.0);
    void logArrayError(size_t errCode, string errLoc, 
                     string errParm) const;
    bool hasArrayErrors() const;
    void print_ErrorLog() const;
    void write_ErrorLog() const;
    void read_ErrorLog(int ErrorCode, std::string &location, 
                      std::string &arrayName);
};

//
// This function checks whether two arrays are numerically equal 
// within a specified numerical tolerance. It is a template function 
// that works for array1D, array2D, and array3D types.  The function
// compares the number of elements and then checks if the absolute
// difference between corresponding elements is less than a tolFactor
// times the machine epsilon for double precision.
// This is useful when validating numerical results that may have
// small floating-point differences due to computation.
//
template <typename ArrayType>

bool numEqualArray(const ArrayType& a1, const ArrayType& a2,
                    double tolFactor) { 
    // the array type is checked at compile time only
    static_assert(std::is_same_v<ArrayType, array1D> ||    
                  std::is_same_v<ArrayType, array2D> ||
                  std::is_same_v<ArrayType, array3D>,
                  "numEqualArray only supports array1D, array2D, or array3D");

    // checking elements and abs|a1(i)-a2(i)| < eps*tolFactor
    if (a1.data_.n_elem != a2.data_.n_elem) return false;

    const double eps = std::numeric_limits<double>::epsilon();
    const double* __restrict c = a1.data_.memptr();
    const double* __restrict u = a2.data_.memptr();

    for (arma::uword k = 0; k < a1.data_.n_elem; ++k) {
        double diff = std::fabs(c[k] - u[k]);
        double mag  = std::fabs(c[k]) > std::fabs(u[k]) ?
                      std::fabs(c[k]) : std::fabs(u[k]);
        mag = mag > 1.0 ? mag : 1.0;
        if (diff > tolFactor * eps * mag) return false;
    }
    return true;
}

#endif // MOLE_ARRAYS_H