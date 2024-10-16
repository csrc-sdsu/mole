#ifndef ROBINBC_H
#define ROBINBC_H

#include "gradient.h"

class RobinBC : public sp_mat {

public:
  using sp_mat::operator=;

  // 1-D Constructor
  RobinBC(u16 k, u32 m, Real dx, Real a, Real b);
  // 2-D Constructor
  RobinBC(u16 k, u32 m, Real dx, u32 n, Real dy, Real a, Real b);
  // 3-D Constructor
  RobinBC(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz, Real a,
          Real b);
};

#endif // ROBINBC_H
