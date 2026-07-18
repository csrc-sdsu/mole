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
 * @date 2026/06/24
 *
 */

#ifndef ARRAY2D_H
#define ARRAY2D_H

#include <vector>
using Real = double;

class Flat2DArray {
    mutable stack<MOLE_Errors> errs; // for error detection+backtracking
public:
    Flat2DArray() = default;
    // constructor for syntax Flat2DArray A(m,n,fillval)
    Flat2DArray(size_t rows, size_t cols, Real fillVal = 0.0)
        : rows_(rows), cols_(cols), data_(rows * cols, fillVal) {}

    Real& operator()(size_t i, size_t j); 
    
    const Real& operator()(size_t i, size_t j) const;

    void resize(size_t rows, size_t cols, Real fillVal= 0.0);

    size_t rows() const { return rows_; }
    size_t cols() const { return cols_; }

    Real* data() { return data_.data(); }
    const Real* data() const { return data_.data(); }

    // --- Row-wise access: pointer + length ---
    Real* row(size_t i);
    
    const Real* row(size_t i) const ;
    
    size_t rowStride() const { return cols_; }  // elements to next row
    size_t rowLength() const { return cols_; }  // valid elements per row

    void logArr2DErr(int errCode, string errLoc, string errParm) const;
    bool hasArr2DErrors();
    void print_ErrorLog();
    void write_ErrorLog();
    Real dnan = nan("");
    
private:
    size_t rows_ = 0, cols_ = 0;
    std::vector<Real> data_;
};
#endif // ARRAY2D_H