/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * 2008-2024 San Diego State University Research Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/**
 * @file addscalarbc.h
 *
 * @brief Boundary Condition Application for Scalar PDEs
 *
 * This file provides functions to add boundary conditions to discrete
 * operators and right-hand side vectors for 1D, 2D, and 3D scalar PDEs.
 *
 * Supports:
 * - Dirichlet boundary conditions (a0 ≠ 0, b0 = 0)
 * - Neumann boundary conditions (a0 = 0, b0 ≠ 0)
 * - Robin boundary conditions (a0 ≠ 0, b0 ≠ 0)
 * - Periodic boundary conditions (a0 = 0, b0 = 0)
 *
 * date 2025/01/26
 * date modified 2026/02/26
 */

#ifndef ADDSCALARBC_H
#define ADDSCALARBC_H

#include "utils.h"
#include "gradient.h"
#include <vector>
#include <cassert>

using namespace arma;

namespace AddScalarBC {

/**
 * @brief Structure to hold boundary condition data for 1D problems
 *
 * Represents boundary condition: a0*u + b0*du/dn = g
 */
struct BC1D {
    vec dc;  // Dirichlet coefficients a0 (2x1: left, right)
    vec nc;  // Neumann coefficients b0 (2x1: left, right)
    vec v;   // Boundary values g (2x1: left, right)

    BC1D() : dc(2, fill::zeros), nc(2, fill::zeros), v(2, fill::zeros) {}
};

/**
 * @brief Structure to hold boundary condition data for 2D problems
 *
 * Represents boundary condition: a0*u + b0*du/dn = g
 */
struct BC2D {
    vec dc;              // Dirichlet coefficients a0 (4x1: left, right, bottom, top)
    vec nc;              // Neumann coefficients b0 (4x1: left, right, bottom, top)
    std::vector<vec> v;  // Boundary values g (4 vectors: left, right, bottom, top)

    BC2D() : dc(4, fill::zeros), nc(4, fill::zeros), v(4) {}
};

/**
 * @brief Structure to hold boundary condition data for 3D problems
 *
 * Represents boundary condition: a0*u + b0*du/dn = g
 */
struct BC3D {
    vec dc;              // Dirichlet coefficients a0 (6x1: left, right, bottom, top, front, back)
    vec nc;              // Neumann coefficients b0 (6x1: left, right, bottom, top, front, back)
    std::vector<vec> v;  // Boundary values g (6 vectors: left, right, bottom, top, front, back)

    BC3D() : dc(6, fill::zeros), nc(6, fill::zeros), v(6) {}
};

// ============================================================================
// LHS: Boundary matrix construction (1D, 2D, 3D overloads)
// ============================================================================

/**
 * @brief Compute LHS boundary condition matrices for a 1D problem
 *
 * @param k    Order of accuracy
 * @param m    Number of cells
 * @param dx   Cell spacing
 * @param dc   Dirichlet coefficients (2x1: left, right)
 * @param nc   Neumann coefficients (2x1: left, right)
 * @param Al   Output: left boundary modification matrix
 * @param Ar   Output: right boundary modification matrix
 */
void addScalarBClhs(u16 k, u32 m, Real dx,
                    const vec &dc, const vec &nc,
                    sp_mat &Al, sp_mat &Ar);

/**
 * brief Compute LHS boundary condition matrices for a 2D problem
 *
 * @param k    Order of accuracy
 * @param m    Number of cells in x-direction
 * @param dx   Cell spacing in x-direction
 * @param n    Number of cells in y-direction
 * @param dy   Cell spacing in y-direction
 * @param dc   Dirichlet coefficients (4x1: left, right, bottom, top)
 * @param nc   Neumann coefficients (4x1: left, right, bottom, top)
 * @param Al   Output: left edge modification matrix
 * @param Ar   Output: right edge modification matrix
 * @param Ab   Output: bottom edge modification matrix
 * @param At   Output: top edge modification matrix
 */
void addScalarBClhs(u16 k, u32 m, Real dx, u32 n, Real dy,
                    const vec &dc, const vec &nc,
                    sp_mat &Al, sp_mat &Ar, sp_mat &Ab, sp_mat &At);

/**
 * brief Compute LHS boundary condition matrices for a 3D problem
 *
 * @param k    Order of accuracy
 * @param m    Number of cells in x-direction
 * @param dx   Cell spacing in x-direction
 * @param n    Number of cells in y-direction
 * @param dy   Cell spacing in y-direction
 * @param o    Number of cells in z-direction
 * @param dz   Cell spacing in z-direction
 * @param dc   Dirichlet coefficients (6x1: left, right, bottom, top, front, back)
 * @param nc   Neumann coefficients (6x1: left, right, bottom, top, front, back)
 * @param Al   Output: left face modification matrix
 * @param Ar   Output: right face modification matrix
 * @param Ab   Output: bottom face modification matrix
 * @param At   Output: top face modification matrix
 * @param Af   Output: front face modification matrix
 * @param Ak   Output: back face modification matrix
 */
void addScalarBClhs(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz,
                    const vec &dc, const vec &nc,
                    sp_mat &Al, sp_mat &Ar, sp_mat &Ab,
                    sp_mat &At, sp_mat &Af, sp_mat &Ak);

// ============================================================================
// RHS: Boundary value application (1D, 2D, 3D overloads)
// ============================================================================

/**
 * @brief Apply boundary values to the RHS vector for a 1D problem
 *
 * @param b        Right-hand side vector (modified in place)
 * @param v        Boundary values (2x1: left, right)
 * @param indices  Row indices to update
 */
void addScalarBCrhs(vec &b, const vec &v, const uvec &indices);

/**
 * brief Apply boundary values to the RHS vector for a 2D problem
 *
 * @param b    Right-hand side vector (modified in place)
 * @param dc   Dirichlet coefficients (4x1: left, right, bottom, top)
 * @param nc   Neumann coefficients (4x1: left, right, bottom, top)
 * @param v    Boundary values (4 vectors: left, right, bottom, top)
 * @param rl   Left edge row indices
 * @param rr   Right edge row indices
 * @param rb   Bottom edge row indices
 * @param rt   Top edge row indices
 */
void addScalarBCrhs(vec &b, const vec &dc, const vec &nc,
                    const std::vector<vec> &v,
                    const uvec &rl, const uvec &rr,
                    const uvec &rb, const uvec &rt);

/**
 * @brief Apply boundary values to the RHS vector for a 3D problem
 *
 * @param b    Right-hand side vector (modified in place)
 * @param dc   Dirichlet coefficients (6x1: left, right, bottom, top, front, back)
 * @param nc   Neumann coefficients (6x1: left, right, bottom, top, front, back)
 * @param v    Boundary values (6 vectors: left, right, bottom, top, front, back)
 * @param rl   Left face row indices
 * @param rr   Right face row indices
 * @param rb   Bottom face row indices
 * @param rt   Top face row indices
 * @param rf   Front face row indices
 * @param rk   Back face row indices
 */
void addScalarBCrhs(vec &b, const vec &dc, const vec &nc,
                    const std::vector<vec> &v,
                    const uvec &rl, const uvec &rr, const uvec &rb,
                    const uvec &rt, const uvec &rf, const uvec &rk);

// ============================================================================
// Top-level BC application (1D, 2D, 3D overloads)
// ============================================================================

/**
 * @brief Apply boundary conditions to a 1D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to enforce boundary conditions.
 *
 * @param A    Linear operator (modified in place)
 * @param b    Right-hand side vector (modified in place)
 * @param k    Order of accuracy
 * @param m    Number of cells
 * @param dx   Cell spacing
 * @param bc   Boundary condition data
 */
void addScalarBC(sp_mat &A, vec &b, u16 k, u32 m, Real dx, const BC1D &bc);

/**
 * @brief Apply boundary conditions to a 2D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to enforce boundary conditions.
 *
 * @param A    Linear operator (modified in place)
 * @param b    Right-hand side vector (modified in place)
 * @param k    Order of accuracy
 * @param m    Number of cells in x-direction
 * @param dx   Cell spacing in x-direction
 * @param n    Number of cells in y-direction
 * @param dy   Cell spacing in y-direction
 * @param bc   Boundary condition data
 */
void addScalarBC(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                 u32 n, Real dy, const BC2D &bc);

/**
 * @brief Apply boundary conditions to a 3D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to enforce boundary conditions.
 *
 * @param A    Linear operator (modified in place)
 * @param b    Right-hand side vector (modified in place)
 * @param k    Order of accuracy
 * @param m    Number of cells in x-direction
 * @param dx   Cell spacing in x-direction
 * @param n    Number of cells in y-direction
 * @param dy   Cell spacing in y-direction
 * @param o    Number of cells in z-direction
 * @param dz   Cell spacing in z-direction
 * @param bc   Boundary condition data
 */
void addScalarBC(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                 u32 n, Real dy, u32 o, Real dz, const BC3D &bc);

// ============================================================================
// These handlers are provided for users who may want to differentiate between
// call to 1D, 2D, and 3D. Internally, they simply call the addScalarBC 
// function with the appropriate parameters.
// ============================================================================

/**
 * @brief Apply boundary conditions to a 1D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to enforce boundary conditions.
 *
 * @param A    Linear operator (modified in place)
 * @param b    Right-hand side vector (modified in place)
 * @param k    Order of accuracy
 * @param m    Number of cells
 * @param dx   Cell spacing
 * @param bc   Boundary condition data
 */
 
inline void addScalarBC1D(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                          const BC1D &bc) {
    addScalarBC(A, b, k, m, dx, bc);
}

/**
 * @brief Apply boundary conditions to a 2D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to enforce boundary conditions.
 *
 * @param A    Linear operator (modified in place)
 * @param b    Right-hand side vector (modified in place)
 * @param k    Order of accuracy
 * @param m    Number of cells in x-direction
 * @param dx   Cell spacing in x-direction
 * @param n    Number of cells in y-direction
 * @param dy   Cell spacing in y-direction
 * @param bc   Boundary condition data
 */

inline void addScalarBC2D(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                          u32 n, Real dy, const BC2D &bc) {
    addScalarBC(A, b, k, m, dx, n, dy, bc);
}

/**
 * @brief Apply boundary conditions to a 3D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to enforce boundary conditions.
 *
 * @param A    Linear operator (modified in place)
 * @param b    Right-hand side vector (modified in place)
 * @param k    Order of accuracy
 * @param m    Number of cells in x-direction
 * @param dx   Cell spacing in x-direction
 * @param n    Number of cells in y-direction
 * @param dy   Cell spacing in y-direction
 * @param o    Number of cells in z-direction
 * @param dz   Cell spacing in z-direction
 * @param bc   Boundary condition data
 */
inline void addScalarBC3D(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                          u32 n, Real dy, u32 o, Real dz, const BC3D &bc) {
    addScalarBC(A, b, k, m, dx, n, dy, o, dz, bc);
}

} // namespace AddScalarBC

#endif // ADDSCALARBC_H