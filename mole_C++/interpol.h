#ifndef INTERPOL_H
#define INTERPOL_H

#include "utils.h"
#include <cassert>

class Interpol : public sp_mat {

public:
  using sp_mat::operator=;

  // 1-D Constructor
  Interpol(u32 m, Real c);
  // 2-D Constructor
  Interpol(u32 m, u32 n, Real c1, Real c2);
  // 3-D Constructor
  Interpol(u32 m, u32 n, u32 o, Real c1, Real c2, Real c3);
  // 1-D Constructor for second type
  Interpol(bool type, u32 m, Real c);
  // 2-D Constructor for second type
  Interpol(bool type, u32 m, u32 n, Real c1, Real c2);
  // 3-D Constructor for second type
  Interpol(bool type, u32 m, u32 n, u32 o, Real c1, Real c2, Real c3);
};

#endif // INTERPOL_H
