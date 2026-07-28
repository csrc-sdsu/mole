/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file array2d.h
 *
 * @brief Flat2DArray Defines flat C++ arrays/vectors to optimize 
 * memory access, instead of using nested c++ vectors (e.g., 
 * std::vector<std:vector<Real>>) 
 *
 * @date 2026/07/14
 *
 */

#ifndef ARRAY2D_H
#define ARRAY2D_H

#include <vector>
#include <cmath>
using Real = double;

#include "MOLE_Errors.h"

class flat2DArray {
protected:
    mutable stack<MOLE_Errors> a_errs; // for error detection+backtracking
public:
    flat2DArray() = default;
    // constructor for syntax Flat2DArray A(rows, cols, fillval)
    flat2DArray(size_t rows, size_t cols, Real fillVal = 0.0);
 
    // Element access
    Real& operator()(size_t i, size_t j); 
    const Real& operator()(size_t i, size_t j) const;
    
    // Array equality comparison (checks data + dimensions)
    bool operator==(const flat2DArray& other) const;
    bool operator!=(const flat2DArray& other) const;    

    void resize(size_t rows, size_t cols, Real fillVal= 0.0);

    // returns flat2DArray dimensions rows or cols
    size_t rows() const { return rows_; }
    size_t cols() const { return cols_; }
    // returns flat2DArray data values (flat)
    Real* data() { return data_.data(); }
    const Real* data() const { return data_.data(); }

    // --- Row-wise access: pointer + length ---
    Real* row(size_t i);
    const Real* row(size_t i) const ;
    
    size_t rowStride() const { return cols_; }  // vals to next row
    size_t rowLength() const { return cols_; }  // valid vals per row

    // 2D Flat Array size definitions
    size_t size() const { return rows_ * cols_; } // size of an array
    bool empty() const { return rows_ == 0 || cols_ == 0; }  

    // flat2DArray error handling
    void logArr2DErr(size_t errCode, string errLoc, 
                     string errParm) const;
    bool hasArr2DErrors();
    void print_ErrorLog();
    void write_ErrorLog();
    
private:
    size_t rows_ = 0, cols_ = 0;
    std::vector<Real> data_;
};
#endif // ARRAY2D_H