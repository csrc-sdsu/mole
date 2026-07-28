/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file array3d.h
 *
 * @brief Flat3DArray Defines flat C++ arrays/vectors to optimize 
 * memory access, instead of using nested c++ vectors (e.g., 
 * std::vector<std::vector<std::vector<Real>>> 
 *
 * @date 2026/07/14
 *
 */

#ifndef ARRAY3D_H
#define ARRAY3D_H

#include <vector>
#include <cmath>
using Real = double;

#include "MOLE_Errors.h"

class flat3DArray {
    mutable std::stack<MOLE_Errors> a_errs; // for error detection+backtracking
public:
    flat3DArray() = default;
    // constructor for syntax flat3DArray A(dim1, dim2, dim3, fillval)
    flat3DArray(size_t dim1, size_t dim2, size_t dim3, 
                Real fillVal = 0.0)
        : dim1_(dim1), dim2_(dim2), dim3_(dim3),
          data_(dim1 * dim2 * dim3, fillVal) {}

    // Element access
    Real& operator()(size_t i, size_t j, size_t k);
    const Real& operator()(size_t i, size_t j, size_t k) const;
  
    // Array equality comparison (checks data + dimensions)
    bool operator==(const flat3DArray& other) const;
    bool operator!=(const flat3DArray& other) const;

    void resize(size_t dim1, size_t dim2, size_t dim3, 
        Real fillVal = 0.0);

    // returns flat3DArray dimensions dim1, dim2 or dim3
    size_t dim1() const { return dim1_; }
    size_t dim2() const { return dim2_; }
    size_t dim3() const { return dim3_; }

    // returns flat3DArray data values (flat)
    Real* data() { return data_.data(); }
    const Real* data() const { return data_.data(); }

    // Plane-wise access: pointer + length (fixed i, all j,k) 
    Real* plane(size_t i);
    const Real* plane(size_t i) const;

    // Row-wise access: pointer + length (fixed i,j, all k) 
    Real* row(size_t i, size_t j);
    const Real* row(size_t i, size_t j) const;

    // elements to next i-plane
    size_t planeStride() const { return dim2_ * dim3_; } 

    // elements to next j-row
    size_t rowStride()   const { return dim3_; } 
    
    // valid elements per row
    size_t rowLength()   const { return dim3_; } 

    // 3D Flat Array size definitions
    size_t size() const { return dim1_ * dim2_ * dim3_; }
    bool empty() const { return dim1_ == 0 || 
                                dim2_ == 0 || dim3_ == 0; }  

    void logArr3DErr(size_t errCode, string errLoc, 
                     string errParm) const;
    bool hasArr3DErrors() const;
    void print_ErrorLog() const;
    void write_ErrorLog() const;

private:
    size_t dim1_ = 0, dim2_ = 0, dim3_ = 0;
    std::vector<Real> data_;
};
#endif // ARRAY3D_H