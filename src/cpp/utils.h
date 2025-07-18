/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/

/*
 * @file utils.h
 * @brief Helpers for sparse operations and MATLAB/Octave analogs
 * @date 2024/10/15
 *
 */

#pragma once

#ifndef UTILS_H
#define UTILS_H

#include <armadillo>

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
  * @param A a sparse matrix
  * @param B a sparse matrix
  *
  * @note This is available in Armadillo >8.0
  */
  static sp_mat spkron(const sp_mat &A, const sp_mat &B);

  /**
  *  @brief An in place operation for joining two matrices by rows
  *
  * @param A a sparse matrix
  * @param B a sparse matrix
  *
  * @note This is available in Armadillo >8.0
  */
  static sp_mat spjoin_rows(const sp_mat &A, const sp_mat &B);

  /**
  * @brief An in place operation for joining two matrices by columns
  *
  * @param A a sparse matrix
  * @param B a sparse matrix
  *
  * @note This is available in Armadillo >=8.5
  */  
  static sp_mat spjoin_cols(const sp_mat &A, const sp_mat &B);

  /**
  * @brief A wrappper for implementing a sparse solve using Eigen from SuperLU.
  *
  * @param A a sparse matrix LHS of Ax=b
  * @param b a vector for the RHS of Ax=b
  *
  * @note This function requires the EIGEN to be used when Armadillo is built
  */
  static vec spsolve_eigen(const sp_mat &A, const vec &b);

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
  * @param x a vector of x-indices
  * @param y a vector of y-indices
  * @param X a sparse matrix, will be filled by the function
  * @param Y a sparse matrix, will be filled by the function
  *
  */  
  void meshgrid(const vec &x, const vec &y, mat &X, mat &Y);

  /**
  * @brief An analog to the MATLAB/Octave 3D meshgrid operation
  *
  * meshgrid(x,y,z,X,Y,Z) returns 3-D grid coordinates defined by the 
  * vectors x, y, and z. The grid represented by X, Y, and Z has size
  * length(y)-by-length(x)-by-length(z).
  * 
  * @param x a vector of x-indices
  * @param y a vector of y-indices
  * @param z a vector of z-indices
  * @param X a sparse matrix, will be filled by the function
  * @param Y a sparse matrix, will be filled by the function
  * @param Z a sparse matrix, will be filled by the function
  *
  */
  void meshgrid(const vec &x, const vec &y, const vec &z, cube &X, cube &Y,
                cube &Z);
  /**
  * @brief Implements the trapezoidal rule for 1D numerical integration
  *
  * Computes the area under a curve defined by vectors x and y using:
  * A ≈ ∑ 0.5 * (xᵢ₊₁ - xᵢ) * (yᵢ + yᵢ₊₁)
  *
  * @param x Vector of x-coordinates
  * @param y Vector of y-values at corresponding x
  * @return Estimated area under the curve
  */
  static double trapz(const vec &x, const vec &y);
};

#endif // UTILS_H
