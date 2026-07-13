/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file grid.h
 *
 * @brief Generic grid class and data structures for 1D, 2D, and 3D grids.
 *
 * @date 2026/06/24
 *
 */

#ifndef GRIDS_H
#define GRIDS_H

#include <vector>
#include <string>
#include <variant>
#include "MOLE_Errors.h"    

// Typedefs used in the MOLE library
using Real = double;

// Convenience typedefs for multi-dimensional double arrays stored as vectors
using Array1D = std::vector<Real>;
using Array2D = std::vector<std::vector<Real>>;
using Array3D = std::vector<std::vector<std::vector<Real>>>;

// Import Armadillo typedefs for matrix and vector operations
#include <armadillo>
using namespace arma;
using namespace std;

// The following 3 structs are used inside the Grid classes 
// (i.e., GRID1D, GRID2D, GRID3D).

// Generic grid shell mostly to report error that may occur before
// a grid type is set and the grid is instantiated
struct gridParams {
    int dim; // Grid dimension
    string topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    vector<bool> bc_isPeriodic; // whether the grid has periodic bc
};

// Grid parameter structure for 1D grids
struct gridParams1D {
    string topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    int m = 0; // Number of cells in x-direction
    Real dx = 0.0; // Cell spacing in x-direction
    vector<Real> nodes_X; // Nodal coordinates in x-dir = faces_X in 1D
    vector<Real> centers_X; // Staggered grid in x-dir for MOLE Ops
    vector<bool> bc_isPeriodic; // whether the grid has periodic bc
    stack<MOLE_Errors> errs; // for error detection + backtracking
};

// Grid parameter structure for 2D grids
struct gridParams2D {
    string topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    int m = 0; // Number of cells in x-direction
    int n = 0; // Number of cells in y-direction
    Real dx = 0.0; // Cell spacing in x-direction
    Real dy = 0.0; // Cell spacing in y-direction
    vector<Real> nodes_X; // Nodal coordinates in x-dir = faces_X in 2D
    vector<Real> nodes_Y; // Nodal coordinates in y-dir = faces_Y in 2D
    vector<Real> centers_X; // Staggered grid in x-dir for MOLE Ops
    vector<Real> centers_Y; // Staggered grid in y-dir for MOLE Ops
    vector<Real> faces_u_X; // x-normal faces
    vector<Real> faces_u_Y; // y-normal faces
    vector<Real> faces_v_X; // x-normal faces
    vector<Real> faces_v_Y; // y-normal faces
    vector<bool> bc_isPeriodic; // whether the grid has periodic bc
    stack<MOLE_Errors> errs; // for error detection + backtracking
};

struct gridParams3D {
    string topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    int m = 0; // Number of cells in x-direction
    int n = 0; // Number of cells in y-direction
    int o = 0; // Number of cells in z-direction
    Real dx = 0.0; // Cell spacing in x-direction
    Real dy = 0.0; // Cell spacing in y-direction
    Real dz = 0.0; // Cell spacing in z-direction
    vector<Real> nodes_X; // Nodal coordinates in x-dir = faces_X in 3D
    vector<Real> nodes_Y; // Nodal coordinates in y-dir = faces_Y in 3D
    vector<Real> nodes_Z; // Nodal coordinates in z-dir = faces_Z in 3D
    vector<Real> centers_X; // Staggered grid in x-dir for MOLE Ops
    vector<Real> centers_Y; // Staggered grid in y-dir for MOLE Ops
    vector<Real> centers_Z; // Staggered grid in z-dir for MOLE Ops
    vector<Real> faces_u_X; // x-normal faces
    vector<Real> faces_u_Y; // y-normal faces
    vector<Real> faces_u_Z; // z-normal faces
    vector<Real> faces_v_X; // x-normal faces
    vector<Real> faces_v_Y; // y-normal faces
    vector<Real> faces_v_Z; // z-normal faces
    vector<Real> faces_w_X; // x-normal faces
    vector<Real> faces_w_Y; // y-normal faces
    vector<Real> faces_w_Z; // z-normal faces
    vector<bool> bc_isPeriodic; // whether the grid has periodic bc
    stack<MOLE_Errors> errs; // for error detection + backtracking
};

// This class is reserved for errors that occurred before a
// grid is successfully created. 
class ErrGrid{
    private:
        stack<MOLE_Errors> errs; // for error detection+backtracking
    public:
        gridParams inputParam;
        ~ErrGrid() = default;
        ErrGrid();
        void logGenError(int dim);
        bool checkErrors();
};

// 1D Grid class
class Grid1D{
    stack<MOLE_Errors> errs; // for error detection + backtracking
    public:
        gridParams1D grid; // 1D grid structure
        ~Grid1D() = default;
        Grid1D(const gridParams1D p1D);
        void validateGrid();
        bool checkErrors();
};

// 2D Grid class
class Grid2D{
    stack<MOLE_Errors> errs; // for error detection + backtracking
    public:
        gridParams2D grid; // 2D grid structure
        ~Grid2D() = default;
        Grid2D(const gridParams2D p2D);
        void validateGrid();
        bool checkErrors();
};

// 3D Grid class
class Grid3D{
    stack<MOLE_Errors> errs; // for error detection + backtracking
    public:
        gridParams3D grid; // 3D grid structure
        ~Grid3D() = default;
        Grid3D(const gridParams3D p3D);
        void validateGrid();
        bool checkErrors();
};

// variant data structures
using paramsVariant = std::variant<gridParams, gridParams1D, gridParams2D, gridParams3D>;
using gridVariant = std::variant<ErrGrid, Grid1D, Grid2D, Grid3D>;

gridVariant makeGrid(int dim, paramsVariant gridParam); 

#endif // GRIDS_H
