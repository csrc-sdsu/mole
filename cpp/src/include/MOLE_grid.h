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
#include "flat2dArray.h"
#include "flat3dArray.h"
#include "MOLE_Errors.h"    

// Typedefs used in the MOLE library
using Real = double;

// Convenience typedefs for multi-dimensional double arrays stored as vectors
using Array1D = std::vector<Real>;
using Array2D = Flat2DArray;
using Array3D = std::vector<std::vector<std::vector<Real>>>;

// Import Armadillo typedefs for matrix and vector operations
#include <armadillo>
using namespace arma;
using namespace std;

// The following 3 structs are used inside the Grid subclasses 
// (i.e., grid1D, grid2D, grid3D).

// 1D grid specific parameters 
// dx is a Real for uniform grids >= 0.0
// for other topologies, the user must provide nodes_X
struct gridParams1D {
    char topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    int m = 0; // Number of cells in x-direction
    Real dx = 0.0; // Uniform cell spacing in x-direction
    Array1D nodes_X; // nodes_X = faces_X in 1D
    Array1D centers_X; // Staggered grid in x-dir for MOLE Ops
    Array1D Faces_X(){return nodes_X;} // In 1D same as nodes_X 
    bool bc_isPeriodic = false; // whether the grid has periodic bcs
};

// 2D grid specific parameters 
// dx and dy are Reals for uniform grids but for all other 
// topologies users need to use nodes_X, and nodes_Y
struct gridParams2D {
    char topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    int m = 0; // Number of cells in x-direction
    int n = 0; // Number of cells in y-direction
    Real dx = 0.0; // Uniform cell spacing in x-direction
    Real dy = 0.0; // Uniform cell spacing in y-direction
    Array2D nodes_X; // Nodal coordinates in x-dir 
    Array2D nodes_Y; // Nodal coordinates in y-dir 
    Array2D centers_X; // Staggered grid in x-dir for MOLE Ops
    Array2D centers_Y; // Staggered grid in y-dir for MOLE Ops
    Array2D faces_u_X; // x-normal faces
    Array2D faces_u_Y; // y-normal faces
    Array2D faces_v_X; // x-normal faces
    Array2D faces_v_Y; // y-normal faces
    bool bc_isPeriodic[2] = {{false}, {false}}; //periodic bcs?
};

// 3D grid specific parameters 
// dx, dy and dz are Reals for uniform grids but arrays of Reals
// for nonuniform grids
struct gridParams3D {
    char topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    int m = 0; // Number of cells in x-direction
    int n = 0; // Number of cells in y-direction
    int o = 0; // Number of cells in z-direction
    Real dx = 0.0; // Uniform cell spacing in x-direction
    Real dy = 0.0; // Uniform cell spacing in y-direction
    Real dz = 0.0; // Uniform cell spacing in z-direction
    Array3D nodes_X; // Nodal coordinates in x-dir 
    Array3D nodes_Y; // Nodal coordinates in y-dir 
    Array3D nodes_Z; // Nodal coordinates in z-dir 
    Array3D centers_X; // Staggered grid in x-dir for MOLE Ops
    Array3D centers_Y; // Staggered grid in y-dir for MOLE Ops
    Array3D centers_Z; // Staggered grid in z-dir for MOLE Ops
    Array3D faces_u_X; // x-normal faces
    Array3D faces_u_Y; // y-normal faces
    Array3D faces_u_Z; // z-normal faces
    Array3D faces_v_X; // x-normal faces
    Array3D faces_v_Y; // y-normal faces
    Array3D faces_v_Z; // z-normal faces
    Array3D faces_w_X; // x-normal faces
    Array3D faces_w_Y; // y-normal faces
    Array3D faces_w_Z; // z-normal faces
    bool bc_isPeriodic[3] = {{false}, {false}, {false}};
};

// variant data structures
using paramVars = std::variant<gridParams1D, 
                               gridParams2D, gridParams3D>;

// gridBase is the grid superclass and can also be used for handling
// errors that occur before a grid dimension is identified.
// The error stack is member of this superclass and protected (i.e 
// can only be access by member functions in a grid class)
class gridBase{
    protected:
        stack<MOLE_Errors> errs; // for error detection+backtracking
    public:
        // gridBase shell members for all grids
        int dim; // declaring dimensionality in the shell grid
        virtual ~gridBase() = default;
        gridBase(int idim);
        // Error handling member functions/methods
        void logGridErr(int errCode, string errLoc, string errParm);
        bool hasGridErrors();
        bool isValidatedGrid();
        void setGridValidated();
        void print_ErrorLog();
        void write_ErrorLog();
};

// 1D grid class
class grid1D : public gridBase{
    public:
        gridParams1D grid; // structure for all 1D grid parameters
        ~grid1D() = default;
        // grid1D(<struct>) constructor, users pass a structure with
        // the 1D parameters (using type gridParams1D).
        grid1D(gridParams1D p1);
        // checks if the main params are valid
        bool validGrid();
        // makeGrid method that only stores the centers_X coordinates
        grid1D makeBasicGrid(gridParams1D gridInput); 
};

// 2D Grid class
class grid2D : public gridBase{
    public:
        gridParams2D grid; // 2D grid structure
        ~grid2D() = default;
        // grid2D(<struct>) constructor, users pass a structure with
        // the 2D parameters (using type gridParams2D).
        grid2D(gridParams2D p2D);
        // checks if the main params are valid
        bool validGrid();
        // makeGrid method that only stores the centers_X coordinates
        grid2D makeBasicGrid(gridParams2D gridInput);
};

// 3D Grid class
class grid3D : public gridBase{
    public:
        gridParams3D grid; // 3D grid structure
        ~grid3D() = default;
        // grid3D(<struct>) constructor, users pass a structure with
        // the 3D parameters (using type gridParams2D).
        grid3D(gridParams3D p3D);
        // checks if the main params are valid
        bool validGrid();
        // makeGrid method that only stores the centers_X coordinates
        grid3D makeBasicGrid(gridParams3D gridInput);
};

// Auxiliar functions used by some MOLE grids
bool validSpacing(Real dh);
void generateUniNodalCoords1D(int m, Real dx, Array1D& nodes_X);
void generateUniCenterCoords1D(int m, Real dx, Array1D& centers_X);

#endif // GRIDS_H
