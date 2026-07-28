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
#include <variant> // To handle C++ variant classes and structs
#include <type_traits> //For polymorphism in visit's lambda functions
#include <memory>
#include "MOLE_Errors.h"    
#include "flat2DArray.h" // 2D and 3D arrays are flat to optimize
#include "flat3DArray.h" // memory performance instead of C++ vectors

// Typedefs used in the MOLE library
using Real = double;

// Convenience typedefs for 1D, 2D and 3D arrays of doubles
using Array1D = std::vector<Real>;
using Array2D = flat2DArray;
using Array3D = flat3DArray;

using namespace std;

// ----------------------------------------------------------------//
//
//               MOLE GRID DATA STRUCTURES
//
// The following 3 structs are used inside the Grid subclasses 
// (i.e., grid1D, grid2D, grid3D).
//
// ----------------------------------------------------------------//
//
// 1D grid specific parameters 
//    - dx is a Real for uniform grids >= 0.0
//    - for other topologies, the user must provide nodes_X
//
struct gridParams1D {
    char topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    size_t m = 0; // Number of cells in x-direction
    Real dx = 0.0; // Uniform cell spacing in x-direction
    Array1D nodes_X; // nodes_X = faces_X in 1D
    Array1D centers_X; // Staggered grid in x-dir for MOLE Ops
    Array1D Faces_X(){return nodes_X;} // In 1D same as nodes_X 
    bool bc_isPeriodic = false; // whether the grid has periodic bcs
};

//
// 2D grid specific parameters 
//    - dx and dy are Reals for uniform grids but for nonuniform
//      there are arrays of Reals 
//    - For curvilinear and nonuniform grids users need to provide  
//      the nodes_X, and nodes_Y arrays
struct gridParams2D {
    char topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    size_t m = 0; // Number of cells in x-direction
    size_t n = 0; // Number of cells in y-direction
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
    bool bc_isPeriodic[2] = {false, false}; //periodic bcs?
};

//
// 3D grid specific parameters 
//    - dx, dy and dz are Reals for uniform grids but arrays of Reals
//      for nonuniform grids
//    - For curvilinear and nonuniform grids users need to provide  
//      the nodes_X, nodes_Y, and nodes_Z arrays
struct gridParams3D {
    char topology; // 'u'=uniform, 'c'=curvilinear, 'n'=non-uniform
    size_t m = 0; // Number of cells in x-direction
    size_t n = 0; // Number of cells in y-direction
    size_t o = 0; // Number of cells in z-direction
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
    bool bc_isPeriodic[3] = {false, false, false};
};

// -----------------------------------------------------------------//
//
// gridBase is the grid superclass that handles common interfaces for
// all grid dimensions (e.g., error detection and propagation). This 
// class can also be used for errors that occur prematurally when a
// grid is created.
//
// ----------------------------------------------------------------//
// The error stack is member of this superclass and protected (i.e 
// can only be access by member functions in a grid class)
class gridBase{
    protected:
        stack<MOLE_Errors> errs; // for error detection+backtracking
    public:
        // gridBase shell members for all grids
        size_t dim; // explict declaration of dimensionality in grid
        virtual ~gridBase() = default;
        gridBase(size_t idim);
        // validates user-provided coordinates for uniform grids only
        bool valid1DCoordinates(Array1D& userInput, 
                                const Array1D& expected,
                                Real dx, size_t m, 
                                int sizeMismatchErr,
                                int badCoordsErr);
        bool valid2DCoordinates(Array2D& userInput,
                                const Array2D& expected, 
                                Real dx, Real dy, size_t m, size_t n,
                                int sizeMismatchErr,
                                int badCoordErr);
        bool valid3DCoordinates(Array3D& userInput,
                                const Array3D& expected,
                                Real dx, Real dy, Real dz,
                                size_t m, size_t n, size_t o,
                                int sizeMismatchErr,
                                int badCoordErr);
        // Error handling member functions/methods
        void logGridErr(size_t errCode, string errLoc, 
                        string errParm);
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
        // the 1D parameters (gridParams1D).
        grid1D(const gridParams1D p1);
        // like grid1D but also takes an MOLE error object containing
        // errors that may have occur prior to the grid construction
        grid1D(const gridParams1D p1, 
                const stack<MOLE_Errors>& inerrs);
        bool validGrid();
};

// 2D Grid class
class grid2D : public gridBase{
    public:
        gridParams2D grid; // 2D grid structure
        ~grid2D() = default;
        // grid2D(<struct>) constructor, users pass a structure with
        // the 2D parameters (gridParams2D).
        grid2D(const gridParams2D p2D);
        // like grid2D but also takes an MOLE error object containing
        // errors that may have occur prior to the grid construction
        grid2D(const gridParams2D p2, 
                const stack<MOLE_Errors>& inerrs);
        // checks if the grid params are valid
        bool validGrid();
};

// 3D Grid class
class grid3D : public gridBase{
    public:
        gridParams3D grid; // 3D grid structure
        ~grid3D() = default;
        // grid3D(<struct>) constructor, users pass a structure with
        // the 3D parameters (gridParams2D).
        grid3D(const gridParams3D p3D);
        // like grid3D but also takes an MOLE error object containing
        // errors that may have occur prior to the grid construction
        grid3D(const gridParams3D p3, 
                const stack<MOLE_Errors>& inerrs);
        // checks if the grid params are valid
        bool validGrid();
};

// Grid Null Class - This grid object is return when errors are found
// with the grid specifications and the grid could not be built.
class gridNull: public gridBase{
    public:
        paramsNull ErrData;
        ~gridNull() = default;
        gridNull(paramsNull inParams, const stack<MOLE_Errors>& inerrs);
        bool validGrid(){return false;}
};

// ----------------------------------------------------------------
//                VARIANT STRUCTURES AND CLASSES
// variant for data structures holding MOLE's grid information
// or ParamsNull = for reporting error when a grid cannot be 
// generated (ParamsNull is declared in MOLE_Errors.h)
using paramVars = std::variant<paramsNull, gridParams1D, 
                               gridParams2D, gridParams3D>;
// Handling MOLE variant classes and data structures. These are
// variant over the concrete derived types — used purely for
// type-safe dispatch for MOLE grid classes and generic grid
// handling. gridNull is an empty shell created whenever errors
// occur and it is unsafe to use the grid.
// ----------------------------------------------------------------
using gridVar = std::variant<grid1D, grid2D, grid3D, gridNull>;

// Auxiliar functions used by some MOLE grids
  
bool isValidGrid(gridVar& g); // validates a generic grid 
bool validSpacing(Real dh);  // checks for valid dx, dy, or dz
void generateNodalPts(size_t npts, Real delta, Array1D& out_array);
void generateCenterPts(size_t npts, Real delta, Array1D& out_array);

// gridVar makeGrid is a factory function that works for any of the 3
// grid dimensionalities, intended for cases when the users need to
// define the dimensionality at runtime. 
gridVar makeGrid(paramVars params, const stack<MOLE_Errors>& errs);

#endif
