/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * © 2008-2024 San Diego State University Research Foundation (SDSURF).
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
 * @date 2025/01/26
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
    vec dc;  // Dirichlet coefficients a0 (4x1: left, right, bottom, top)
    vec nc;  // Neumann coefficients b0 (4x1: left, right, bottom, top)
    std::vector<vec> v;  // Boundary values g (4 vectors: left, right, bottom, top)

    BC2D() : dc(4, fill::zeros), nc(4, fill::zeros), v(4) {}
};

/**
 * @brief Structure to hold boundary condition data for 3D problems
 *
 * Represents boundary condition: a0*u + b0*du/dn = g
 */
struct BC3D {
    vec dc;  // Dirichlet coefficients a0 (6x1: left, right, bottom, top, front, back)
    vec nc;  // Neumann coefficients b0 (6x1: left, right, bottom, top, front, back)
    std::vector<vec> v;  // Boundary values g (6 vectors: left, right, bottom, top, front, back)

    BC3D() : dc(6, fill::zeros), nc(6, fill::zeros), v(6) {}
};

// ============================================================================
// 1D Boundary Condition Functions
// ============================================================================

/**
 * @brief Helper: Compute LHS modifications for 1D boundary conditions
 *
 * @param k Order of accuracy
 * @param m Number of cells
 * @param dx Cell spacing
 * @param dc Dirichlet coefficients (2x1 vector)
 * @param nc Neumann coefficients (2x1 vector)
 * @param Al Output: Left boundary modification matrix
 * @param Ar Output: Right boundary modification matrix
 */
void addScalarBC1Dlhs(u16 k, u32 m, Real dx, const vec &dc, const vec &nc,
                      sp_mat &Al, sp_mat &Ar);

/**
 * @brief Helper: Modify RHS vector for 1D boundary conditions
 *
 * @param b Right-hand side vector (modified in place)
 * @param v Boundary values (2x1 vector)
 * @param vec Indices to modify
 */
void addScalarBC1Drhs(vec &b, const vec &v, const uvec &vec);

/**
 * @brief Apply boundary conditions to 1D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to include boundary conditions.
 *
 * @param A Linear operator (modified in place)
 * @param b Right-hand side vector (modified in place)
 * @param k Order of accuracy
 * @param m Number of cells
 * @param dx Cell spacing
 * @param bc Boundary condition data
 */
void addScalarBC1D(sp_mat &A, vec &b, u16 k, u32 m, Real dx, const BC1D &bc);

// ============================================================================
// 2D Boundary Condition Functions
// ============================================================================

/**
 * @brief Helper: Compute LHS modifications for 2D boundary conditions
 *
 * @param k Order of accuracy
 * @param m Number of cells in x-direction
 * @param dx Cell spacing in x-direction
 * @param n Number of cells in y-direction
 * @param dy Cell spacing in y-direction
 * @param dc Dirichlet coefficients (4x1 vector)
 * @param nc Neumann coefficients (4x1 vector)
 * @param Abcl Output: Left edge modification
 * @param Abcr Output: Right edge modification
 * @param Abcb Output: Bottom edge modification
 * @param Abct Output: Top edge modification
 */
void addScalarBC2Dlhs(u16 k, u32 m, Real dx, u32 n, Real dy,
                      const vec &dc, const vec &nc,
                      sp_mat &Abcl, sp_mat &Abcr, sp_mat &Abcb, sp_mat &Abct);

/**
 * @brief Helper: Modify RHS vector for 2D boundary conditions
 *
 * @param b Right-hand side vector (modified in place)
 * @param dc Dirichlet coefficients (4x1 vector)
 * @param nc Neumann coefficients (4x1 vector)
 * @param v Boundary values (4 vectors)
 * @param rl Left edge indices
 * @param rr Right edge indices
 * @param rb Bottom edge indices
 * @param rt Top edge indices
 */
void addScalarBC2Drhs(vec &b, const vec &dc, const vec &nc,
                      const std::vector<vec> &v,
                      const uvec &rl, const uvec &rr,
                      const uvec &rb, const uvec &rt);

/**
 * @brief Apply boundary conditions to 2D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to include boundary conditions.
 *
 * @param A Linear operator (modified in place)
 * @param b Right-hand side vector (modified in place)
 * @param k Order of accuracy
 * @param m Number of cells in x-direction
 * @param dx Cell spacing in x-direction
 * @param n Number of cells in y-direction
 * @param dy Cell spacing in y-direction
 * @param bc Boundary condition data
 */
void addScalarBC2D(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                   u32 n, Real dy, const BC2D &bc);

// ============================================================================
// 3D Boundary Condition Functions
// ============================================================================

/**
 * @brief Helper: Compute LHS modifications for 3D boundary conditions
 *
 * @param k Order of accuracy
 * @param m Number of cells in x-direction
 * @param dx Cell spacing in x-direction
 * @param n Number of cells in y-direction
 * @param dy Cell spacing in y-direction
 * @param o Number of cells in z-direction
 * @param dz Cell spacing in z-direction
 * @param dc Dirichlet coefficients (6x1 vector)
 * @param nc Neumann coefficients (6x1 vector)
 * @param Abcl Output: Left face modification
 * @param Abcr Output: Right face modification
 * @param Abcb Output: Bottom face modification
 * @param Abct Output: Top face modification
 * @param Abcf Output: Front face modification
 * @param Abck Output: Back face modification
 */
void addScalarBC3Dlhs(u16 k, u32 m, Real dx, u32 n, Real dy, u32 o, Real dz,
                      const vec &dc, const vec &nc,
                      sp_mat &Abcl, sp_mat &Abcr, sp_mat &Abcb,
                      sp_mat &Abct, sp_mat &Abcf, sp_mat &Abck);

/**
 * @brief Helper: Modify RHS vector for 3D boundary conditions
 *
 * @param b Right-hand side vector (modified in place)
 * @param dc Dirichlet coefficients (6x1 vector)
 * @param nc Neumann coefficients (6x1 vector)
 * @param v Boundary values (6 vectors)
 * @param rl Left face indices
 * @param rr Right face indices
 * @param rb Bottom face indices
 * @param rt Top face indices
 * @param rf Front face indices
 * @param rk Back face indices
 */
void addScalarBC3Drhs(vec &b, const vec &dc, const vec &nc,
                      const std::vector<vec> &v,
                      const uvec &rl, const uvec &rr, const uvec &rb,
                      const uvec &rt, const uvec &rf, const uvec &rk);

/**
 * @brief Apply boundary conditions to 3D discrete operator and RHS
 *
 * Modifies the linear system A*u = b to include boundary conditions.
 *
 * @param A Linear operator (modified in place)
 * @param b Right-hand side vector (modified in place)
 * @param k Order of accuracy
 * @param m Number of cells in x-direction
 * @param dx Cell spacing in x-direction
 * @param n Number of cells in y-direction
 * @param dy Cell spacing in y-direction
 * @param o Number of cells in z-direction
 * @param dz Cell spacing in z-direction
 * @param bc Boundary condition data
 */
void addScalarBC3D(sp_mat &A, vec &b, u16 k, u32 m, Real dx,
                   u32 n, Real dy, u32 o, Real dz, const BC3D &bc);

} // namespace AddScalarBC

#endif // ADDSCALARBC_H
