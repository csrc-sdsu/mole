/*
 * SPDX-License-Identifier: GPL-3.0-only
 * 
 * Copyright 2008-2024 San Diego State University Research Foundation (SDSURF).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * LICENSE file or on the web GNU General Public License 
 * <https:*www.gnu.org/licenses/> for more details.
 *  
 */

/*
 * @file utils.h
 * @brief Helpers for sparse operations and MATLAB analogs
 * @date 2024/10/15
 *
 */

#pragma once

#ifndef UTILS_H
#define UTILS_H

#include <armadillo>
#include <assert.h>     /* assert */
#include "debug.h"

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
  * @brief An analog to the MATLAB 2D meshgrid operation
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
  * @brief An analog to the MATLAB 3D meshgrid operation
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
  * @brief A circular shift for sparse matrices
  *
  * circshift shifts the sparse matrix Q by the value in 
  * shift, along the dimensions specified by axes.  
  * 
  * @param Q a sparse matrix to shift
  * @param shift a signed integer for the shift amount 
  * @param axes a direction of shift, 0=up/down, 1=left/right
  */             
  static sp_mat circshift( const sp_mat &Q, const s32 shift, const u16 axes );

  /**
  * @brief Counts the number of shifts which were cyclic.
  *
  * Sparse matrix indices must be in order, (row,column). A cyclic shift
  * may change the order of existing indices. Instead of resorting the entire set
  * of indices, it is easier to remember the values cycled, and move only those.
  * This function counts the number of indices that are looped from
  * one edge of the matrix to the other (cycled). This value is used to 
  * quickly organize the resulting shifted sparse matrix.
  * 
  * @param ivec a vector of indices to shift
  * @param size the amount to shift ( output )
  */  
  int handleCyclicShift(ivec &indices, const uint size);
};

#endif // UTILS_H
