#ifndef GRADIENT_H
#define GRADIENT_H

#include "utils.h"
#include <cassert>

class Gradient : public sp_mat {

public:
  using sp_mat::operator=;

  // 1-D Constructor
  Gradient(u16 k, u32 m, Real dx);
  // 2-D Constructor
  Gradient(u16 k, u32 m, u32 n, Real dx, Real dy);
  // 3-D Constructor
  Gradient(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);
  // Returns weights
  vec getP();

private:
  vec P;
};

#endif // GRADIENT_H
