#include "divergence.h"

// 1-D Constructor
Divergence::Divergence(u16 k, u32 m, Real dx) : sp_mat(m + 2, m + 1) {
  assert(!(k % 2));
  assert(k > 1 && k < 7);
  assert(m > 2 * k);

  switch (k) {
  case 2:
    for (u32 i = 1; i < m + 1; i++) {
      at(i, i - 1) = -1.0;
      at(i, i) = 1.0;
    }
    // Weights
    Q << 1.0 << 1.0 << 1.0 << 1.0 << 1.0;
    break;
  case 4:
    // A
    at(1, 0) = -11.0 / 12.0;
    at(1, 1) = 17.0 / 24.0;
    at(1, 2) = 3.0 / 8.0;
    at(1, 3) = -5.0 / 24.0;
    at(1, 4) = 1.0 / 24.0;
    // A'
    at(m, m) = 11.0 / 12.0;
    at(m, m - 1) = -17.0 / 24.0;
    at(m, m - 2) = -3.0 / 8.0;
    at(m, m - 3) = 5.0 / 24.0;
    at(m, m - 4) = -1.0 / 24.0;
    // Middle
    for (u32 i = 2; i < m; i++) {
      at(i, i - 2) = 1.0 / 24.0;
      at(i, i - 1) = -9.0 / 8.0;
      at(i, i) = 9.0 / 8.0;
      at(i, i + 1) = -1.0 / 24.0;
    }
    // Weights
    //
    Q << 2186.0 / 1943.0 << 2125.0 / 2828.0 << 1441.0 / 1240.0 << 648.0 / 673.0
      << 349.0 / 350.0 << 648.0 / 673.0 << 1441.0 / 1240.0 << 2125.0 / 2828.0
      << 2186.0 / 1943.0;
    break;
  case 6:
    // A
    at(1, 0) = -1627.0 / 1920.0;
    at(1, 1) = 211.0 / 640.0;
    at(1, 2) = 59.0 / 48.0;
    at(1, 3) = -235.0 / 192.0;
    at(1, 4) = 91.0 / 128.0;
    at(1, 5) = -443.0 / 1920.0;
    at(1, 6) = 31.0 / 960.0;
    at(2, 0) = 31.0 / 960.0;
    at(2, 1) = -687.0 / 640.0;
    at(2, 2) = 129.0 / 128.0;
    at(2, 3) = 19.0 / 192.0;
    at(2, 4) = -3.0 / 32.0;
    at(2, 5) = 21.0 / 640.0;
    at(2, 6) = -3.0 / 640.0;
    // A'
    at(m, m) = 1627.0 / 1920.0;
    at(m, m - 1) = -211.0 / 640.0;
    at(m, m - 2) = -59.0 / 48.0;
    at(m, m - 3) = 235.0 / 192.0;
    at(m, m - 4) = -91.0 / 128.0;
    at(m, m - 5) = 443.0 / 1920.0;
    at(m, m - 6) = -31.0 / 960.0;
    at(m - 1, m) = -31.0 / 960.0;
    at(m - 1, m - 1) = 687.0 / 640.0;
    at(m - 1, m - 2) = -129.0 / 128.0;
    at(m - 1, m - 3) = -19.0 / 192.0;
    at(m - 1, m - 4) = 3.0 / 32.0;
    at(m - 1, m - 5) = -21.0 / 640.0;
    at(m - 1, m - 6) = 3.0 / 640.0;
    // Middle
    for (u32 i = 3; i < m - 1; i++) {
      at(i, i - 3) = -3.0 / 640.0;
      at(i, i - 2) = 25.0 / 384.0;
      at(i, i - 1) = -75.0 / 64.0;
      at(i, i) = 75.0 / 64.0;
      at(i, i + 1) = -25.0 / 384.0;
      at(i, i + 2) = 3.0 / 640.0;
    }
    // Weights
    Q << 2383.0 / 2005.0 << 929.0 / 2002.0 << 887.0 / 531.0 << 3124.0 / 5901.0
      << 1706.0 / 1457.0 << 457.0 / 467.0 << 1057.0 / 1061.0 << 457.0 / 467.0
      << 1706.0 / 1457.0 << 3124.0 / 5901.0 << 887.0 / 531.0 << 929.0 / 2002.0
      << 2383.0 / 2005.0;
    break;
  }

  // Scaling
  *this /= dx;
}

// 2-D Constructor
Divergence::Divergence(u16 k, u32 m, u32 n, Real dx, Real dy) {
  Divergence Dx(k, m, dx);
  Divergence Dy(k, n, dy);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);

  Im.shed_col(0);
  Im.shed_col(m);
  In.shed_col(0);
  In.shed_col(n);

  sp_mat D1 = Utils::spkron(In, Dx);
  sp_mat D2 = Utils::spkron(Dy, Im);

  // Dimensions = (m+2)*(n+2), 2*m*n+m+n
  if (m != n)
    *this = Utils::spjoin_rows(D1, D2);
  else {
    sp_mat A1(1, 2);
    sp_mat A2(1, 2);
    A1(0, 0) = A2(0, 1) = 1.0;
    *this = Utils::spkron(A1, D1) + Utils::spkron(A2, D2);
  }
}

// 3-D Constructor
Divergence::Divergence(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz) {
  Divergence Dx(k, m, dx);
  Divergence Dy(k, n, dy);
  Divergence Dz(k, o, dz);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);
  sp_mat Io = speye(o + 2, o + 2);

  Im.shed_col(0);
  Im.shed_col(m);
  In.shed_col(0);
  In.shed_col(n);
  Io.shed_col(0);
  Io.shed_col(o);

  sp_mat D1 = Utils::spkron(Utils::spkron(Io, In), Dx);
  sp_mat D2 = Utils::spkron(Utils::spkron(Io, Dy), Im);
  sp_mat D3 = Utils::spkron(Utils::spkron(Dz, In), Im);

  // Dimensions = (m+2)*(n+2)*(o+2), 3*m*n*o+m*n+m*o+n*o
  if ((m != n) || (n != o))
    *this = Utils::spjoin_rows(Utils::spjoin_rows(D1, D2), D3);
  else {
    sp_mat A1(1, 3);
    sp_mat A2(1, 3);
    sp_mat A3(1, 3);
    A1(0, 0) = A2(0, 1) = A3(0, 2) = 1.0;
    *this =
        Utils::spkron(A1, D1) + Utils::spkron(A2, D2) + Utils::spkron(A3, D3);
  }
}

// Returns weights
vec Divergence::getQ() { return Q; }
