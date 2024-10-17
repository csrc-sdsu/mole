/**
 * @file utils.h
 * @brief Helpers for sparse operations and MATLAB analogs
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
  *  @brief An in place oepration for joining two matrices by rows
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
  * @note This is available in Armadillo >8.0
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
};

#endif // UTILS_H
