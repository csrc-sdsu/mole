/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * © 2008-2024 San Diego State University Research Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/**
 * @file addscalarbc.cpp
 *
 * @brief Implementation of boundary condition application for scalar PDEs
 *
 * @date 2025/01/26
 */

#include "addscalarbc.h"

namespace AddScalarBC {

// ============================================================================
// 1D Boundary Condition Implementation
// ============================================================================

void addScalarBC1Dlhs(u16 k, u32 m, Real dx, const vec &dc, const vec &nc,
                      sp_mat &Al, sp_mat &Ar) {
    // Initialize sparse matrices
    Al = sp_mat(m+2, m+2);
    Ar = sp_mat(m+2, m+2);

    // Dirichlet coefficients
    if (dc(0) != 0.0) Al(0, 0) = dc(0);
    if (dc(1) != 0.0) Ar(m+1, m+1) = dc(1);

    // Neumann coefficients (requires gradient operator)
    sp_mat Bl(m+2, m+1);
    sp_mat Br(m+2, m+1);

    if (nc(0) != 0.0 || nc(1) != 0.0) {
        Gradient G(k, m, dx);
        sp_mat G_mat = sp_mat(G);  // Cast Gradient to sp_mat

        if (nc(0) != 0.0) Bl(0, 0) = -nc(0);
        if (nc(1) != 0.0) Br(m+1, m) = nc(1);

        // Robin coefficients
        Al = Al + Bl * G_mat;
        Ar = Ar + Br * G_mat;
    }
}

void addScalarBC1Drhs(vec &b, const vec &v, const uvec &vec_indices) {
    // Set boundary values in RHS
    for (uword i = 0; i < vec_indices.n_elem; i++) {
        b(vec_indices(i)) = v(i);
    }
}

void addScalarBC1D(sp_mat &A, vec &b, u16 k, u32 m, Real dx, const BC1D &bc) {
    // Verify input sizes
    assert(bc.dc.n_elem == 2 && "dc must be a 2x1 vector");
    assert(bc.nc.n_elem == 2 && "nc must be a 2x1 vector");
    assert(A.n_rows == A.n_cols && "A must be square");
    assert(A.n_cols == b.n_elem && "b size must equal A columns");

    // Check if non-periodic boundary conditions exist
    Real q = bc.dc(0)*bc.dc(0) + bc.dc(1)*bc.dc(1) +
             bc.nc(0)*bc.nc(0) + bc.nc(1)*bc.nc(1);

    if (q > 0) {
        // Verify boundary value size for non-periodic case
        assert(bc.v.n_elem == 2 && "v must be a 2x1 vector");

        // Indices to modify (first and last rows)
        uvec vec_indices = {0, (uword)(A.n_rows-1)};

        // Extract rows to be zeroed
        sp_mat A_temp(vec_indices.n_elem, A.n_cols);
        for (uword i = 0; i < vec_indices.n_elem; i++) {
            A_temp.row(i) = A.row(vec_indices(i));
        }

        // Remove first and last rows of A
        for (uword i = 0; i < vec_indices.n_elem; i++) {
            uword row_idx = vec_indices(i);
            for (sp_mat::const_row_iterator it = A.begin_row(row_idx);
                 it != A.end_row(row_idx); ++it) {
                A(it.row(), it.col()) = 0;
            }
        }

        // Remove first and last coefficients of RHS
        b(vec_indices).zeros();

        // Get boundary condition modifications
        sp_mat Abcl, Abcr;
        addScalarBC1Dlhs(k, m, dx, bc.dc, bc.nc, Abcl, Abcr);

        // Add boundary modifications to A
        A = A + Abcl + Abcr;

        // Update RHS with boundary values
        addScalarBC1Drhs(b, bc.v, vec_indices);
    }
}

// ============================================================================
// 2D Boundary Condition Implementation
// ============================================================================

void addScalarBC2Dlhs(u16 k, u32 m, Real dx, u32 n, Real dy,
                      const vec &dc, const vec &nc,
                      sp_mat &Abcl, sp_mat &Abcr, sp_mat &Abcb, sp_mat &Abct) {
    // Initialize to zero (periodic case)
    Abcl.set_size(0, 0);
    Abcr.set_size(0, 0);
    Abcb.set_size(0, 0);
    Abct.set_size(0, 0);

    // Check if left/right boundaries are non-periodic
    Real qrl = dc(0)*dc(0) + dc(1)*dc(1) + nc(0)*nc(0) + nc(1)*nc(1);

    // Check if bottom/top boundaries are non-periodic
    Real qbt = dc(2)*dc(2) + dc(3)*dc(3) + nc(2)*nc(2) + nc(3)*nc(3);

    // Process left and right edges
    if (qrl > 0) {
        vec dc_lr = {dc(0), dc(1)};
        vec nc_lr = {nc(0), nc(1)};
        sp_mat Abcl0, Abcr0;
        addScalarBC1Dlhs(k, m, dx, dc_lr, nc_lr, Abcl0, Abcr0);

        sp_mat In;
        if (qbt == 0) {
            // Periodic in y-direction
            In = speye<sp_mat>(n, n);
        } else {
            // Non-periodic in y-direction
            In = speye<sp_mat>(n+2, n+2);
            In(0, 0) = 0;
            In(n+1, n+1) = 0;
        }

        // Kronecker product for 2D
        Abcl = kron(In, Abcl0);
        Abcr = kron(In, Abcr0);
    }

    // Process bottom and top edges
    if (qbt > 0) {
        vec dc_bt = {dc(2), dc(3)};
        vec nc_bt = {nc(2), nc(3)};
        sp_mat Abcb0, Abct0;
        addScalarBC1Dlhs(k, n, dy, dc_bt, nc_bt, Abcb0, Abct0);

        sp_mat Im;
        if (qrl == 0) {
            // Periodic in x-direction
            Im = speye<sp_mat>(m, m);
        } else {
            // Non-periodic in x-direction
            Im = speye<sp_mat>(m+2, m+2);
        }

        // Kronecker product for 2D
        Abcb = kron(Abcb0, Im);
        Abct = kron(Abct0, Im);
    }
}

void addScalarBC2Drhs(vec &b, const vec &dc, const vec &nc,
                      const std::vector<vec> &v,
                      const uvec &rl, const uvec &rr,
                      const uvec &rb, const uvec &rt) {
    // Check if left/right boundaries are non-periodic
    Real qrl = dc(0)*dc(0) + dc(1)*dc(1) + nc(0)*nc(0) + nc(1)*nc(1);

    if (qrl > 0 && v.size() >= 2) {
        // Left boundary
        if (v[0].n_elem > 0) {
            for (uword i = 0; i < rl.n_elem && i < v[0].n_elem; i++) {
                b(rl(i)) = v[0](i);
            }
        }
        // Right boundary
        if (v[1].n_elem > 0) {
            for (uword i = 0; i < rr.n_elem && i < v[1].n_elem; i++) {
                b(rr(i)) = v[1](i);
            }
        }
    }

    // Check if bottom/top boundaries are non-periodic
    Real qbt = dc(2)*dc(2) + dc(3)*dc(3) + nc(2)*nc(2) + nc(3)*nc(3);

    if (qbt > 0 && v.size() >= 4) {
        // Bottom boundary
        if (v[2].n_elem > 0) {
            for (uword i = 0; i < rb.n_elem && i < v[2].n_elem; i++) {
                b(rb(i)) = v[2](i);
            }
        }
        // Top boundary
        if (v[3].n_elem > 0) {
            for (uword i = 0; i < rt.n_elem && i < v[3].n_elem; i++) {
                b(rt(i)) = v[3](i);
            }
        }
    }
}

void addScalarBC2D(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                   u32 n, Real dy, const BC2D &bc) {
    // Verify input sizes
    assert(bc.dc.n_elem == 4 && "dc must be a 4x1 vector");
    assert(bc.nc.n_elem == 4 && "nc must be a 4x1 vector");
    assert(bc.v.size() == 4 && "v must have 4 vectors");
    assert(A.n_rows == A.n_cols && "A must be square");
    assert(A.n_cols == b.n_elem && "b size must equal A columns");

    // Check if boundaries are non-periodic
    Real qrl = bc.dc(0)*bc.dc(0) + bc.dc(1)*bc.dc(1) +
               bc.nc(0)*bc.nc(0) + bc.nc(1)*bc.nc(1);
    Real qbt = bc.dc(2)*bc.dc(2) + bc.dc(3)*bc.dc(3) +
               bc.nc(2)*bc.nc(2) + bc.nc(3)*bc.nc(3);

    uvec rl, rr, rb, rt;  // Indices for boundaries

    // Get modifications for left, right, bottom, top edges
    sp_mat Abcl, Abcr, Abcb, Abct;
    addScalarBC2Dlhs(k, m, dx, n, dy, bc.dc, bc.nc, Abcl, Abcr, Abcb, Abct);

    // Process left/right boundaries
    if (qrl > 0) {
        // Get unique row indices from boundary matrices
        uvec rl_temp, rr_temp;
        sp_mat Abc1 = Abcl + Abcr;

        for (sp_mat::const_iterator it = Abc1.begin(); it != Abc1.end(); ++it) {
            rl_temp.resize(rl_temp.n_elem + 1);
            rl_temp(rl_temp.n_elem - 1) = it.row();
        }
        uvec rowsbc1 = unique(rl_temp);

        // Find rows from Abcl and Abcr
        for (sp_mat::const_iterator it = Abcl.begin(); it != Abcl.end(); ++it) {
            rl.resize(rl.n_elem + 1);
            rl(rl.n_elem - 1) = it.row();
        }
        for (sp_mat::const_iterator it = Abcr.begin(); it != Abcr.end(); ++it) {
            rr.resize(rr.n_elem + 1);
            rr(rr.n_elem - 1) = it.row();
        }
        rl = unique(rl);
        rr = unique(rr);

        // Zero out rows in A that will be replaced
        for (uword i = 0; i < rowsbc1.n_elem; i++) {
            uword row_idx = rowsbc1(i);
            for (sp_mat::const_row_iterator it = A.begin_row(row_idx);
                 it != A.end_row(row_idx); ++it) {
                A(it.row(), it.col()) = 0;
            }
        }

        // Add boundary modifications
        A = A + Abc1;

        // Zero out corresponding RHS entries
        b(rowsbc1).zeros();
    }

    // Process bottom/top boundaries
    if (qbt > 0) {
        uvec rb_temp, rt_temp;
        sp_mat Abc2 = Abcb + Abct;

        for (sp_mat::const_iterator it = Abc2.begin(); it != Abc2.end(); ++it) {
            rb_temp.resize(rb_temp.n_elem + 1);
            rb_temp(rb_temp.n_elem - 1) = it.row();
        }
        uvec rowsbc2 = unique(rb_temp);

        // Find rows from Abcb and Abct
        for (sp_mat::const_iterator it = Abcb.begin(); it != Abcb.end(); ++it) {
            rb.resize(rb.n_elem + 1);
            rb(rb.n_elem - 1) = it.row();
        }
        for (sp_mat::const_iterator it = Abct.begin(); it != Abct.end(); ++it) {
            rt.resize(rt.n_elem + 1);
            rt(rt.n_elem - 1) = it.row();
        }
        rb = unique(rb);
        rt = unique(rt);

        // Zero out rows in A that will be replaced
        for (uword i = 0; i < rowsbc2.n_elem; i++) {
            uword row_idx = rowsbc2(i);
            for (sp_mat::const_row_iterator it = A.begin_row(row_idx);
                 it != A.end_row(row_idx); ++it) {
                A(it.row(), it.col()) = 0;
            }
        }

        // Add boundary modifications
        A = A + Abc2;

        // Zero out corresponding RHS entries
        b(rowsbc2).zeros();
    }

    // Update RHS with boundary values
    if (qrl > 0 || qbt > 0) {
        addScalarBC2Drhs(b, bc.dc, bc.nc, bc.v, rl, rr, rb, rt);
    }
}

// ============================================================================
// 3D Boundary Condition Implementation
// ============================================================================

void addScalarBC3Dlhs(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz,
                      const vec &dc, const vec &nc,
                      sp_mat &Abcl, sp_mat &Abcr, sp_mat &Abcb,
                      sp_mat &Abct, sp_mat &Abcf, sp_mat &Abck) {
    // Implementation follows the same pattern as 2D but extended to 3D
    // Initialize to zero (periodic case)
    Abcl.set_size(0, 0);
    Abcr.set_size(0, 0);
    Abcb.set_size(0, 0);
    Abct.set_size(0, 0);
    Abcf.set_size(0, 0);
    Abck.set_size(0, 0);

    // Check which boundaries are non-periodic
    Real qrl = dc(0)*dc(0) + dc(1)*dc(1) + nc(0)*nc(0) + nc(1)*nc(1);
    Real qbt = dc(2)*dc(2) + dc(3)*dc(3) + nc(2)*nc(2) + nc(3)*nc(3);
    Real qfk = dc(4)*dc(4) + dc(5)*dc(5) + nc(4)*nc(4) + nc(5)*nc(5);

    // Determine grid sizes based on boundary types
    u32 mx = (qrl > 0) ? m + 2 : m;
    u32 ny = (qbt > 0) ? n + 2 : n;
    u32 oz = (qfk > 0) ? o + 2 : o;

    // Process left/right faces (x-direction)
    if (qrl > 0) {
        vec dc_lr = {dc(0), dc(1)};
        vec nc_lr = {nc(0), nc(1)};
        sp_mat Abcl0, Abcr0;
        addScalarBC1Dlhs(k, m, dx, dc_lr, nc_lr, Abcl0, Abcr0);

        // Create identity matrices for y and z directions
        sp_mat In, Io;
        if (qbt == 0) {
            In = speye<sp_mat>(n, n);
        } else {
            In = speye<sp_mat>(n+2, n+2);
            In(0, 0) = 0;
            In(n+1, n+1) = 0;
        }
        if (qfk == 0) {
            Io = speye<sp_mat>(o, o);
        } else {
            Io = speye<sp_mat>(o+2, o+2);
            Io(0, 0) = 0;
            Io(o+1, o+1) = 0;
        }

        // Left and right faces
        Abcl = kron(kron(Io, In), Abcl0);
        Abcr = kron(kron(Io, In), Abcr0);
    }

    // Process bottom/top faces (y-direction)
    if (qbt > 0) {
        vec dc_bt = {dc(2), dc(3)};
        vec nc_bt = {nc(2), nc(3)};
        sp_mat Abcb0, Abct0;
        addScalarBC1Dlhs(k, n, dy, dc_bt, nc_bt, Abcb0, Abct0);

        // Create identity matrices for x and z directions
        sp_mat Im, Io;
        if (qrl == 0) {
            Im = speye<sp_mat>(m, m);
        } else {
            Im = speye<sp_mat>(m+2, m+2);
        }
        if (qfk == 0) {
            Io = speye<sp_mat>(o, o);
        } else {
            Io = speye<sp_mat>(o+2, o+2);
            Io(0, 0) = 0;
            Io(o+1, o+1) = 0;
        }

        // Bottom and top faces
        Abcb = kron(kron(Io, Abcb0), Im);
        Abct = kron(kron(Io, Abct0), Im);
    }

    // Process front/back faces (z-direction)
    if (qfk > 0) {
        vec dc_fk = {dc(4), dc(5)};
        vec nc_fk = {nc(4), nc(5)};
        sp_mat Abcf0, Abck0;
        addScalarBC1Dlhs(k, o, dz, dc_fk, nc_fk, Abcf0, Abck0);

        // Create identity matrices for x and y directions
        sp_mat Im, In;
        if (qrl == 0) {
            Im = speye<sp_mat>(m, m);
        } else {
            Im = speye<sp_mat>(m+2, m+2);
        }
        if (qbt == 0) {
            In = speye<sp_mat>(n, n);
        } else {
            In = speye<sp_mat>(n+2, n+2);
        }

        // Front and back faces
        Abcf = kron(kron(Abcf0, In), Im);
        Abck = kron(kron(Abck0, In), Im);
    }
}

void addScalarBC3Drhs(vec &b, const vec &dc, const vec &nc,
                      const std::vector<vec> &v,
                      const uvec &rl, const uvec &rr, const uvec &rb,
                      const uvec &rt, const uvec &rf, const uvec &rk) {
    // Check boundaries and update RHS
    Real qrl = dc(0)*dc(0) + dc(1)*dc(1) + nc(0)*nc(0) + nc(1)*nc(1);
    Real qbt = dc(2)*dc(2) + dc(3)*dc(3) + nc(2)*nc(2) + nc(3)*nc(3);
    Real qfk = dc(4)*dc(4) + dc(5)*dc(5) + nc(4)*nc(4) + nc(5)*nc(5);

    if (qrl > 0 && v.size() >= 2) {
        if (v[0].n_elem > 0) {
            for (uword i = 0; i < rl.n_elem && i < v[0].n_elem; i++) {
                b(rl(i)) = v[0](i);
            }
        }
        if (v[1].n_elem > 0) {
            for (uword i = 0; i < rr.n_elem && i < v[1].n_elem; i++) {
                b(rr(i)) = v[1](i);
            }
        }
    }

    if (qbt > 0 && v.size() >= 4) {
        if (v[2].n_elem > 0) {
            for (uword i = 0; i < rb.n_elem && i < v[2].n_elem; i++) {
                b(rb(i)) = v[2](i);
            }
        }
        if (v[3].n_elem > 0) {
            for (uword i = 0; i < rt.n_elem && i < v[3].n_elem; i++) {
                b(rt(i)) = v[3](i);
            }
        }
    }

    if (qfk > 0 && v.size() >= 6) {
        if (v[4].n_elem > 0) {
            for (uword i = 0; i < rf.n_elem && i < v[4].n_elem; i++) {
                b(rf(i)) = v[4](i);
            }
        }
        if (v[5].n_elem > 0) {
            for (uword i = 0; i < rk.n_elem && i < v[5].n_elem; i++) {
                b(rk(i)) = v[5](i);
            }
        }
    }
}

void addScalarBC3D(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                   u32 n, Real dy, u32 o, Real dz, const BC3D &bc) {
    // Verify input sizes
    assert(bc.dc.n_elem == 6 && "dc must be a 6x1 vector");
    assert(bc.nc.n_elem == 6 && "nc must be a 6x1 vector");
    assert(bc.v.size() == 6 && "v must have 6 vectors");
    assert(A.n_rows == A.n_cols && "A must be square");
    assert(A.n_cols == b.n_elem && "b size must equal A columns");

    // Check which boundaries are non-periodic
    Real qrl = bc.dc(0)*bc.dc(0) + bc.dc(1)*bc.dc(1) +
               bc.nc(0)*bc.nc(0) + bc.nc(1)*bc.nc(1);
    Real qbt = bc.dc(2)*bc.dc(2) + bc.dc(3)*bc.dc(3) +
               bc.nc(2)*bc.nc(2) + bc.nc(3)*bc.nc(3);
    Real qfk = bc.dc(4)*bc.dc(4) + bc.dc(5)*bc.dc(5) +
               bc.nc(4)*bc.nc(4) + bc.nc(5)*bc.nc(5);

    uvec rl, rr, rb, rt, rf, rk;

    // Get boundary modifications
    sp_mat Abcl, Abcr, Abcb, Abct, Abcf, Abck;
    addScalarBC3Dlhs(k, m, dx, n, dy, o, dz, bc.dc, bc.nc,
                     Abcl, Abcr, Abcb, Abct, Abcf, Abck);

    // Process each boundary pair similarly to 2D
    // Left/right boundaries
    if (qrl > 0) {
        sp_mat Abc1 = Abcl + Abcr;
        uvec temp;
        for (sp_mat::const_iterator it = Abc1.begin(); it != Abc1.end(); ++it) {
            temp.resize(temp.n_elem + 1);
            temp(temp.n_elem - 1) = it.row();
        }
        uvec rowsbc1 = unique(temp);

        for (sp_mat::const_iterator it = Abcl.begin(); it != Abcl.end(); ++it) {
            rl.resize(rl.n_elem + 1);
            rl(rl.n_elem - 1) = it.row();
        }
        for (sp_mat::const_iterator it = Abcr.begin(); it != Abcr.end(); ++it) {
            rr.resize(rr.n_elem + 1);
            rr(rr.n_elem - 1) = it.row();
        }
        rl = unique(rl);
        rr = unique(rr);

        for (uword i = 0; i < rowsbc1.n_elem; i++) {
            for (sp_mat::const_row_iterator it = A.begin_row(rowsbc1(i));
                 it != A.end_row(rowsbc1(i)); ++it) {
                A(it.row(), it.col()) = 0;
            }
        }
        A = A + Abc1;
        b(rowsbc1).zeros();
    }

    // Bottom/top boundaries
    if (qbt > 0) {
        sp_mat Abc2 = Abcb + Abct;
        uvec temp;
        for (sp_mat::const_iterator it = Abc2.begin(); it != Abc2.end(); ++it) {
            temp.resize(temp.n_elem + 1);
            temp(temp.n_elem - 1) = it.row();
        }
        uvec rowsbc2 = unique(temp);

        for (sp_mat::const_iterator it = Abcb.begin(); it != Abcb.end(); ++it) {
            rb.resize(rb.n_elem + 1);
            rb(rb.n_elem - 1) = it.row();
        }
        for (sp_mat::const_iterator it = Abct.begin(); it != Abct.end(); ++it) {
            rt.resize(rt.n_elem + 1);
            rt(rt.n_elem - 1) = it.row();
        }
        rb = unique(rb);
        rt = unique(rt);

        for (uword i = 0; i < rowsbc2.n_elem; i++) {
            for (sp_mat::const_row_iterator it = A.begin_row(rowsbc2(i));
                 it != A.end_row(rowsbc2(i)); ++it) {
                A(it.row(), it.col()) = 0;
            }
        }
        A = A + Abc2;
        b(rowsbc2).zeros();
    }

    // Front/back boundaries
    if (qfk > 0) {
        sp_mat Abc3 = Abcf + Abck;
        uvec temp;
        for (sp_mat::const_iterator it = Abc3.begin(); it != Abc3.end(); ++it) {
            temp.resize(temp.n_elem + 1);
            temp(temp.n_elem - 1) = it.row();
        }
        uvec rowsbc3 = unique(temp);

        for (sp_mat::const_iterator it = Abcf.begin(); it != Abcf.end(); ++it) {
            rf.resize(rf.n_elem + 1);
            rf(rf.n_elem - 1) = it.row();
        }
        for (sp_mat::const_iterator it = Abck.begin(); it != Abck.end(); ++it) {
            rk.resize(rk.n_elem + 1);
            rk(rk.n_elem - 1) = it.row();
        }
        rf = unique(rf);
        rk = unique(rk);

        for (uword i = 0; i < rowsbc3.n_elem; i++) {
            for (sp_mat::const_row_iterator it = A.begin_row(rowsbc3(i));
                 it != A.end_row(rowsbc3(i)); ++it) {
                A(it.row(), it.col()) = 0;
            }
        }
        A = A + Abc3;
        b(rowsbc3).zeros();
    }

    // Update RHS with boundary values
    if (qrl > 0 || qbt > 0 || qfk > 0) {
        addScalarBC3Drhs(b, bc.dc, bc.nc, bc.v, rl, rr, rb, rt, rf, rk);
    }
}

} // namespace AddScalarBC
