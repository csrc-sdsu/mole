/*
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */
/*
 * @file divergence.cpp
 *
 * @brief Mimetic Divergence Operators
 *
 * @date 2024/10/15
 * Last Modified: 2026/03/31
 */

#include "divergence.h"
#include <vector>

// ============================================================================
// Private helpers
// ============================================================================

int Divergence::isPeriodic(const ivec &dc, const ivec &nc) {
  // Periodic when every dc and nc entry for this axis is zero.
  // Iterates both vectors explicitly; no element may be nonzero.
  for (int i = 0; i < (int)dc.n_elem; i++) {
    if ((dc[i] != 0) || (nc[i] != 0))
      return 0;
  }
  return 1;
}

sp_mat Divergence::periodicDiv1D(u16 k, u32 m, Real dx) {
  assert(!(k % 2));
  assert(k > 1 && k < 9);
  assert(m >= 2 * k);

  // The periodic divergence is the negative transpose of the periodic gradient
  // circulant.  The gradient stencil vector V defines G(i,j) = V[(i-j+m)%m],
  // so the divergence stencil at (i,j) is -V[(j-i+m)%m].
  // Equivalently, define W[d] = -V[(m-d)%m]; then D(i,j) = W[(i-j+m)%m].
  std::vector<Real> V(m, 0.0);
  switch (k) {
  case 2:
    // 2nd-order central difference gradient stencil
    V[1] = 1.0;
    V[2] = -1.0;
    break;

  case 4:
    // 4th-order central difference gradient stencil
    V[0] = -1.0 / 24.0;
    V[1] = 9.0 / 8.0;
    V[2] = -9.0 / 8.0;
    V[3] = 1.0 / 24.0;
    break;

  case 6:
    // 6th-order central difference gradient stencil; wrap-around at V[m-1]
    V[0] = -25.0 / 384.0;
    V[1] = 75.0 / 64.0;
    V[2] = -75.0 / 64.0;
    V[3] = 25.0 / 384.0;
    V[4] = -3.0 / 640.0;
    V[m - 1] = 3.0 / 640.0;
    break;

  case 8:
    // 8th-order central difference gradient stencil; wrap-around at V[m-2],
    // V[m-1]
    V[0] = -245.0 / 3072.0;
    V[1] = 1225.0 / 1024.0;
    V[2] = -1225.0 / 1024.0;
    V[3] = 245.0 / 3072.0;
    V[4] = -49.0 / 5120.0;
    V[5] = 5.0 / 7168.0;
    V[m - 2] = -5.0 / 7168.0;
    V[m - 1] = 49.0 / 5120.0;
    break;
  }

  // Build the m×m divergence matrix: D(i,j) = -V[(j-i+m)%m]
  sp_mat D(m, m);
  for (u32 i = 0; i < m; i++) {
    for (u32 j = 0; j < m; j++) {
      Real val = -V[(j - i + m) % m];
      if (val != 0.0)
        D(i, j) = val;
    }
  }

  D /= dx;
  return D;
}

// ============================================================================
// Non-periodic 1-D Constructor
// ============================================================================

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
    Q = {1.0, 1.0, 1.0, 1.0, 1.0};
    break;

  case 4:
    at(1, 0) = -11.0 / 12.0;
    at(1, 1) = 17.0 / 24.0;
    at(1, 2) = 3.0 / 8.0;
    at(1, 3) = -5.0 / 24.0;
    at(1, 4) = 1.0 / 24.0;
    at(m, m) = 11.0 / 12.0;
    at(m, m - 1) = -17.0 / 24.0;
    at(m, m - 2) = -3.0 / 8.0;
    at(m, m - 3) = 5.0 / 24.0;
    at(m, m - 4) = -1.0 / 24.0;
    for (u32 i = 2; i < m; i++) {
      at(i, i - 2) = 1.0 / 24.0;
      at(i, i - 1) = -9.0 / 8.0;
      at(i, i) = 9.0 / 8.0;
      at(i, i + 1) = -1.0 / 24.0;
    }
    Q = {2186.0 / 1943.0, 2125.0 / 2828.0, 1441.0 / 1240.0,
         648.0 / 673.0,   349.0 / 350.0,   648.0 / 673.0,
         1441.0 / 1240.0, 2125.0 / 2828.0, 2186.0 / 1943.0};
    break;

  case 6:
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
    for (u32 i = 3; i < m - 1; i++) {
      at(i, i - 3) = -3.0 / 640.0;
      at(i, i - 2) = 25.0 / 384.0;
      at(i, i - 1) = -75.0 / 64.0;
      at(i, i) = 75.0 / 64.0;
      at(i, i + 1) = -25.0 / 384.0;
      at(i, i + 2) = 3.0 / 640.0;
    }
    Q = {2383.0 / 2005.0, 929.0 / 2002.0,  887.0 / 531.0,   3124.0 / 5901.0,
         1706.0 / 1457.0, 457.0 / 467.0,   1057.0 / 1061.0, 457.0 / 467.0,
         1706.0 / 1457.0, 3124.0 / 5901.0, 887.0 / 531.0,   929.0 / 2002.0,
         2383.0 / 2005.0};
    break;
  }

  *this /= dx;
}

// Helper: returns an (s+2)×s sparse matrix used as the interior-node
// selector for non-periodic axes.  It is the (s+2)×(s+2) identity with its
// first and last columns removed, leaving only the s interior columns.
static sp_mat trimmedIdentity_cols(u32 s) {
  sp_mat I = speye(s + 2, s + 2);
  I.shed_col(0);
  I.shed_col(s);
  // original last col (s+1) is now at index s after the first shed
  return I; // (s+2)xs
}

// Populates D_m and I for one axis; selects periodic or non-periodic form.
void Divergence::build_divergence(sp_mat &D_m, sp_mat &I, u16 k, u32 dim,
                                  Real delta, int periodic) {
  if (periodic) {
    D_m = periodicDiv1D(k, dim, delta);
    I.eye(dim, dim);
  } else {
    D_m = Divergence(k, dim, delta);
    I = trimmedIdentity_cols(dim);
  }
}

// ============================================================================
// Non-periodic 2-D Constructor
// ============================================================================

Divergence::Divergence(u16 k, u32 m, u32 n, Real dx, Real dy) {
  Divergence Dx(k, m, dx);
  Divergence Dy(k, n, dy);

  sp_mat Im = trimmedIdentity_cols(m);
  sp_mat In = trimmedIdentity_cols(n);

  sp_mat D1 = Utils::spkron(In, Dx);
  sp_mat D2 = Utils::spkron(Dy, Im);

  if (m != n) {
    *this = Utils::spjoin_rows(D1, D2);
  } else {
    sp_mat A1(1, 2), A2(1, 2);
    A1(0, 0) = A2(0, 1) = 1.0;
    *this = Utils::spkron(A1, D1) + Utils::spkron(A2, D2);
  }
}

// ============================================================================
// Non-periodic 3-D Constructor
// ============================================================================

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

  if ((m != n) || (n != o)) {
    *this = Utils::spjoin_rows(Utils::spjoin_rows(D1, D2), D3);
  } else {
    sp_mat A1(1, 3), A2(1, 3), A3(1, 3);
    A1(0, 0) = A2(0, 1) = A3(0, 2) = 1.0;
    *this =
        Utils::spkron(A1, D1) + Utils::spkron(A2, D2) + Utils::spkron(A3, D3);
  }
}

// ============================================================================
// BC-aware 1-D Constructor
// ============================================================================

Divergence::Divergence(u16 k, u32 m, Real dx, const ivec &dc, const ivec &nc)
    : sp_mat() {
  assert(dc.n_elem == 2 && nc.n_elem == 2);

  if (isPeriodic(dc, nc)) {
    // Periodic: produces an m×m matrix; Q is not applicable.
    *this = periodicDiv1D(k, m, dx);
  } else {
    // Non-periodic: produces an (m+2)×(m+1) matrix; carry over weights Q.
    Divergence tmp(k, m, dx);
    this->sp_mat::operator=(tmp);
    Q = tmp.Q;
  }
}

// ============================================================================
// BC-aware 2-D Constructor
// ============================================================================

Divergence::Divergence(u16 k, u32 m, u32 n, Real dx, Real dy, const ivec &dc,
                       const ivec &nc)
    : sp_mat() {
  assert(dc.n_elem == 4 && nc.n_elem == 4);

  // dc/nc index convention: entries [0,1] control the x-axis (left, right),
  // entries [2,3] control the y-axis (bottom, top).
  // An axis is periodic when all of its dc and nc entries are zero.
  const int xPer = isPeriodic(dc.subvec(0, 1), nc.subvec(0, 1));
  const int yPer = isPeriodic(dc.subvec(2, 3), nc.subvec(2, 3));

  sp_mat Dx_m, Dy_m, Im, In;
  build_divergence(Dx_m, Im, k, m, dx, xPer);
  build_divergence(Dy_m, In, k, n, dy, yPer);

  // Assemble the 2-D divergence by joining the x- and y-component blocks.
  // D1 = kron(In, Dx_m) applies Dx along each row of the 2-D grid.
  // D2 = kron(Dy_m, Im) applies Dy along each column of the 2-D grid.
  sp_mat D1 = Utils::spkron(In, Dx_m);
  sp_mat D2 = Utils::spkron(Dy_m, Im);
  *this = Utils::spjoin_rows(D1, D2);
}

// ============================================================================
// BC-aware 3-D Constructor
// ============================================================================

Divergence::Divergence(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz,
                       const ivec &dc, const ivec &nc)
    : sp_mat() {
  assert(dc.n_elem == 6 && nc.n_elem == 6);

  // dc/nc index convention:
  //   [0,1] = left, right  (x-axis)
  //   [2,3] = bottom, top  (y-axis)
  //   [4,5] = front, back  (z-axis)
  // An axis is periodic when all of its dc and nc entries are zero.
  const int xPer = isPeriodic(dc.subvec(0, 1), nc.subvec(0, 1));
  const int yPer = isPeriodic(dc.subvec(2, 3), nc.subvec(2, 3));
  const int zPer = isPeriodic(dc.subvec(4, 5), nc.subvec(4, 5));

  sp_mat Dx_m, Dy_m, Dz_m, Im, In, Io;

  build_divergence(Dx_m, Im, k, m, dx, xPer);
  build_divergence(Dy_m, In, k, n, dy, yPer);
  build_divergence(Dz_m, Io, k, o, dz, zPer);

  // Assemble the 3-D divergence by joining the x-, y-, and z-component blocks.
  // D1 = kron(kron(Io, In), Dx_m) applies Dx along x for each (y,z) slice.
  // D2 = kron(kron(Io, Dy_m), Im) applies Dy along y for each (x,z) slice.
  // D3 = kron(kron(Dz_m, In), Im) applies Dz along z for each (x,y) slice.
  sp_mat D1 = Utils::spkron(Utils::spkron(Io, In), Dx_m);
  sp_mat D2 = Utils::spkron(Utils::spkron(Io, Dy_m), Im);
  sp_mat D3 = Utils::spkron(Utils::spkron(Dz_m, In), Im);

  *this = Utils::spjoin_rows(Utils::spjoin_rows(D1, D2), D3);
}

// ============================================================================
// Accessor
// ============================================================================

vec Divergence::getQ() { return Q; }
