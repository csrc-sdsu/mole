/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/

/**
 * @file interpolNtoC.h
 * 
 * @brief Mimetic Interpolators from the Nodes to Centers
 * 
 * @date 2026/4/6
 * 
 */

#ifndef INTERPOLNTOC_H
#define INTERPOLNTOC_H

#include "utils.h"
#include <cassert>

/**
 * @brief Mimetic Interpolator operators from the Nodes to Centers
 * 
 */
class InterpolNtoC : public sp_mat
{
public:
    using sp_mat::operator=;

    /**
     * @brief 1-D Mimetic Interoplator from the Nodes to Centers Constructor
     * 
     * @param k Order of accuracy
     * @param m Number of cells
     * @param dc Dirichlet coefficients for left and right boundaries
     * @param nc Neumann coefficients for left and right boundaries
     */
    InterpolNtoC(u16 k, u32 m, const ivec& dc, const ivec& nc);

    /**
     * @brief 2-D Mimetic Interoplator from the Nodes to Centers Constructor
     * 
     * @param k Order of accuracy
     * @param m Number of cells in x-direction
     * @param n Number of cells in y-direction
     * @param dc Dirichlet coefficients for left, right, bottom, and top boundaries
     * @param nc Neumann coefficients for left, right, bottom, and top boundaries
     */
    InterpolNtoC(u16 k, u32 m, u32 n, const ivec& dc, const ivec& nc);

    /**
     * @brief 3-D Mimetic Interoplator from the Nodes to Centers Constructor
     * 
     * @param k Order of accuracy
     * @param m Number of cells in x-direction
     * @param n Number of cells in y-direction
     * @param o Number of cells in z-direction
     * @param dc Dirichlet coefficients for left, right, bottom, top, front, and back boundaries
     * @param nc Neumann coefficients for left, right, bottom, top, front, and back boundaries
     */
    InterpolNtoC(u16 k, u32 m, u32 n, u32 o, const ivec& dc, const ivec& nc);

private:
    
    /**
     * @brief 1-D Nonperiodic Mimetic Interpolator from the Nodes to Centers Constructor
     * 
     * @param k Order of accuracy
     * @param m NUmber of cells
     */
    InterpolNtoC(u16 k, u32 m);

    /**
     * @brief 1-D Periodic Mimetic Interpolator from the Nodes to Centers Constructor
     * 
     * @param k Order of accuracy
     * @param m NUmber of cells
     * @param dummy Dummy argument to trigger overload
     */
    InterpolNtoC(u16 k, u32 m, bool dummy);
};

#endif //INTERPOLNTOC_H