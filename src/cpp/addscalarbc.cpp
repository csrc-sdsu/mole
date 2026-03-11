/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * 2008-2024 San Diego State University Research Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/**
 * file addscalarbc.cpp
 *
 * brief Implementation of boundary condition application for scalar PDEs
 *
 * date 2025/01/26
 *Last Modified: 2026/03/04
 */

#include "addscalarbc.h"

namespace AddScalarBC {

// ============================================================================
// Internal Helpers
// ============================================================================

namespace {

/**
 * Computes the sum of squares of Dirichlet and Neumann coefficients
 *       for a boundary pair at indices i and j.
 *       Returns > 0 if the boundary is non-periodic.
 */
Real boundaryNorm(const vec &dc, const vec &nc, uword i, uword j) {
    return dc(i)*dc(i) + dc(j)*dc(j) + nc(i)*nc(i) + nc(j)*nc(j);
}

/**
 * Collects unique row indices from all non-zero entries of a sparse matrix.
 */
uvec collectUniqueRows(const sp_mat &M) {
    uvec temp(M.n_nonzero);
    uword count = 0;
    for (sp_mat::const_iterator it = M.begin(); it != M.end(); ++it) {
        temp(count++) = it.row();
    }
    temp.resize(count);
    return unique(temp);
}

/**
 * Zeros out specified rows of a sparse matrix in-place.
 *       Used to remove existing equations at boundary nodes before
 *       replacing them with boundary condition equations.
 */
void zeroRows(sp_mat &A, const uvec &rows) {
    for (uword i = 0; i < rows.n_elem; i++) {
        uword row_idx = rows(i);
        for (sp_mat::const_row_iterator it = A.begin_row(row_idx);
             it != A.end_row(row_idx); ++it) {
            A(it.row(), it.col()) = 0;
        }
    }
}

/**
 * Applies a boundary pair to the system matrix A and RHS vector b.
 */
void applyBCMatrix(sp_mat &A, vec &b, const sp_mat &Abc, uvec &rows) {
    rows = collectUniqueRows(Abc);
    zeroRows(A, rows);
    A = A + Abc;
    b(rows).zeros();
}

/**
 * Updates RHS entries for one side of a boundary pair.
 */
void applyRhsSide(vec &b, const uvec &indices, const vec &values) {
    for (uword i = 0; i < indices.n_elem && i < values.n_elem; i++) {
        b(indices(i)) = values(i);
    }
}

/**
 * Builds a sparse identity matrix of size sz x sz, optionally zeroing
 *       the first and last diagonal entries to exclude ghost nodes.
 */
sp_mat buildIdentity(uword sz, bool zeroCorners = false) {
    sp_mat I = speye<sp_mat>(sz, sz);
    if (zeroCorners && sz >= 2) {
        I(0, 0) = 0;
        I(sz-1, sz-1) = 0;
    }
    return I;
}

/**
 * Groups the data for one boundary pair needed to apply BCs to A and b.
 */
struct BCPairLhs {
    Real     q;       // boundaryNorm result; skip if == 0
    sp_mat  &Mleft;   // BC matrix for the left/bottom/front face
    sp_mat  &Mright;  // BC matrix for the right/top/back face
    uvec    &rowsL;   // output: row indices for left/bottom/front face
    uvec    &rowsR;   // output: row indices for right/top/back face
};

/**
 * Applies one BCPairLhs to the system. For non-periodic boundaries only.
 */
void applyBCPair(sp_mat &A, vec &b, BCPairLhs &p) {
    if (p.q == 0) return;
    uvec rows;
    applyBCMatrix(A, b, p.Mleft + p.Mright, rows);
    p.rowsL = collectUniqueRows(p.Mleft);
    p.rowsR = collectUniqueRows(p.Mright);
}

/**
 * Groups the data for one boundary pair needed to update the RHS vector.
 */
struct BCPairRhs {
    uword       i, j;   // dc/nc indices for boundaryNorm check
    const uvec &rowsL;  // row indices for the left/bottom/front face
    const uvec &rowsR;  // row indices for the right/top/back face
    uword       vL, vR; // indices into the boundary value vector v[]
};

/**
 * Applies the RHS update for a single BCPairRhs.
 * Skips periodic boundaries or missing value vectors.
 */
void applyBCPairRhs(vec &b, const vec &dc, const vec &nc,
                    const std::vector<vec> &v, const BCPairRhs &p) {
    if (boundaryNorm(dc, nc, p.i, p.j) == 0) return;
    if (v.size() <= p.vR) return;
    if (v[p.vL].n_elem > 0) applyRhsSide(b, p.rowsL, v[p.vL]);
    if (v[p.vR].n_elem > 0) applyRhsSide(b, p.rowsR, v[p.vR]);
}

} // anonymous namespace

// ============================================================================
// LHS: Boundary matrix construction (1D, 2D, 3D overloads)
// ============================================================================

void addScalarBClhs(u16 k, u32 m, Real dx,
                    const vec &dc, const vec &nc,
                    sp_mat &Al, sp_mat &Ar) {
    Al = sp_mat(m+2, m+2);
    Ar = sp_mat(m+2, m+2);

    if (dc(0) != 0.0) Al(0, 0) = dc(0);
    if (dc(1) != 0.0) Ar(m+1, m+1) = dc(1);

    if (nc(0) != 0.0 || nc(1) != 0.0) {
        Gradient G(k, m, dx);
        sp_mat G_mat = sp_mat(G);

        if (nc(0) != 0.0) {
            sp_mat Bl(m+2, m+1);
            Bl(0, 0) = -nc(0);
            Al = Al + Bl * G_mat;
        }
        if (nc(1) != 0.0) {
            sp_mat Br(m+2, m+1);
            Br(m+1, m) = nc(1);
            Ar = Ar + Br * G_mat;
        }
    }
}

void addScalarBClhs(u16 k, u32 m, Real dx, u32 n, Real dy,
                    const vec &dc, const vec &nc,
                    sp_mat &Al, sp_mat &Ar, sp_mat &Ab, sp_mat &At) {
    Al.set_size(0, 0); Ar.set_size(0, 0);
    Ab.set_size(0, 0); At.set_size(0, 0);

    Real qrl = boundaryNorm(dc, nc, 0, 1);
    Real qbt = boundaryNorm(dc, nc, 2, 3);

    if (qrl > 0) {
        sp_mat Al0, Ar0;
        addScalarBClhs(k, m, dx, {dc(0), dc(1)}, {nc(0), nc(1)}, Al0, Ar0);

        sp_mat In = (qbt == 0) ? buildIdentity(n)
                               : buildIdentity(n+2, /*zeroCorners=*/true);
        Al = kron(In, Al0);
        Ar = kron(In, Ar0);
    }

    if (qbt > 0) {
        sp_mat Ab0, At0;
        addScalarBClhs(k, n, dy, {dc(2), dc(3)}, {nc(2), nc(3)}, Ab0, At0);

        sp_mat Im = (qrl == 0) ? buildIdentity(m)
                               : buildIdentity(m+2);
        Ab = kron(Ab0, Im);
        At = kron(At0, Im);
    }
}

void addScalarBClhs(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz,
                    const vec &dc, const vec &nc,
                    sp_mat &Al, sp_mat &Ar, sp_mat &Ab,
                    sp_mat &At, sp_mat &Af, sp_mat &Ak) {
    Al.set_size(0,0); Ar.set_size(0,0);
    Ab.set_size(0,0); At.set_size(0,0);
    Af.set_size(0,0); Ak.set_size(0,0);

    Real qrl = boundaryNorm(dc, nc, 0, 1);
    Real qbt = boundaryNorm(dc, nc, 2, 3);
    Real qfk = boundaryNorm(dc, nc, 4, 5);

    auto makeId = [](u32 sz, Real q, bool excludeCorners) -> sp_mat {
        return (q == 0) ? buildIdentity(sz)
                        : buildIdentity(sz + 2, excludeCorners);
    };

    if (qrl > 0) {
        sp_mat Al0, Ar0;
        addScalarBClhs(k, m, dx, {dc(0), dc(1)}, {nc(0), nc(1)}, Al0, Ar0);

        sp_mat In = makeId(n, qbt, /*excludeCorners=*/true);
        sp_mat Io = makeId(o, qfk, /*excludeCorners=*/true);
        Al = kron(kron(Io, In), Al0);
        Ar = kron(kron(Io, In), Ar0);
    }

    if (qbt > 0) {
        sp_mat Ab0, At0;
        addScalarBClhs(k, n, dy, {dc(2), dc(3)}, {nc(2), nc(3)}, Ab0, At0);

        sp_mat Im = makeId(m, qrl, /*excludeCorners=*/false);
        sp_mat Io = makeId(o, qfk, /*excludeCorners=*/true);
        Ab = kron(kron(Io, Ab0), Im);
        At = kron(kron(Io, At0), Im);
    }

    if (qfk > 0) {
        sp_mat Af0, Ak0;
        addScalarBClhs(k, o, dz, {dc(4), dc(5)}, {nc(4), nc(5)}, Af0, Ak0);

        sp_mat Im = makeId(m, qrl, /*excludeCorners=*/false);
        sp_mat In = makeId(n, qbt, /*excludeCorners=*/false);
        Af = kron(kron(Af0, In), Im);
        Ak = kron(kron(Ak0, In), Im);
    }
}

// ============================================================================
// RHS: Boundary value application (1D, 2D, 3D overloads)
// ============================================================================

void addScalarBCrhs(vec &b, const vec &v, const uvec &indices) {
    for (uword i = 0; i < indices.n_elem; i++) {
        b(indices(i)) = v(i);
    }
}

void addScalarBCrhs(vec &b, const vec &dc, const vec &nc,
                    const std::vector<vec> &v,
                    const uvec &rl, const uvec &rr,
                    const uvec &rb, const uvec &rt) {
    const BCPairRhs pairs[] = {
        {0, 1, rl, rr, 0, 1},  // Left  / Right
        {2, 3, rb, rt, 2, 3},  // Bottom / Top
    };
    for (const auto &p : pairs) applyBCPairRhs(b, dc, nc, v, p);
}

void addScalarBCrhs(vec &b, const vec &dc, const vec &nc,
                    const std::vector<vec> &v,
                    const uvec &rl, const uvec &rr, const uvec &rb,
                    const uvec &rt, const uvec &rf, const uvec &rk) {
    const BCPairRhs pairs[] = {
        {0, 1, rl, rr, 0, 1},  // Left  / Right
        {2, 3, rb, rt, 2, 3},  // Bottom / Top
        {4, 5, rf, rk, 4, 5},  // Front  / Back
    };
    for (const auto &p : pairs) applyBCPairRhs(b, dc, nc, v, p);
}

// ============================================================================
// Top-level BC application (1D, 2D, 3D overloads)
// ============================================================================

void addScalarBC(sp_mat &A, vec &b, u16 k, u32 m, Real dx, const BC1D &bc) {
    assert(bc.dc.n_elem == 2 && "dc must be a 2x1 vector");
    assert(bc.nc.n_elem == 2 && "nc must be a 2x1 vector");
    assert(A.n_rows == A.n_cols && "A must be square");
    assert(A.n_cols == b.n_elem && "b size must equal A columns");

    if (boundaryNorm(bc.dc, bc.nc, 0, 1) == 0.0) return;

    assert(bc.v.n_elem == 2 && "v must be a 2x1 vector");

    uvec indices = {0, (uword)(A.n_rows - 1)};
    zeroRows(A, indices);
    b(indices).zeros();

    sp_mat Al, Ar;
    addScalarBClhs(k, m, dx, bc.dc, bc.nc, Al, Ar);
    A = A + Al + Ar;

    addScalarBCrhs(b, bc.v, indices);
}

void addScalarBC(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                 u32 n, Real dy, const BC2D &bc) {
    assert(bc.dc.n_elem == 4 && "dc must be a 4x1 vector");
    assert(bc.nc.n_elem == 4 && "nc must be a 4x1 vector");
    assert(bc.v.size() == 4  && "v must have 4 vectors");
    assert(A.n_rows == A.n_cols && "A must be square");
    assert(A.n_cols == b.n_elem && "b size must equal A columns");

    sp_mat Al, Ar, Ab, At;
    addScalarBClhs(k, m, dx, n, dy, bc.dc, bc.nc, Al, Ar, Ab, At);

    uvec rl, rr, rb, rt;

    BCPairLhs pairs[] = {
        {boundaryNorm(bc.dc, bc.nc, 0, 1), Al, Ar, rl, rr},  // Left  / Right
        {boundaryNorm(bc.dc, bc.nc, 2, 3), Ab, At, rb, rt},  // Bottom / Top
    };
    for (auto &p : pairs) applyBCPair(A, b, p);

    addScalarBCrhs(b, bc.dc, bc.nc, bc.v, rl, rr, rb, rt);
}

void addScalarBC(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                 u32 n, Real dy, u32 o, Real dz, const BC3D &bc) {
    assert(bc.dc.n_elem == 6 && "dc must be a 6x1 vector");
    assert(bc.nc.n_elem == 6 && "nc must be a 6x1 vector");
    assert(bc.v.size() == 6  && "v must have 6 vectors");
    assert(A.n_rows == A.n_cols && "A must be square");
    assert(A.n_cols == b.n_elem && "b size must equal A columns");

    sp_mat Al, Ar, Ab, At, Af, Ak;
    addScalarBClhs(k, m, dx, n, dy, o, dz, bc.dc, bc.nc,
                   Al, Ar, Ab, At, Af, Ak);

    uvec rl, rr, rb, rt, rf, rk;

    BCPairLhs pairs[] = {
        {boundaryNorm(bc.dc, bc.nc, 0, 1), Al, Ar, rl, rr},  // Left  / Right
        {boundaryNorm(bc.dc, bc.nc, 2, 3), Ab, At, rb, rt},  // Bottom / Top
        {boundaryNorm(bc.dc, bc.nc, 4, 5), Af, Ak, rf, rk},  // Front  / Back
    };
    for (auto &p : pairs) applyBCPair(A, b, p);

    addScalarBCrhs(b, bc.dc, bc.nc, bc.v, rl, rr, rb, rt, rf, rk);
}

} // namespace AddScalarBC