/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
*/

/*
 * @file utils.h
 * @brief Helpers for sparse operations and MATLAB/Octave analogs
 * @date 2024/10/15
 * New Implementation for MOLE 2.0 Last Modified 2026/10/25
 *
 * Every function takes the caller's MOLE error stack as its first
 * argument and logs any error onto it, in the same way as the
 * gridBuilder helpers. Utils keeps no error state of its own; the
 * caller checks the stack with MOLEerr_haserrors(errs).
 */

#pragma once

#ifndef UTILS_H
#define UTILS_H

#include <armadillo>
#include <stack>
#include "MOLE_errors.h"

using Real = double;
using namespace arma;

/**
 * @brief Utility Functions
 *
 */
class Utils {
public:

  /**
  * @brief A wrappper for implementing a sparse Kroenecker product.
  *
  * @param errs caller's error stack; an allocation exception is
  *        logged here
  * @param A a sparse matrix
  * @param B a sparse matrix
  * @return A kron B, or an empty matrix on error
  *
  * @note This is available in Armadillo >8.0
  */
  static sp_mat spkron(std::stack<MOLE_Errors> &errs, const sp_mat &A,
                       const sp_mat &B);

  /**
  *  @brief Joins two matrices by rows, [A B]
  *
  * @param errs caller's error stack; a row mismatch or an allocation
  *        exception is logged here
  * @param A a sparse matrix
  * @param B a sparse matrix with the same number of rows as A
  * @return [A B], or an empty matrix on error
  *
  * @note This is available in Armadillo >8.0
  */
  static sp_mat spjoin_rows(std::stack<MOLE_Errors> &errs,
                            const sp_mat &A, const sp_mat &B);

  /**
  * @brief Joins two matrices by columns, [A; B]
  *
  * @param errs caller's error stack; a column mismatch or an
  *        allocation exception is logged here
  * @param A a sparse matrix
  * @param B a sparse matrix with the same number of columns as A
  * @return [A; B], or an empty matrix on error
  *
  * @note This is available in Armadillo >=8.5
  */
  static sp_mat spjoin_cols(std::stack<MOLE_Errors> &errs,
                            const sp_mat &A, const sp_mat &B);

  /**
  * @brief A wrappper for implementing a sparse solve using Eigen from SuperLU.
  *
  * @param errs caller's error stack; a non-square A, a row mismatch
  *        between A and b, a singular A, or an allocation exception
  *        is logged here
  * @param A a sparse matrix LHS of Ax=b
  * @param b a vector for the RHS of Ax=b
  * @return x, or an empty vector on error
  *
  * @note This function requires the EIGEN to be used when Armadillo is built
  */
  static vec spsolve_eigen(std::stack<MOLE_Errors> &errs, const sp_mat &A,
                           const vec &b);

  /**
  * @brief An analog to the MATLAB/Octave 2D meshgrid operation
  *
  * returns 2-D grid coordinates based on the coordinates contained
  * in vectors x and y. X is a matrix where each row is a copy of x,
  * and Y is a matrix where each column is a copy of y. The grid
  * represented by the coordinates X and Y has length(y) rows and
  * length(x) columns. Key here is the rows is the y-coordinate, and
  * the columns are the x-coordinate.
  *
  * @param errs caller's error stack; an empty input or an allocation
  *        exception is logged here, and X, Y are left empty
  * @param x a vector of x-indices
  * @param y a vector of y-indices
  * @param X a matrix, will be filled by the function
  * @param Y a matrix, will be filled by the function
  *
  */
  static void mesh2Dgrid(std::stack<MOLE_Errors> &errs, const vec &x,
                         const vec &y, mat &X, mat &Y);

  /**
  * @brief An analog to the MATLAB/Octave 3D meshgrid operation
  *
  * meshgrid(x,y,z,X,Y,Z) returns 3-D grid coordinates defined by the
  * vectors x, y, and z. The grid represented by X, Y, and Z has size
  * length(y)-by-length(x)-by-length(z).
  *
  * @param errs caller's error stack; an empty input or an allocation
  *        exception is logged here, and X, Y, Z are left empty
  * @param x a vector of x-indices
  * @param y a vector of y-indices
  * @param z a vector of z-indices
  * @param X a cube, will be filled by the function
  * @param Y a cube, will be filled by the function
  * @param Z a cube, will be filled by the function
  *
  */
  static void mesh3Dgrid(std::stack<MOLE_Errors> &errs, const vec &x,
                         const vec &y, const vec &z, cube &X, cube &Y,
                         cube &Z);

  /**
  * @brief Implements the trapezoidal rule for 1D numerical integration
  *
  * Computes the area under a curve defined by vectors x and y using:
  * A ≈ ∑ 0.5 * (xᵢ₊₁ - xᵢ) * (yᵢ + yᵢ₊₁)
  *
  * @param errs caller's error stack; a size mismatch or fewer than
  *        two points is logged here
  * @param x Vector of x-coordinates
  * @param y Vector of y-values at corresponding x
  * @return Estimated area under the curve, or NaN on error
  */
  static double trapz(std::stack<MOLE_Errors> &errs, const vec &x,
                      const vec &y);
};

#endif // UTILS_H
