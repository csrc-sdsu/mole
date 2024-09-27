#ifndef DIVERGENCE_H
#define DIVERGENCE_H

#include "utils.h"
#include <cassert>

class Divergence : public sp_mat {

public:
  using sp_mat::operator=;

  // 1-D Constructor
  Divergence(u16 k, u32 m, Real dx);
  // 2-D Constructor
  Divergence(u16 k, u32 m, u32 n, Real dx, Real dy);
  // 3-D Constructor
  Divergence(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz);
  // Returns weights
  vec getQ();

private:
  vec Q;
};

#endif // DIVERGENCE_H
