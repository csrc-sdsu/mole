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

// gridBase is the grid superclass that handles common interfaces for
// all grid dimensions (e.g., error detection and propagation). This 
// class can also be used for errors that occur prematurally when a
// grid is created

// Default gridBase Constructor (creates only a shell) and
// initializes the error_log for the grid validation with and
// error to ensure the grid is validated before proceeding with 
// other MOLE operations.
gridBase::gridBase(int idim){
    MOLEerr_init(errs); // initialized the stack of errors
    MOLE_Errors err;
    errs = stack<MOLE_Errors>(); // Clear the stack
    err.errCode = MOLE_ERR_GRID_UNCHECKED; // push error to grid stack
    err.errLocation = "<Grid Construction>";
    err.paramError = "";
    logGridErr(err.errCode, err.errLocation, err.paramError);
    if (idim >= 1 && idim <= 3){ // validate grid dimensionality
        dim = idim;
    } else {
        MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM,
                    "gridBase declaration", to_string(idim));
    }
}

// gridBase::logGridErr logs errors for all Grid classes 
void gridBase::logGridErr(int errCode, string errLoc, string errParm){
    MOLEerr_log(errs, errCode, errLoc, errParm);
}
// gridBase::reportErrors prints out all generated errors 
bool gridBase::hasGridErrors(){
    MOLEerr_haserrors(errs);
}

// This function checks whether the grid has been validated.
bool gridBase::isValidatedGrid(){ 
    if (!errs.empty() && 
         MOLEerr_contains(errs, MOLE_ERR_GRID_UNCHECKED)) {
         return false; // Grid has not been validated
    }
    return true; // Grid has been validated
} 

// After a grid has been successfully validated, this function
// remove the requirement to validate the grid. 
void gridBase::setGridValidated(){
    MOLEerr_remove(errs, MOLE_ERR_GRID_UNCHECKED);
}

// This method prints the contents of an errorlog stack to std output
void gridBase::print_ErrorLog(){
    MOLEerr_print(errs);
}

// This method writes the contents of an errorlog stack to a file
void gridBase::write_ErrorLog(){
    MOLEerr_dumpErrLog(errs, "MOLEGridErrors");
}

// Auxiliar functions that check for consistency in the grid 
// parameters 
//
// checks valid cell spacing is valid
bool validSpacing(Real dh){
    if (dh <= 0.0 ) return false;
    if (!isfinite(dh)) return false;
    return true;
}

//
// MOLE 1D Grid Class methods
//
// Check whether the member 1D grid is valid or not and reports all
// errors found with the grid in its error stack.
bool grid1D::validGrid(){
    bool isValid = true;  // the grid is valid unless found errors 
    if (grid.m <= 0){      // X-direction size must be > 0
        logGridErr(MOLE_ERR_INVALID_GRID_SIZE, "grid1D[construct]",
                   to_string(grid.m));
        isValid = false;
    }
    // Must be a valid topology (c, n, or u)
    if (grid.topology != 'c' && grid.topology != 'u' && 
        grid.topology != 'n'){    
        logGridErr(MOLE_ERR_INVALID_GRID_TOPOLOGY,
        "grid1D[construct]", string{grid.topology});
        isValid = false;
    }
    // check for a valid dx for uniform grids
    if (grid.topology == 'u' && !validSpacing(grid.dx)){ 
            logGridErr(MOLE_ERR_INVALID_GRID_SPACING, 
                "grid1D[construct]", to_string(grid.dx));
        isValid = false;
        } 
    // 1D curvilinear grids are fundamentally undefined
    else if (grid.topology == 'c'){  
            logGridErr(MOLE_ERR_INVALID_1D_CURVILINEAR, 
                "grid1D[construct]", "");
        isValid = false;
        }
    // check for nonuniform grids, users must provide nodes_X    
    else if (grid.topology == 'n' && grid.nodes_X.empty()){ 
            logGridErr(MOLE_ERR_INVALID_NONUNIFORM_GRID, 
                "grid1D[construct]", "");
        isValid = false;
        } 
    // If none of the errors above were detected, then
    // set grid as validated (i.e., grid params are checked)
    if (isValid) setGridValidated();
    return isValid;
}

// Functions that generate 1D grid coordinates
//
// Generate 1D grid uniform nodal coordinates
void generateUniNodalCoords1D(int m, Real dx, Array1D& nodes_X){
    for (int i = 0; i <= m; ++i) {
        nodes_X[i] = i * dx;
    }
}
// Generate 1D grid uniform stagger frid (centers) coordinates
void generateUniCenterCoords1D(int m, Real dx, Array1D& centers_X){
    // center_X[0] = 0.0, centers_X[1:m] = (i-0.5)*dx
    for (int i = 1; i <= m; ++i) {
        centers_X[i] = (Real(i) - 0.5) * dx;
    }
    centers_X[m+1] = Real(m) * dx; // center_X[m+1] = m*dx
}

// This grid1D constructor creates and validates. A user needs to 
// input m, dx, and topology in a gridParam1D structure, and 
// optionally they can also provide the grid coordinate arrays 
// (nodes_X & centers_X). It also initializes the GridBase error_log
grid1D::grid1D(gridParams1D p1): gridBase(1) {
    grid.m = p1.m; 
    grid.topology = p1.topology;
    grid.dx = p1.dx; 
    grid.bc_isPeriodic = p1.bc_isPeriodic;
    if (validGrid()){
        // GenerateCoordinates1D -- Nodal
        if (!p1.nodes_X.empty()){  
            grid.nodes_X = p1.nodes_X; // User provided nodal info
        } 
        else if (grid.topology == 'u'){ 
            //Autogenerate Nodal Coordinates for uniform grids
            grid.nodes_X=Array1D(p1.m + 1, 0.0);
            generateUniNodalCoords1D(grid.m, grid.dx, 
            grid.nodes_X);
        }
       // GenerateCoordinates1D -- Centers 
        if (!p1.centers_X.empty()){ // User has provided staggered grid
            grid.centers_X = p1.centers_X;
        }    
        else if (grid.topology == 'u') { 
            //Autogenerate Center Coordinates for uniform grids
            grid.centers_X=Array1D(p1.m + 2, 0.0);
            generateUniCenterCoords1D(grid.m, grid.dx, 
            grid.centers_X);
        }
    } 
    else {
        // log error that grid was not generated
         logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid1D[construct]", to_string(grid.dx));
    }
}

// makeBasicGrid<struct>: users pass a structure with the 1D
// parameters. It initializes the GridBase error_log. Unlike the
// default constructor, it only generates/stores center coordinates
grid1D grid1D::makeBasicGrid(gridParams1D p1){
    gridBase(1);
    grid.m = p1.m; 
    grid.topology = p1.topology;
    grid.dx = p1.dx; 
    grid.bc_isPeriodic = p1.bc_isPeriodic;
    if (validGrid()){
        // GenerateCoordinates1D -- Centers 
        if (!p1.centers_X.empty()){ // User provided staggered grid
            grid.centers_X = p1.centers_X;
        }    
        else if (grid.topology == 'u') { 
            //Autogenerate Center Coordinates for uniform grids
            grid.centers_X=Array1D(p1.m + 2, 0.0);
            generateUniCenterCoords1D(grid.m, grid.dx, 
            grid.centers_X);
        }
    } 
    else {
        // log error that grid was not generated
         logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid1D[construct]", to_string(grid.dx));
    }
}

//
// MOLE 2D Grid Class methods and functions
//
// Functions that generate 2D Grid Coordinates
//
// Generate 2D grid nodal coordinates
void generateUniNodalCoords2D(int m, int n, Real dx, Real dy, 
                            Array2D& nodes_X, Array2D& nodes_Y){
    for (int i = 0; i <= m; ++i) {
        nodes_X[i] = i * dx;
    }
}
// 1D Grids Stagger Grid (center) Coordinates
void generateCenterCoordinates2D(int m, int n, Real dx, Real dy,
                                Array2D& nodes_X, Array2D& centers_X) {
    // center_X[0] = 0.0, centers_X[1:m] = (i-0.5)*dx
    for (int i = 1; i <= m; ++i) {
        centers_X[i] = (Real(i) - 0.5) * dx;
    }
    centers_X[m+1] = Real(m) * dx; // center_X[m+1] = m*dx
}

// This grid1D constructor creates and validates. A user needs to 
// input m, dx, and topology in a gridParam1D structure, and 
// optionally they can also provide the grid coordinate arrays 
// (nodes_X & centers_X). It also initializes the GridBase error_log
grid2D::grid2D(gridParams2D p2): gridBase(2) {
    grid.m = p2.m; 
    grid.n = p2.n;
    grid.topology = p2.topology;
    grid.dx = p2.dx; 
    grid.dy = p2.dy;
    grid.bc_isPeriodic[0] = p2.bc_isPeriodic[0];
    grid.bc_isPeriodic[1] = p2.bc_isPeriodic[1]; 
    if (validGrid()){
        // GenerateCoordinates2D -- Nodal
        if (!p2.nodes_X.empty()){  
            grid.nodes_X = p2.nodes_X; // User provided nodal info
        } 
        else { //Autogenerate Nodal Coordinates = Faces
            grid.nodes_X = Array2D(p2.m + 1, Array1D(p2.n + 1, 0.0));
            generateNodalCoordinates2D(grid.m, grid.n, grid.dx, 
                grid.dy, grid.nodes_X);
        }
       // GenerateCoordinates1D -- Centers 
        if (!p2.centers_X.empty()){ // User has provided staggered grid
            grid.centers_X = p2.centers_X;
        }    
        else { //Autogenerate Center Coordinates 
            grid.centers_X = Array2D(p2.m + 1, Array1D(p2.n + 1, 0.0));
            generateCenterCoordinates2D(grid.m, grid.n, grid.dx, 
            grid.dy, grid.centers_X);
        }
    } 
    else {
        // log error that grid was not generated
         logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid1D[construct]", to_string(grid.dx));
    }
}

// makeBasicGrid<struct>: users pass a structure with the 1D
// parameters. It initializes the GridBase error_log. Unlike the
// default constructor, it only generates/stores center coordinates
grid1D grid1D::makeBasicGrid(gridParams1D p1){
    gridBase(1);
    grid.m = p1.m; 
    grid.topology = p1.topology;
    grid.dx = p1.dx; 
    grid.bc_isPeriodic = p1.bc_isPeriodic;
    if (validGrid()){
        // GenerateCoordinates1D -- Centers 
        if (!p1.centers_X.empty()){ // User provided staggered grid
            grid.centers_X = p1.centers_X;
        }    
        else { //Autogenerate Center Coordinates 
            grid.centers_X=Array1D(p1.m + 2, 0.0);
            generateCenterCoordinates1D(grid.m, grid.dx, 
            grid.centers_X);
        }
    } 
    else {
        // log error that grid was not generated
         logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid1D[construct]", to_string(grid.dx));
    }
}
//
// MOLE 3D Grid Class methods
//

