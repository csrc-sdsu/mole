/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/
 
/*
 * @file MOLE_grid.cpp
 * 
 * @brief MOLE Grid Implementations
 * 
 * @date 2026/06/24
 * 
 */

#include "MOLE_grid.h"

// Make Grid functions which returns an object of a
// class Grid1D, Grid2D, Grid3D or ErrGrid
gridVariant makeGrid(int dim, paramsVariant gridInput){
    if (dim == 1) return makeGrid1D(gridInput);
    if (dim == 2) return makeGrid2D(gridInput);
    if (dim == 3) return makeGrid3D(gridInput);
    ErrGrid grid;
    grid.logGenError(dim);
    return grid;
}

ErrGrid::ErrGrid(){
    params.dim = 0; // initialized dimension to 0
    MOLEerr_init(errs); // initialized the stack of errors
}

void ErrGrid::logGenError(int dim){
    MOLEerr_log(errs, MOLE_ERR_INVALID_DIM, "makeGrid", std::to_string(dim));
}
Grid1D makeGrid1D(paramsVariant gp){

}

Grid2D makeGrid2D(paramsVariant gp){
    
}

Grid3D makeGrid3D(paramsVariant gp){
    
}

Grid1D makeFullGrid1D(gridParams1D gp){

}

Grid2D makeFullGrid2D(gridParams2D gp){
    
}

Grid3D makeFullGrid3D(gridParams3D gp){
    
}

// Initializes the error stack.
void init_gridErrors(stack<MOLE_Errors>& errs){
    MOLEerr_init(errs); // Initialize the error stack 
    MOLEerr_log(errs, MOLE_ERR_GRID_UNCHECKED, "init_grid", "");
}

// This function checks whether the grid has been validated.
bool gridBase::is_gridValidated(){ 
    if (!errs.empty() && 
         MOLEerr_contains(errs, MOLE_ERR_GRID_UNCHECKED)) {
         return false; // Grid has not been validated
    }
    return true; // Grid has been validated
} 

// After a grid has been validated, the error stack is updated
// to remove the requirement to validate the grid. 
void gridBase::set_gridValidated(){
    MOLEerr_remove(errs, MOLE_ERR_GRID_UNCHECKED);
}
    
// 1D Grid class implementation
Grid1D::Grid1D( gridParam1D p1D) : grid1D(p1D) {
        init_gridErrors();
    }

// 2D Grid class implementation
Grid2D::Grid2D( gridParam2D p2D) : grid2D(p2D) {
        init_gridErrors();
    }

// 3D Grid class implementation
Grid3D::Grid3D( gridParam3D p3D) : grid3D(p3D) {
        init_gridErrors();
    }
