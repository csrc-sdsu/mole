#include "robinbc.h"

// 1-D Constructor
RobinBC::RobinBC(u16 k, u32 m, Real dx, Real a, Real b) {
  sp_mat A(m + 2, m + 2);
  sp_mat BG(m + 2, m + 2);

  A.at(0, 0) = a;
  A.at(m + 1, m + 1) = a;

  Gradient grad(k, m, dx);

  BG.row(0) = -b * grad.row(0);
  BG.row(m + 1) = b * grad.row(m);

  *this = A + BG;
}

// 2-D Constructor
RobinBC::RobinBC(u16 k, u32 m, Real dx, u32 n, Real dy, Real a, Real b) {
  RobinBC Bm(k, m, dx, a, b);
  RobinBC Bn(k, n, dy, a, b);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);

  In.at(0, 0) = 0;
  In.at(n + 1, n + 1) = 0;

  sp_mat BC1 = Utils::spkron(In, Bm);
  sp_mat BC2 = Utils::spkron(Bn, Im);

  *this = BC1 + BC2;
}

// 3-D Constructor
RobinBC::RobinBC(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz, Real a,
                 Real b) {
  RobinBC Bm(k, m, dx, a, b);
  RobinBC Bn(k, n, dy, a, b);
  RobinBC Bo(k, o, dz, a, b);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);
  sp_mat Io = speye(o + 2, o + 2);

  Io.at(0, 0) = 0;
  Io.at(o + 1, o + 1) = 0;

  sp_mat In2 = In;
  In2.at(0, 0) = 0;
  In2.at(n + 1, n + 1) = 0;

  sp_mat BC1 = Utils::spkron(Utils::spkron(Io, In2), Bm);
  sp_mat BC2 = Utils::spkron(Utils::spkron(Io, Bn), Im);
  sp_mat BC3 = Utils::spkron(Utils::spkron(Bo, In), Im);

  *this = BC1 + BC2 + BC3;
}
