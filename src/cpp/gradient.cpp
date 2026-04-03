/*
* SPDX-License-Identifier: GPL-3.0-or-later
* 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/

/*
 * @file gradient.cpp
 * 
 * @brief Mimetic Gradient Operators
 * 
 * @date 2024/10/15
 * last modified: 2026/03/27 by Jiya Rathi
 *
 */

#include "gradient.h"
#include <vector>

// ============================================================================
// Private helpers
// ============================================================================

int Gradient::isPeriodic(const ivec& dc, const ivec& nc) {
  // Periodic when every dc and nc entry for this axis is zero.
  // Iterates both vectors explicitly; no element may be nonzero.
  for (int i = 0; i < (int)dc.n_elem; i++) {
    if (dc[i] != 0 || nc[i] != 0) return 0;
  }
  return 1;
}

sp_mat Gradient::periodicGrad1D(u16 k, u32 m, Real dx) {
  assert(!(k % 2));
  assert(k > 1 && k < 9);
  assert(m >= 2 * k);

  // Stencil vector V holds the first row of the circulant matrix (0-indexed).
  // Each entry V[d] is the finite-difference weight at offset d from the
  // diagonal.  The full m×m matrix is then G(i,j) = V[(i - j + m) % m].
  std::vector<Real> V(m, 0.0);

  switch (k) {
    case 2:
      // 2nd-order central difference stencil: [-1, 1] at offsets [1, 2]
      V[1] =  1.0;
      V[2] = -1.0;
      break;

    case 4:
      // 4th-order central difference stencil
      V[0] = -1.0 / 24.0;
      V[1] =  9.0 / 8.0;
      V[2] = -9.0 / 8.0;
      V[3] =  1.0 / 24.0;
      break;

    case 6:
      // 6th-order central difference stencil; wrap-around terms at V[m-1]
      V[0] = -25.0 / 384.0;
      V[1] =  75.0 / 64.0;
      V[2] = -75.0 / 64.0;
      V[3] =  25.0 / 384.0;
      V[4] = -3.0  / 640.0;
      V[m - 1] = 3.0 / 640.0;
      break;

    case 8:
      // 8th-order central difference stencil; wrap-around terms at V[m-2], V[m-1]
      V[0] = -245.0 / 3072.0;
      V[1] =  1225.0 / 1024.0;
      V[2] = -1225.0 / 1024.0;
      V[3] =  245.0 / 3072.0;
      V[4] = -49.0  / 5120.0;
      V[5] =   5.0  / 7168.0;
      V[m - 2] =  -5.0 / 7168.0;
      V[m - 1] =  49.0 / 5120.0;
      break;
  }

  // Build the m×m circulant: G(i,j) = V[(i - j + m) % m]
  sp_mat G(m, m);
  for (u32 i = 0; i < m; i++) {
    for (u32 j = 0; j < m; j++) {
      Real val = V[(i - j + m) % m];
      if (val != 0.0) G(i, j) = val;
    }
  }

  G /= dx;
  return G;
}

// ============================================================================
// Non-periodic 1-D Constructor
// ============================================================================

Gradient::Gradient(u16 k, u32 m, Real dx) : sp_mat(m + 1, m + 2) {
  assert(!(k % 2));
  assert(k > 1 && k < 9);
  assert(m >= 2 * k);

  switch (k) {
    case 2:
      at(0, 0) = -8.0 / 3.0;
      at(0, 1) =  3.0;
      at(0, 2) = -1.0 / 3.0;
      at(m, m + 1) =  8.0 / 3.0;
      at(m, m)     = -3.0;
      at(m, m - 1) =  1.0 / 3.0;
      for (u32 i = 1; i < m; i++) {
        at(i, i)     = -1.0;
        at(i, i + 1) =  1.0;
      }
      P = { 3.0/8.0, 9.0/8.0, 1.0, 9.0/8.0, 3.0/8.0 };
      break;

  case 4:
    at(0, 0) = -352.0/105.0;  at(0, 1) =  35.0/8.0;
    at(0, 2) =  -35.0/24.0;  at(0, 3) =  21.0/40.0;  at(0, 4) = -5.0/56.0;
    at(1, 0) =   16.0/105.0; at(1, 1) = -31.0/24.0;
    at(1, 2) =   29.0/24.0;  at(1, 3) =  -3.0/40.0;  at(1, 4) =  1.0/168.0;
    at(m,   m+1) =  352.0/105.0;  at(m,   m)   = -35.0/8.0;
    at(m,   m-1) =   35.0/24.0;  at(m,   m-2) = -21.0/40.0; at(m,   m-3) =  5.0/56.0;
    at(m-1, m+1) =  -16.0/105.0; at(m-1, m)   =  31.0/24.0;
    at(m-1, m-1) =  -29.0/24.0;  at(m-1, m-2) =   3.0/40.0; at(m-1, m-3) = -1.0/168.0;
    for (u32 i = 2; i < m - 1; i++) {
      at(i, i-1) =  1.0/24.0;
      at(i, i)   = -9.0/8.0;
      at(i, i+1) =  9.0/8.0;
      at(i, i+2) = -1.0/24.0;
    }
    P = { 1606.0/4535.0, 941.0/766.0, 1384.0/1541.0, 1371.0/1346.0,
          701.0/700.0, 1371.0/1346.0, 1384.0/1541.0, 941.0/766.0,
          1606.0/4535.0 };
    break;

  case 6:
    at(0, 0) = -13016.0/3465.0; at(0, 1) =  693.0/128.0;
    at(0, 2) =   -385.0/128.0;  at(0, 3) =  693.0/320.0;
    at(0, 4) =   -495.0/448.0;  at(0, 5) =  385.0/1152.0; at(0, 6) = -63.0/1408.0;
    at(1, 0) =    496.0/3465.0; at(1, 1) = -811.0/640.0;
    at(1, 2) =    449.0/384.0;  at(1, 3) =  -29.0/960.0;
    at(1, 4) =    -11.0/448.0;  at(1, 5) =   13.0/1152.0; at(1, 6) = -37.0/21120.0;
    at(2, 0) =     -8.0/385.0;  at(2, 1) =  179.0/1920.0;
    at(2, 2) =   -153.0/128.0;  at(2, 3) =  381.0/320.0;
    at(2, 4) =   -101.0/1344.0; at(2, 5) =    1.0/128.0;  at(2, 6) =  -3.0/7040.0;
    at(m,   m+1) =  13016.0/3465.0; at(m,   m)   = -693.0/128.0;
    at(m,   m-1) =    385.0/128.0;  at(m,   m-2) = -693.0/320.0;
    at(m,   m-3) =    495.0/448.0;  at(m,   m-4) = -385.0/1152.0; at(m,   m-5) = 63.0/1408.0;
    at(m-1, m+1) =   -496.0/3465.0; at(m-1, m)   =  811.0/640.0;
    at(m-1, m-1) =   -449.0/384.0;  at(m-1, m-2) =   29.0/960.0;
    at(m-1, m-3) =     11.0/448.0;  at(m-1, m-4) =  -13.0/1152.0; at(m-1, m-5) = 37.0/21120.0;
    at(m-2, m+1) =      8.0/385.0;  at(m-2, m)   = -179.0/1920.0;
    at(m-2, m-1) =    153.0/128.0;  at(m-2, m-2) = -381.0/320.0;
    at(m-2, m-3) =    101.0/1344.0; at(m-2, m-4) =   -1.0/128.0;  at(m-2, m-5) =  3.0/7040.0;
    for (u32 i = 3; i < m - 2; i++) {
      at(i, i-2) =  -3.0/640.0;
      at(i, i-1) =  25.0/384.0;
      at(i, i)   = -75.0/64.0;
      at(i, i+1) =  75.0/64.0;
      at(i, i+2) = -25.0/384.0;
      at(i, i+3) =   3.0/640.0;
    }
    P = { 420249.0/1331069.0, 2590978.0/1863105.0, 882762.0/1402249.0,
          1677712.0/1359311.0, 239985.0/261097.0,  664189.0/657734.0,
          756049.0/754729.0,  664189.0/657734.0,  239985.0/261097.0,
          1677712.0/1359311.0, 882762.0/1402249.0, 2590978.0/1863105.0,
          420249.0/1331069.0 };
    break;

  case 8:
    at(0, 0) = -4856215.0/1200963.0;  at(0, 1) =  45858154.0/7297397.0;
    at(0, 2) = -23409299.0/4789435.0; at(0, 3) =   3799178.0/719717.0;
    at(0, 4) =  -4892189.0/1089890.0; at(0, 5) =   1789111.0/658879.0;
    at(0, 6) =  -1406819.0/1289899.0; at(0, 7) =   1154863.0/4436807.0;
    at(0, 8) =  -2936602.0/105142673.0;
    at(1, 0) =     86048.0/675675.0;   at(1, 1) = -131093.0/107520.0;
    at(1, 2) =   5503131.0/5166017.0;  at(1, 3) =  305249.0/2136437.0;
    at(1, 4) =  -1763845.0/8250973.0;  at(1, 5) = 1562032.0/10745723.0;
    at(1, 6) =   -270419.0/4422611.0;  at(1, 7) =    2983.0/199680.0;
    at(1, 8) =     -2621.0/1612800.0;
    at(2, 0) =     -3776.0/225225.0;   at(2, 1) =    8707.0/107520.0;
    at(2, 2) =    -17947.0/15360.0;    at(2, 3) =   29319.0/25600.0;
    at(2, 4) =      -533.0/21504.0;    at(2, 5) =    -263.0/9216.0;
    at(2, 6) =       903.0/56320.0;    at(2, 7) =    -283.0/66560.0;
    at(2, 8) =       257.0/537600.0;
    at(3, 0) =        32.0/9009.0;     at(3, 1) =    -543.0/35840.0;
    at(3, 2) =       265.0/3072.0;     at(3, 3) =   -1233.0/1024.0;
    at(3, 4) =      8625.0/7168.0;     at(3, 5) =    -775.0/9216.0;
    at(3, 6) =       639.0/56320.0;    at(3, 7) =     -15.0/13312.0;
    at(3, 8) =         1.0/21504.0;
    at(m,   m+1) =  4856215.0/1200963.0;  at(m,   m)   = -45858154.0/7297397.0;
    at(m,   m-1) = 23409299.0/4789435.0;  at(m,   m-2) =  -3799178.0/719717.0;
    at(m,   m-3) =  4892189.0/1089890.0;  at(m,   m-4) =  -1789111.0/658879.0;
    at(m,   m-5) =  1406819.0/1289899.0;  at(m,   m-6) =  -1154863.0/4436807.0;
    at(m,   m-7) =  2936602.0/105142673.0;
    at(m-1, m+1) =   -86048.0/675675.0;   at(m-1, m)   =  131093.0/107520.0;
    at(m-1, m-1) = -5503131.0/5166017.0;  at(m-1, m-2) = -305249.0/2136437.0;
    at(m-1, m-3) =  1763845.0/8250973.0;  at(m-1, m-4) =-1562032.0/10745723.0;
    at(m-1, m-5) =   270419.0/4422611.0;  at(m-1, m-6) =   -2983.0/199680.0;
    at(m-1, m-7) =     2621.0/1612800.0;
    at(m-2, m+1) =    3776.0/225225.0;    at(m-2, m)   =   -8707.0/107520.0;
    at(m-2, m-1) =   17947.0/15360.0;     at(m-2, m-2) =  -29319.0/25600.0;
    at(m-2, m-3) =     533.0/21504.0;     at(m-2, m-4) =     263.0/9216.0;
    at(m-2, m-5) =    -903.0/56320.0;     at(m-2, m-6) =     283.0/66560.0;
    at(m-2, m-7) =    -257.0/537600.0;
    at(m-3, m+1) =     -32.0/9009.0;      at(m-3, m)   =     543.0/35840.0;
    at(m-3, m-1) =    -265.0/3072.0;      at(m-3, m-2) =    1233.0/1024.0;
    at(m-3, m-3) =   -8625.0/7168.0;      at(m-3, m-4) =     775.0/9216.0;
    at(m-3, m-5) =    -639.0/56320.0;     at(m-3, m-6) =      15.0/13312.0;
    at(m-3, m-7) =      -1.0/21504.0;
    for (u32 i = 4; i < m - 3; i++) {
      at(i, i-3) =    5.0/7168.0;
      at(i, i-2) =  -49.0/5120.0;
      at(i, i-1) =  245.0/3072.0;
      at(i, i)   = -1225.0/1024.0;
      at(i, i+1) =  1225.0/1024.0;
      at(i, i+2) =  -245.0/3072.0;
      at(i, i+3) =    49.0/5120.0;
      at(i, i+4) =    -5.0/7168.0;
    }
    P = { 267425.0/904736.0,   2307435.0/1517812.0, 847667.0/3066027.0,
          4050911.0/2301238.0,  498943.0/1084999.0, 211042.0/170117.0,
          2065895.0/2191686.0, 1262499.0/1258052.0, 1314891.0/1312727.0,
          1262499.0/1258052.0, 2065895.0/2191686.0, 211042.0/170117.0,
          498943.0/1084999.0,  4050911.0/2301238.0, 847667.0/3066027.0,
          2307435.0/1517812.0,  267425.0/904736.0 };
    break;
  }

  *this /= dx;
}

// ============================================================================
// Non-periodic 2-D Constructor
// ============================================================================

Gradient::Gradient(u16 k, u32 m, u32 n, Real dx, Real dy) {
  Gradient Gx(k, m, dx);
  Gradient Gy(k, n, dy);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);
  Im.shed_row(0); Im.shed_row(m);
  In.shed_row(0); In.shed_row(n);

  sp_mat G1 = Utils::spkron(In, Gx);
  sp_mat G2 = Utils::spkron(Gy, Im);

  if (m != n)
    *this = Utils::spjoin_cols(G1, G2);
  else {
    sp_mat A1(2, 1), A2(2, 1);
    A1(0, 0) = A2(1, 0) = 1.0;
    *this = Utils::spkron(A1, G1) + Utils::spkron(A2, G2);
  }
}

// ============================================================================
// Non-periodic 3-D Constructor
// ============================================================================

Gradient::Gradient(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz) {
  Gradient Gx(k, m, dx);
  Gradient Gy(k, n, dy);
  Gradient Gz(k, o, dz);

  sp_mat Im = speye(m + 2, m + 2);
  sp_mat In = speye(n + 2, n + 2);
  sp_mat Io = speye(o + 2, o + 2);
  Im.shed_row(0); Im.shed_row(m);
  In.shed_row(0); In.shed_row(n);
  Io.shed_row(0); Io.shed_row(o);

  sp_mat G1 = Utils::spkron(Utils::spkron(Io, In), Gx);
  sp_mat G2 = Utils::spkron(Utils::spkron(Io, Gy), Im);
  sp_mat G3 = Utils::spkron(Utils::spkron(Gz, In), Im);

  if ((m != n) || (n != o))
    *this = Utils::spjoin_cols(Utils::spjoin_cols(G1, G2), G3);
  else {
    sp_mat A1(3, 1), A2(3, 1), A3(3, 1);
    A1(0, 0) = A2(1, 0) = A3(2, 0) = 1.0;
    *this = Utils::spkron(A1, G1) + Utils::spkron(A2, G2) + Utils::spkron(A3, G3);
  }
}

// ============================================================================
// BC-aware 1-D Constructor
// ============================================================================

Gradient::Gradient(u16 k, u32 m, Real dx, const ivec& dc, const ivec& nc)
    : sp_mat() {
  assert(dc.n_elem == 2 && nc.n_elem == 2);

  if (isPeriodic(dc, nc)) {
    // Periodic: produces an m×m circulant matrix; P is not applicable.
    *this = periodicGrad1D(k, m, dx);
  } else {
    // Non-periodic: produces an (m+1)×(m+2) matrix; carry over weights P.
    Gradient tmp(k, m, dx);
    this->sp_mat::operator=(tmp);
    P = tmp.P;
  }
}

// ============================================================================
// BC-aware 2-D Constructor
// ============================================================================

// Helper: returns an s×(s+2) sparse matrix used as the interior-node
// selector for non-periodic axes.  It is the (s+2)×(s+2) identity with its
// first and last rows removed, leaving only the s interior rows.
static sp_mat trimmedIdentity(u32 s) {
  sp_mat I = speye(s + 2, s + 2);
  I.shed_row(0);
  I.shed_row(s);   // original last row (s+1) is now at index s after the first shed
  return I;        // s×(s+2)
}

Gradient::Gradient(u16 k, u32 m, u32 n, Real dx, Real dy,
                   const ivec& dc, const ivec& nc) : sp_mat() {
  assert(dc.n_elem == 4 && nc.n_elem == 4);

  // dc/nc index convention: entries [0,1] control the x-axis (left, right),
  // entries [2,3] control the y-axis (bottom, top).
  // An axis is periodic when all of its dc and nc entries are zero.
  const int xPer = isPeriodic(dc.subvec(0, 1), nc.subvec(0, 1));
  const int yPer = isPeriodic(dc.subvec(2, 3), nc.subvec(2, 3));

  sp_mat Gx_m, Gy_m, Im, In;

  if (xPer) {
    // Periodic x: m×m circulant gradient; Im is the full m×m identity.
    Gx_m = periodicGrad1D(k, m, dx);
    Im   = speye(m, m);
  } else {
    // Non-periodic x: (m+1)×(m+2) gradient; Im selects the m interior nodes.
    Gx_m = Gradient(k, m, dx);
    Im   = trimmedIdentity(m);
  }

  if (yPer) {
    Gy_m = periodicGrad1D(k, n, dy);
    In   = speye(n, n);
  } else {
    Gy_m = Gradient(k, n, dy);
    In   = trimmedIdentity(n);
  }

  // Assemble the 2-D gradient by stacking the x- and y-component blocks.
  // G1 = kron(In, Gx_m) applies Gx along each row of the 2-D grid.
  // G2 = kron(Gy_m, Im) applies Gy along each column of the 2-D grid.
  sp_mat G1 = Utils::spkron(In, Gx_m);
  sp_mat G2 = Utils::spkron(Gy_m, Im);
  *this = Utils::spjoin_cols(G1, G2);
}

// ============================================================================
// BC-aware 3-D Constructor
// ============================================================================

Gradient::Gradient(u16 k, u32 m, u32 n, u32 o, Real dx, Real dy, Real dz,
                   const ivec& dc, const ivec& nc) : sp_mat() {
  assert(dc.n_elem == 6 && nc.n_elem == 6);

  // dc/nc index convention:
  //   [0,1] = left, right  (x-axis)
  //   [2,3] = bottom, top  (y-axis)
  //   [4,5] = front, back  (z-axis)
  // An axis is periodic when all of its dc and nc entries are zero.
  const int xPer = isPeriodic(dc.subvec(0, 1), nc.subvec(0, 1));
  const int yPer = isPeriodic(dc.subvec(2, 3), nc.subvec(2, 3));
  const int zPer = isPeriodic(dc.subvec(4, 5), nc.subvec(4, 5));

  sp_mat Gx_m, Gy_m, Gz_m, Im, In, Io;

  if (xPer) {
    Gx_m = periodicGrad1D(k, m, dx);
    Im   = speye(m, m);
  } else {
    Gx_m = Gradient(k, m, dx);
    Im   = trimmedIdentity(m);
  }

  if (yPer) {
    Gy_m = periodicGrad1D(k, n, dy);
    In   = speye(n, n);
  } else {
    Gy_m = Gradient(k, n, dy);
    In   = trimmedIdentity(n);
  }

  if (zPer) {
    Gz_m = periodicGrad1D(k, o, dz);
    Io   = speye(o, o);
  } else {
    Gz_m = Gradient(k, o, dz);
    Io   = trimmedIdentity(o);
  }

  // Assemble the 3-D gradient by stacking the x-, y-, and z-component blocks.
  // G1 = kron(kron(Io, In), Gx_m) applies Gx along x for each (y,z) slice.
  // G2 = kron(kron(Io, Gy_m), Im) applies Gy along y for each (x,z) slice.
  // G3 = kron(kron(Gz_m, In), Im) applies Gz along z for each (x,y) slice.
  sp_mat G1 = Utils::spkron(Utils::spkron(Io, In), Gx_m);
  sp_mat G2 = Utils::spkron(Utils::spkron(Io, Gy_m), Im);
  sp_mat G3 = Utils::spkron(Utils::spkron(Gz_m, In), Im);

  *this = Utils::spjoin_cols(Utils::spjoin_cols(G1, G2), G3);
}

// ============================================================================
// Accessor
// ============================================================================

vec Gradient::getP() { return P; }