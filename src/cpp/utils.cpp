/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/


/* 
 * @file utils.cpp
 * @brief Helpers for sparse operations and MATLAB/Octave analogs
 * @date 2024/10/15
 * 
 * Sparse operations that repeatedly are needed, but not 
 * necessarily part of the Armadillo library. Some other MATLAB/Octave
 * type functions are also here, like meshgrid.
 */

#include "utils.h"
#include <cassert>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

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

const char* weightsPathEnvVar = "MOLE_WEIGHTS_PATH"; 
const char* weightsDefaultPath = "../../../src/dat"; 

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

// Trapezoidal rule (trapz) for 1D integration
double Utils::trapz(const vec &x, const vec &y) {
  assert(x.n_elem == y.n_elem);
  double sum = 0.0;
  for (uword i = 0; i < x.n_elem - 1; ++i) {
    sum += (x(i+1) - x(i)) * (y(i) + y(i+1));
  }
  return 0.5 * sum;
}

void Utils::initWeightsVec(const int k, const int m, vec &weightsVec, const char* weightsFileName)
{
  bool lineFnd = false;

  assert(m >= 2*k+1);

  //TODO: We need a rational way to store the location of the weights files
  //      Using an environment variable is one way to do it
  const char* weightsPath = std::getenv(weightsPathEnvVar);
  if (weightsPath == NULL) {
    weightsPath = weightsDefaultPath;
  }
  std::string weightsFilePath = std::string(weightsPath) + "/" + weightsFileName;
  std::ifstream file(weightsFilePath);
  
  std::string line;
  while (std::getline(file, line)) {
      std::stringstream ss(line);
      std::string token;
      std::vector<std::string> result_vector;

      while (std::getline(ss, token, ',')) {
        result_vector.push_back(token);
      }
      if (std::stoi(result_vector[0]) == k && std::stoi(result_vector[1]) == m) {
        lineFnd = true;
        weightsVec.set_size(m);
        for (int i = 2;i < m;++i) {
          weightsVec.at(i-2) = std::stod(result_vector[i]);
        }
      }
  }
  file.close();
  assert(lineFnd);
}

void Utils::initQ(const int k, const int m, vec &q) {
  initWeightsVec(k, m, q, "qweights.csv");
}

void Utils::initP(const int k, const int m, vec &p) {
  initWeightsVec(k, m, p, "pweights.csv");
}
