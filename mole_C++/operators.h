#ifndef OPERATORS_H
#define OPERATORS_H

#include "interpol.h"
#include "laplacian.h"
#include "mixedbc.h"
#include "robinbc.h"

inline sp_mat operator*(const Divergence &div, const Gradient &grad) {
  return (sp_mat)div * (sp_mat)grad;
}

inline sp_mat operator+(const Laplacian &lap, const RobinBC &bc) {
  return (sp_mat)lap + (sp_mat)bc;
}

inline sp_mat operator+(const Laplacian &lap, const MixedBC &bc) {
  return (sp_mat)lap + (sp_mat)bc;
}

inline vec operator*(const Divergence &div, const vec &v) {
  return (sp_mat)div * v;
}

inline vec operator*(const Gradient &grad, const vec &v) {
  return (sp_mat)grad * v;
}

inline vec operator*(const Laplacian &lap, const vec &v) {
  return (sp_mat)lap * v;
}

inline vec operator*(const Interpol &I, const vec &v) { return (sp_mat)I * v; }

#endif // OPERATORS_H
