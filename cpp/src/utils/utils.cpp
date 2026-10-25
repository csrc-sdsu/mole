/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/


/* 
 * @file utils.cpp
 * @brief Helpers for sparse operations and MATLAB/Octave analogs
 * @date 2024/10/15
 * New Implementation for MOLE 2.0 Last Modified 2026/10/25
 * 
 * Sparse operations that repeatedly are needed, but not 
 * necessarily part of the Armadillo library. Some other MATLAB/Octave
 * type functions are also here, like meshgrid.
 *
 * Every function logs its errors onto the error stack passed in by
 * the caller. Allocation exceptions thrown by Armadillo or Eigen are
 * caught and logged as MOLE_ERR_FAILED_ARRAY_ALLOC.
 */

#include "utils.h"
#include <cmath>
#include <new>
#include <string>

//
// logAllocException logs an allocation exception caught inside a
// Utils function onto the caller's error stack.
//
static void logAllocException(std::stack<MOLE_Errors> &errs,
                              const std::string &loc,
                              const std::bad_alloc &e) {
  MOLEerr_log(errs, MOLE_ERR_FAILED_ARRAY_ALLOC, loc,
              std::string("std::bad_alloc: ") + e.what());
}

#ifdef EIGEN
#include <eigen3/Eigen/SparseLU>

//
// spsolve_eigen solves Ax = b with Eigen's SparseLU. A must be square
// and have as many rows as b. A singular A is reported through the
// solver's status after factorization.
//
vec Utils::spsolve_eigen(std::stack<MOLE_Errors> &errs, const sp_mat &A,
                         const vec &b) {
  const std::string loc = "Utils::spsolve_eigen";
  bool valid = true;

  if (A.n_rows != A.n_cols) {
    std::string errmsg = "A.n_rows = " + std::to_string(A.n_rows);
    errmsg += ", and A.n_cols = " + std::to_string(A.n_cols);
    MOLEerr_log(errs, MOLE_ERR_UTILS_NOT_SQUARE, loc, errmsg);
    valid = false;
  }
  if (A.n_rows != b.n_elem) {
    std::string errmsg = "A.n_rows = " + std::to_string(A.n_rows);
    errmsg += ", and b.n_elem = " + std::to_string(b.n_elem);
    MOLEerr_log(errs, MOLE_ERR_UTILS_RHS_ROW_MISMATCH, loc, errmsg);
    valid = false;
  }
  if (!valid)
    return vec();

  try {
    Eigen::SparseMatrix<Real> eigen_A(A.n_rows, A.n_cols);
    std::vector<Eigen::Triplet<Real>> triplets;
    Eigen::SparseLU<Eigen::SparseMatrix<Real>, Eigen::COLAMDOrdering<int>>
        solver;

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
    if (solver.info() != Eigen::Success) {
      MOLEerr_log(errs, MOLE_ERR_UTILS_SINGULAR_MATRIX, loc,
                  solver.lastErrorMessage());
      return vec();
    }
    eigen_x = solver.solve(eigen_b);

    return vec(eigen_x.data(), eigen_x.size());
  } catch (const std::bad_alloc &e) {
    logAllocException(errs, loc, e);
    return vec();
  }
}
#endif

//
// spkron computes the sparse Kronecker tensor product of two 
// sparse matrices A and B. This version uses Armadillo's sparse 
// matrices and it is based on Octave's kron(A, B) operation.
//
sp_mat Utils::spkron(std::stack<MOLE_Errors> &errs, const sp_mat &A,
                     const sp_mat &B) {
  try {
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

    sp_mat result(locations, values, A.n_rows * B.n_rows,
                  A.n_cols * B.n_cols, true);

    return result;
  } catch (const std::bad_alloc &e) {
    logAllocException(errs, "Utils::spkron", e);
    return sp_mat();
  }
}


//
// spjoin_rows joins two sparse matrices by rows, returning a new
// sparse matrix. This version uses Armadillo's sparse matrices and
// it is based on Octave's [A B] operation, where A and B are sparse
// matrices with the same number of rows.
//
sp_mat Utils::spjoin_rows(std::stack<MOLE_Errors> &errs, const sp_mat &A,
                          const sp_mat &B) {
  const std::string loc = "Utils::spjoin_rows";

  if (A.n_rows != B.n_rows) {
    std::string errmsg = "A.n_rows = " + std::to_string(A.n_rows);
    errmsg += ", and B.n_rows = " + std::to_string(B.n_rows);
    MOLEerr_log(errs, MOLE_ERR_UTILS_ROW_MISMATCH, loc, errmsg);
    return sp_mat();
  }

  try {
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
  } catch (const std::bad_alloc &e) {
    logAllocException(errs, loc, e);
    return sp_mat();
  }
}

//
// spjoin_cols joins two sparse matrices by columns, returning a new
// sparse matrix. This version uses Armadillo's sparse matrices and
// it is based on Octave's [A; B] operation, where A and B are 
// sparse matrices with the same number of columns.
//
sp_mat Utils::spjoin_cols(std::stack<MOLE_Errors> &errs, const sp_mat &A,
                          const sp_mat &B) {
  const std::string loc = "Utils::spjoin_cols";

  if (A.n_cols != B.n_cols) {
    std::string errmsg = "A.n_cols = " + std::to_string(A.n_cols);
    errmsg += ", and B.n_cols = " + std::to_string(B.n_cols);
    MOLEerr_log(errs, MOLE_ERR_UTILS_COL_MISMATCH, loc, errmsg);
    return sp_mat();
  }

  try {
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
  } catch (const std::bad_alloc &e) {
    logAllocException(errs, loc, e);
    return sp_mat();
  }
}

//
// meshgrid generates a 2D mesh from two 1D arrays representing the x
// and y coordinates (matches Octave meshgrid implemenation, which is
// incolumn-major order). This version uses Armadillo vecs and mats.
// It also checks for valid input sizes and reports errors.
//
void Utils::mesh2Dgrid(std::stack<MOLE_Errors> &errs, const vec &x,
                       const vec &y, mat &X, mat &Y) {
  const std::string loc = "Utils::mesh2Dgrid";
  size_t m = x.n_elem;
  size_t n = y.n_elem;
  bool valid = true;
   
  if (m == 0) {
    std::string errmsg = "m = " + std::to_string(m);
    MOLEerr_log(errs, MOLE_ERR_UTILS_INVALID_MESH_SIZE, loc, errmsg);
    valid = false;
  }
  if (n == 0) {
    std::string errmsg = "n = " + std::to_string(n);
    MOLEerr_log(errs, MOLE_ERR_UTILS_INVALID_MESH_SIZE, loc, errmsg);
    valid = false;
  }

  if (!valid)
    return;

  try {
    // Build X
    vec t(n, fill::ones);

    X.zeros(n, m);
    Y.zeros(n, m);

    for (size_t ii = 0; ii < m; ++ii) {
      X.col(ii) = x(ii) * t;
      t.ones();
    }
  
    // Build Y
    for (size_t ii = 0; ii < m; ++ii)
      Y.col(ii) = y;
  } catch (const std::bad_alloc &e) {
    X.reset();
    Y.reset();
    logAllocException(errs, loc, e);
  }
}

//
// meshgrid generates a 3D mesh from three 1D arrays representing the 
// x, y, and z coordinates (matches Octave meshgrid implemenation, 
// which is in column-major order). This version uses Armadillo vecs
// and mats. It also checks for valid input sizes and reports errors.
//
void Utils::mesh3Dgrid(std::stack<MOLE_Errors> &errs, const vec &x,
                       const vec &y, const vec &z, cube &X, cube &Y,
                       cube &Z) {
  const std::string loc = "Utils::mesh3Dgrid";
  size_t m = x.n_elem;
  size_t n = y.n_elem;
  size_t o = z.n_elem;
  bool valid = true;

  if (m == 0) {
    std::string errmsg = "m = " + std::to_string(m);
    MOLEerr_log(errs, MOLE_ERR_UTILS_INVALID_MESH_SIZE, loc, errmsg);
    valid = false;
  }
  if (n == 0) {
    std::string errmsg = "n = " + std::to_string(n);
    MOLEerr_log(errs, MOLE_ERR_UTILS_INVALID_MESH_SIZE, loc, errmsg);
    valid = false;
  }
  if (o == 0) {
    std::string errmsg = "o = " + std::to_string(o);
    MOLEerr_log(errs, MOLE_ERR_UTILS_INVALID_MESH_SIZE, loc, errmsg);
    valid = false;
  }

  if (!valid)
    return;

  try {
    // Temporary Holder of sheet of cube
    mat sheet(m, n, fill::zeros);

    // Build X
    vec t(n, fill::ones);

    X.zeros(m, n, o);
    Y.zeros(m, n, o);
    Z.zeros(m, n, o);

    // Sheet that repeats each slice
    for (size_t ii = 0; ii < m; ++ii) {
      sheet.row(ii) = x(ii) * t.t();
      t.ones();
    }

    for (size_t kk = 0; kk < o; ++kk)
      X.slice(kk) = sheet;

    // Y Cube, repeats same sheet as well
    for (size_t ii = 0; ii < m; ++ii)
      sheet.row(ii) = y.t();

    for (size_t kk = 0; kk < o; ++kk)
      Y.slice(kk) = sheet;

    // Z cube goes by slices each with same value
    for (size_t kk = 0; kk < o; ++kk)
      Z.slice(kk).fill(z(kk));
  } catch (const std::bad_alloc &e) {
    X.reset();
    Y.reset();
    Z.reset();
    logAllocException(errs, loc, e);
  }
}

//
// Trapezoidal rule (trapz) for 1D integration. This version uses
// Armadillo vecs. It logs an error and returns NaN when the two input
// vectors are not the same size or have fewer than two points.
//
double Utils::trapz(std::stack<MOLE_Errors> &errs, const vec &x,
                    const vec &y) {
  const std::string loc = "Utils::trapz";

  if (x.n_elem != y.n_elem) {
    std::string errmsg = "x.n_elem = " + std::to_string(x.n_elem);
    errmsg += ", and y.n_elem = " + std::to_string(y.n_elem);
    MOLEerr_log(errs, MOLE_ERR_UTILS_SIZE_MISMATCH, loc, errmsg);
    return std::nan("");
  }
  if (x.n_elem < 2) {
    std::string errmsg = "x.n_elem = " + std::to_string(x.n_elem);
    MOLEerr_log(errs, MOLE_ERR_UTILS_TOO_FEW_POINTS, loc, errmsg);
    return std::nan("");
  }

  double sum = 0.0;
  for (uword i = 0; i < x.n_elem - 1; ++i) {
    sum += (x(i+1) - x(i)) * (y(i) + y(i+1));
  }
  return 0.5 * sum;
}
