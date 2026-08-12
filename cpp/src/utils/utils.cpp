/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/


/* 
 * @file utils.cpp
 * @brief Helpers for sparse operations and MATLAB/Octave analogs
 * @date 2024/10/15
 * New Implementation for MOLE 2.0 Last Modified 2026/07/22
 * 
 * Sparse operations that repeatedly are needed, but not 
 * necessarily part of the Armadillo library. Some other MATLAB/Octave
 * type functions are also here, like meshgrid.
 */

#include "utils.h"
#include <cmath>
#include <string>

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

// ------------------------------------------------------------------
//
// Error handling methods for MOLE Utils
//
// ------------------------------------------------------------------

//
// hasErrors checks if there are any errors logged in the Utils class
bool Utils::hasErrors() {    
  return !errs.empty();
}

//
// print_ErrorLog prints the error log to stdout
//
void Utils::print_ErrorLog() {
  MOLEerr_print(errs); 
}

//
// write_ErrorLog writes the error log to a file with name starting 
// with UtilsErrors, the full file name includes a timestamp.
//
void Utils::write_ErrorLog() {
  MOLEerr_dumpErrLog(errs, "UtilsErrors"); // writes the error log to a file
}

//
// read_ErrorLog reads the error on top of the stack
//
void Utils::read_ErrorLog(int ErrorCode, std::string &location, 
                          std::string &arrayName) {
  if (!errs.empty()) {
    MOLE_Errors topError = errs.top();
    ErrorCode = topError.errCode;
    location = topError.errLocation;
    arrayName = topError.paramError;
    errs.pop(); // Remove the top error after reading
  }
}

//
// spkron computes the sparse Kronecker tensor product of two 
//sparse matrices A and B. This version uses Armadillo's sparse 
// matrices and it is based on Octave's kron(A, B) operation.
//
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


//
// spjoin_rows joins two sparse matrices by rows, returning a new
// sparse matrix. This version uses Armadillo's sparse matrices and
// it is based on Octave's [A B] operation, where A and B are sparse
// matrices.
//
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

//
// spjoin_cols joins two sparse matrices by columns, returning a new
// sparse matrix. This version uses Armadillo's sparse matrices and
// it is based on Octave's [A B]^T operation, where A and B are 
// sparse matrices.
//
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

//
// meshgrid generates a 2D mesh from two 1D arrays representing the x
// and y coordinates (matches Octave meshgrid implemenation, which is
// incolumn-major order). This version uses Armadillo vecs and mats.
// It also checks for valid input sizes and reports errors.
//
void Utils::mesh2Dgrid(const vec &x, const vec &y, mat &X, mat &Y) {
  size_t m = x.n_elem;
  size_t n = y.n_elem;
  bool valid = true;
   
  if (m <= 0){ // assert(m > 0)
    std::string errmsg = "m = " + std::to_string(m);
    MOLEerr_log(errs, MOLE_ERR_INVALID_ARRAY_SIZE, "Utils::meshgrid",
                errmsg);
    valid = false;
  }
  if (n <= 0) {// assert(n > 0);
    std::string errmsg = "n = " + std::to_string(n);
    MOLEerr_log(errs, MOLE_ERR_INVALID_ARRAY_SIZE, "Utils::meshgrid",
                errmsg);
    valid = false;
  }

  if (valid){
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
  }
}

//
// meshgrid generates a 3D mesh from three 1D arrays representing the 
// x, y, and z coordinates (matches Octave meshgrid implemenation, 
// which is in column-major order). This version uses Armadillo vecs
// and mats. It also checks for valid input sizes and reports errors.
//
void Utils::mesh3Dgrid(const vec &x, const vec &y, const vec &z, 
                      cube &X, cube &Y, cube &Z) {
  size_t m = x.n_elem;
  size_t n = y.n_elem;
  size_t o = z.n_elem;

  bool valid = true;
  if (m <= 0){ // assert(m > 0)
    std::string errmsg = "m = " + std::to_string(m);
    MOLEerr_log(errs, MOLE_ERR_INVALID_ARRAY_SIZE, "Utils::meshgrid",
                errmsg);
    valid = false;
  }
  if (n <= 0) {// assert(n > 0);
    std::string errmsg = "n = " + std::to_string(n);
    MOLEerr_log(errs, MOLE_ERR_INVALID_ARRAY_SIZE, "Utils::meshgrid",
                errmsg);
    valid = false;
  }
  if (o <= 0) {// assert(o > 0);
    std::string errmsg = "o = " + std::to_string(o);
    MOLEerr_log(errs, MOLE_ERR_INVALID_ARRAY_SIZE, "Utils::meshgrid", 
                errmsg);
    valid = false;
  }

  if (valid){
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
  }
}

//
// Trapezoidal rule (trapz) for 1D integration. This version uses
// Armadillo vecs and mats. It losgs and error when the two input
// vectors are not the same size.
//
double Utils::trapz(const vec &x, const vec &y) {

  if (x.n_elem == y.n_elem){
    double sum = 0.0;
    for (uword i = 0; i < x.n_elem - 1; ++i) {
      sum += (x(i+1) - x(i)) * (y(i) + y(i+1));
    }
    return 0.5 * sum;
  } else{
      std::string errmsg = "x._n_elem = " + std::to_string(x.n_elem);
      errmsg += ", and y.n_elem = " + std::to_string(y.n_elem);
      MOLEerr_log(errs, MOLE_ERR_INVALID_ARRAY_SIZE, "Utils::trapz", errmsg);
      return std::nan("");
  }
}

