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
 * @file utils.cpp
 * @brief Helpers for sparse operations and MATLAB analogs
 * @date 2024/10/15
 * 
 * Sparse operations that repeatedly are needed, but not 
 * necessarily part of the Armadillo library. Some other MATLAB
 * type functions are also here, like meshgrid.
 */

#include "utils.h"

#ifdef EIGEN
#include <eigen3/Eigen/SparseLU>

vec Utils::spsolve_eigen(const sp_mat &A, const vec &b) {
  Eigen::SparseMatrix<Real> eigen_A(A.n_rows, A.n_cols);
  std::vector<Eigen::Triplet<Real>> triplets;
  Eigen::SparseLU<Eigen::SparseMatrix<Real>, Eigen::COLAMDOrdering<int>> solver;

  Eigen::VectorXd eigen_x(A.n_rows);
  triplets.reserve(5 * A.n_rows);

  auto it = A.begin();
  while (it != A.end()) {
    triplets.push_back(Eigen::Triplet<Real>(it.row(), it.col(), *it));
    ++it;
  }

  eigen_A.setFromTriplets(triplets.begin(), triplets.end());
  triplets.clear();

  auto b_ = conv_to<std::vector<Real>>::from(b);
  Eigen::Map<Eigen::VectorXd> eigen_b(b_.data(), b_.size());

  solver.analyzePattern(eigen_A);
  solver.factorize(eigen_A);
  eigen_x = solver.solve(eigen_b);

  return vec(eigen_x.data(), eigen_x.size());
}
#endif

// Basic implementation of Kronecker product
/*
sp_mat Utils::spkron(const sp_mat &A, const sp_mat &B)
{
    sp_mat result;

    for (u32 i = 0; i < A.n_rows; i++) {
        sp_mat BLOCK;
        for (u32 j = 0; j < A.n_cols; j++) {
            BLOCK = join_rows(BLOCK, A(i, j)*B);
        }
        result = join_cols(result, BLOCK);
    }

    return result;
}
*/

sp_mat Utils::spkron(const sp_mat &A, const sp_mat &B) {
  sp_mat::const_iterator itA = A.begin();
  sp_mat::const_iterator endA = A.end();
  sp_mat::const_iterator itB = B.begin();
  sp_mat::const_iterator endB = B.end();
  u32 j = 0;

  vec a = nonzeros(A);
  vec b = nonzeros(B);

  umat locations(2, a.n_elem * b.n_elem);
  vec values(a.n_elem * b.n_elem);

  while (itA != endA) {
    while (itB != endB) {
      locations(0, j) = itA.row() * B.n_rows + itB.row();
      locations(1, j) = itA.col() * B.n_cols + itB.col();
      values(j) = (*itA) * (*itB);
      ++j;
      ++itB;
    }

    ++itA;
    itB = B.begin();
  }

  sp_mat result(locations, values, A.n_rows * B.n_rows, A.n_cols * B.n_cols,
                true);

  return result;
}


sp_mat Utils::spjoin_rows(const sp_mat &A, const sp_mat &B) {
  sp_mat::const_iterator itA = A.begin();
  sp_mat::const_iterator endA = A.end();
  sp_mat::const_iterator itB = B.begin();
  sp_mat::const_iterator endB = B.end();
  u32 j = 0;

  vec a = nonzeros(A);
  vec b = nonzeros(B);

  umat locations(2, a.n_elem + b.n_elem);
  vec values(a.n_elem + b.n_elem);

  while (itA != endA) {
    locations(0, j) = itA.row();
    locations(1, j) = itA.col();
    values(j) = (*itA);
    ++itA;
    ++j;
  }

  while (itB != endB) {
    locations(0, j) = itB.row();
    locations(1, j) = itB.col() + A.n_cols;
    values(j) = (*itB);
    ++itB;
    ++j;
  }

  sp_mat result(locations, values, A.n_rows, A.n_cols + B.n_cols, true);

  return result;
}


sp_mat Utils::spjoin_cols(const sp_mat &A, const sp_mat &B) {
  sp_mat::const_iterator itA = A.begin();
  sp_mat::const_iterator endA = A.end();
  sp_mat::const_iterator itB = B.begin();
  sp_mat::const_iterator endB = B.end();
  u32 j = 0;

  vec a = nonzeros(A);
  vec b = nonzeros(B);

  umat locations(2, a.n_elem + b.n_elem);
  vec values(a.n_elem + b.n_elem);

  while (itA != endA) {
    locations(0, j) = itA.row();
    locations(1, j) = itA.col();
    values(j) = (*itA);
    ++itA;
    ++j;
  }

  while (itB != endB) {
    locations(0, j) = itB.row() + A.n_rows;
    locations(1, j) = itB.col();
    values(j) = (*itB);
    ++itB;
    ++j;
  }

  sp_mat result(locations, values, A.n_rows + B.n_rows, A.n_cols, true);

  return result;
}


void Utils::meshgrid(const vec &x, const vec &y, mat &X, mat &Y) {
  int m = x.n_elem;
  int n = y.n_elem;

  assert(m > 0);
  assert(n > 0);

  // Build X
  vec t(n, fill::ones);

  X.zeros(n, m);
  Y.zeros(n, m);

  for (int ii = 0; ii < m; ++ii) {
    X.col(ii) = x(ii) * t;
    t.ones();
  }

  for (int ii = 0; ii < m; ++ii)
    Y.col(ii) = y;
}


void Utils::meshgrid(const vec &x, const vec &y, const vec &z, cube &X, cube &Y,
                     cube &Z) {
  int m = x.n_elem;
  int n = y.n_elem;
  int o = z.n_elem;

  assert(m > 0);
  assert(n > 0);
  assert(o > 0);

  // Temporary Holder of sheet of cube
  mat sheet(m, n, fill::zeros);

  // Build X
  vec t(n, fill::ones);

  X.zeros(m, n, o);
  Y.zeros(m, n, o);
  Z.zeros(m, n, o);

  // Sheet that repeats each slice
  for (int ii = 0; ii < m; ++ii) {
    sheet.row(ii) = x(ii) * t.t();
    t.ones();
  }

  for (int kk = 0; kk < o; ++kk)
    X.slice(kk) = sheet;

  // Y Cube, repeats same sheet as well
  for (int ii = 0; ii < m; ++ii)
    sheet.row(ii) = y.t();

  for (int kk = 0; kk < o; ++kk)
    Y.slice(kk) = sheet;

  // Z cube goes by slices each with same value
  for (int kk = 0; kk < o; ++kk)
    Z.slice(kk).fill(z(kk));
}



sp_mat Utils::circshift(const sp_mat &Q, const s32 shift, const u16 axes)
{
    /* circshift is a Sparse implementation of the MATLAB circshift operator for 
       Armadillo. The standard operator works for dense matrixes, but we require
       a sparse implementation. Because sparse matrices are stored in CSR format,
       a different technique is used to speed up the process. If the matrix is
       shifted in the left/right direction, we also can sort the indices faster
       than Armadillo can, so we help that out for rebuilding the returned matrix.

       INPUT:

            Q       A sparse matrix to shift,
            shift   The amount to shift, positive indicates up/right, negative indicates down/left
            axes    The axes of shifting, 0=up/down, 1=left/right

        OUTPUT:

            returns shifted version of Q

    */
    DBGVMSG("Starting circshift, shifting ", shift );

    bool sort_locations = false;  // This algorithm sorts the locations for axis == 1,
    bool check_for_zeros = false; // And we are not adding any zero members, so do not check.

    uint size = (axes == 1) ? Q.n_cols : Q.n_rows; // Size is number of cols or rows
    uint elements = Q.n_nonzero;

    // Armadillo uses uvecs for building sparse matrices
    uvec r(elements);
    uvec c(elements);
    vec val(elements);

    // Strip sparse matrix into its row/column indices, and the values
    int count = 0;
    for (sp_mat::const_iterator it = Q.begin(); it != Q.end(); ++it)
    {
        r(count) = it.row();
        c(count) = it.col();
        val(count) = *it;
        count += 1;
    }

    // uvec may need indices higher than it can go, or may
    // need to subtract (negative indices), so convert to ivec
    ivec cc = conv_to<ivec>::from(c);
    ivec rr = conv_to<ivec>::from(r);
    // Shift columns or rows based on axes
    int shifted = 0;
    if ( axes == 1 ) // Shift columns
    {
        cc += shift;
        shifted = Utils().handleCyclicShift( cc, size );
        c = conv_to<uvec>::from(cc);
    }
    else // shift rows
    {
        rr += shift;
        shifted = Utils().handleCyclicShift( rr, size );
        r = conv_to<uvec>::from(rr);
    }

    // Build shifted sparse matrix
    umat Loc(2, elements);
    umat LocShift(arma::size(Loc));
    vec ValShift(arma::size(val));

    // Build dense location matrix
    Loc = arma::join_vert(r.t(), c.t());

    // For shifts in left/right direction (axis==1), no need to sort!
    // cut bottom off and put on top, or cut top off and put on bottom
    if ( axes == 1 )
    {
        LocShift = arma::shift(Loc,shifted,1);
        ValShift = arma::shift(val,shifted);
    }
    else  // Otherwise we assume that Armadillo will be able to sort the entries for us
    {
        LocShift = Loc;
        ValShift = val;
        sort_locations = true; // make Armadillo sort the values, check_for_zeros still false becasue we did not make zeros.
    } 

    return sp_mat( LocShift, ValShift, Q.n_rows, Q.n_cols, sort_locations, check_for_zeros );
}

// Helper function for circular shifting
int Utils::handleCyclicShift(ivec &indices, const uint size)
{
    DBGMSG("Handling CyclicShift");
    int shifted = 0;
    for (uint i = 0; i < indices.size(); ++i)
    {
        if (indices(i) >= size)
        {
            indices(i) -= size;
            shifted += 1;
        }
        else if (indices(i) < 0)
        {
            indices(i) += size;
            shifted += 1;
        }
    }    
    return shifted;
}
// End of file