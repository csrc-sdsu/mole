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

#include "MOLE_grids.h"

// ------------------------------------------------------------------
//                      gridBase Errors Implementation
//  Wrappers to the MOLE error handling mechanism that can access 
//  the gridBase class private error stack
// ------------------------------------------------------------------ 
//
// gridBase::logGridErr logs errors for all Grid classes 
//
void gridBase::logGridErr(size_t errCode, string errLoc, 
                          string errParm){
    MOLEerr_log(errs, errCode, errLoc, errParm);
}

//
// gridBase::reportErrors prints out all generated errors 
//
bool gridBase::hasGridErrors(){
    return MOLEerr_haserrors(errs);
}

//
// gridBase::isValidatedGrid checks if a grid has been validated.
//
bool gridBase::isValidatedGrid(){ 
    if (!errs.empty() || 
         MOLEerr_contains(errs, MOLE_ERR_GRID_UNCHECKED)) {
         return false; // Grid has not been validated
    }
    return true; // Grid has been validated
} 

//
// gridBase::setGridValidated is called afer a grid has been 
// throroughly validated and sets internal flags with the results.
// 
void gridBase::setGridValidated(){
    MOLEerr_remove(errs, MOLE_ERR_GRID_UNCHECKED);
}

//
// gridBase::print_ErrorLog outputs the contents of a grid's 
// errorlog stack to the standard output
//
void gridBase::print_ErrorLog(){
    MOLEerr_print(errs);
}

//
// gridBase::write_ErrorLog outputs the contents of a grid's 
// errorlog stack to a logfile. The name of the output file starts 
// with "MOLEGridErrors" and is follow by the timestamp
//
void gridBase::write_ErrorLog(){
    MOLEerr_dumpErrLog(errs, "MOLEGridErrors");
}

// ----------
// Set of Auxiliar functions that check for consistency 
// in the grid parameters. These are not particular to a grid
// dimensionality nor topology 
// ----------

//
// validSpacing checks for a valid cell spacing is valid
//
bool validSpacing(Real dh){
    if ( isnan(dh) ) return false;
    if ( dh <= 0.0 ) return false;
    if ( !isfinite(dh) ) return false;
    return true;
}

// 
// generateNodalPts generate arrays used in the generation and
// validation of nodal or normal faces coordinates
// 
void generateNodalPts(size_t npts, Real delta, Array1D& out_array){
    for (size_t i = 0; i <= npts; ++i) {
        out_array[i] = (Real)i * delta;
    }
}
//
// generateCenterPts generates cell centered grid coordinates used in
// generation and validation of grid center coordinates
//
void generateCenterPts(size_t npts, Real delta, Array1D& out_array){
    // center_X[0] = 0.0, centers_X[1:npts] = (i-0.5)*delta
    for (size_t i = 1; i <= npts; ++i) {
        out_array[i] = ((Real)i - 0.5) * delta;
    }
    out_array[npts+1] = (Real)npts * delta; // center_X[npts+1]=npnts*dx
}

//
// NumEqualArray fast flat array element-by-element comparison which
// accounts for possible minor precision errors (i.e., elements in  
// an array can differ by x < factor * machine precision (eps)
// This function works also for flat2DArrays and flat3DArrays
//
bool numEqualArray(const Array1D& a1, Array1D& a2, 
                double tolFactor = 4.0){// multiples of machine eps
    // checking elements and abs|a1(i)-a2(i)| < eps*tolFactor
    const double eps = std::numeric_limits<double>::epsilon();
    const double* __restrict c = a1.data();
    const double* __restrict u = a2.data();

    for (size_t k = 0; k < a1.size(); ++k) {
        double diff = std::fabs(c[k] - u[k]);
        double mag  = std::fabs(c[k]) > std::fabs(u[k]) ? 
                      std::fabs(c[k]) : std::fabs(u[k]);
        mag = mag > 1.0 ? mag : 1.0;
        if (diff > tolFactor * eps * mag) return false;
    }
    return true;
}

bool numEqualArray(const Array2D& a1, Array2D& a2, 
                double tolFactor = 4.0){// multiples of machine eps
    // checking elements and abs|a1(i)-a2(i)| < eps*tolFactor
    const double eps = std::numeric_limits<double>::epsilon();
    const double* __restrict c = a1.data();
    const double* __restrict u = a2.data();

    for (size_t k = 0; k < a1.size(); ++k) {
        double diff = std::fabs(c[k] - u[k]);
        double mag  = std::fabs(c[k]) > std::fabs(u[k]) ? 
                      std::fabs(c[k]) : std::fabs(u[k]);
        mag = mag > 1.0 ? mag : 1.0;
        if (diff > tolFactor * eps * mag) return false;
    }
    return true;
}

bool numEqualArray(const Array3D& a1, Array3D& a2, 
                double tolFactor = 4.0){// multiples of machine eps
    // checking elements and abs|a1(i)-a2(i)| < eps*tolFactor
    const double eps = std::numeric_limits<double>::epsilon();
    const double* __restrict c = a1.data();
    const double* __restrict u = a2.data();

    for (size_t k = 0; k < a1.size(); ++k) {
        double diff = std::fabs(c[k] - u[k]);
        double mag  = std::fabs(c[k]) > std::fabs(u[k]) ? 
                      std::fabs(c[k]) : std::fabs(u[k]);
        mag = mag > 1.0 ? mag : 1.0;
        if (diff > tolFactor * eps * mag) return false;
    }
    return true;
}
//
// Returns a string with the grid topology name
//
string string_topology (char topology){
    if (topology == 'u') return("Uniform Grid: ");
    else if (topology == 'c') return("Curvilinear Grid: ");
    else if (topology == 'n') return("Nonuniform Grid");
    else return ("Invalid Topolgy");
}
// ----------------------------------------------------------------
//
// IMPlEMENTATION OF MOLE GRID CLASSES AND RELATED FUNCTIONS
//
// ----------------------------------------------------------------
//
//                        gridBase Class
// Default gridBase Constructor (creates only a i grid shell) and
// initializes the error_log for grid validation with and error 
// handling. The grid is marked as unvalidated until an explicit 
// required call to validGrid() is made, preceding MOLE operations.
gridBase::gridBase(size_t idim){
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

// ------------------------------------------------------------------
//
// MOLE 1D Grid Class methods (declarations in MOLE_grid.h)
//
// ------------------------------------------------------------------

//
// valid1DCoordinates validates a user-supplied coordinate array 
// against an expected valid grid coordinate one. If the user did not
// provide an array of coordinates, and the grid is uniform, the
// expected value is assigned.
//
bool gridBase::valid1DCoordinates(Array1D& userInput, 
                                const Array1D& expected,
                                Real dx, size_t m,
                                int sizeMismatchErr,
                                int badCoordsErr) {
    if (userInput.empty()) {
        userInput = expected;   // auto-generate
        return true;
    }
    if (userInput.size() != expected.size()) {
        logGridErr(sizeMismatchErr, "grid1D[construct]", 
                    to_string(userInput.size()));
        return false;
    }
    if (!numEqualArray(expected, userInput, 4.0)) {//eps*4.0 precision 
        string sparams = "dx = " + to_string(dx) + ", m = ";
        sparams += to_string(m);
        logGridErr(badCoordsErr, "grid1D[construct]", sparams);
        return false;
    }
    return true;
}

//
// Checks whether the member 1D grid is valid or not and reports all
// errors found with the grid in its error stack. When the grid 
// topology is uniform, this function also generates coordinate 
// arrays not provided by the user.
//
bool grid1D::validGrid() {
    bool isValid = true;

    if (grid.m <= 0) {
        logGridErr(MOLE_ERR_INVALID_GRID_SIZE, "grid1D[construct]", 
            to_string(grid.m));
        isValid = false;
    }

    // u = uniform, c = curvilinear, n = 'non-uniform
    switch (grid.topology) {
    case 'u': {
        if (!validSpacing(grid.dx)) {
            logGridErr(MOLE_ERR_INVALID_GRID_SPACING, 
                "grid1D[construct]", to_string(grid.dx));
            isValid = false;
            break;
        }
        Array1D xn(grid.m + 1), xc(grid.m + 2);
        generateNodalPts(grid.m, grid.dx, xn);
        generateCenterPts(grid.m, grid.dx, xc);

        if (!valid1DCoordinates(grid.nodes_X, xn, grid.dx, grid.m,
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES))
            isValid = false;

        if (!valid1DCoordinates(grid.centers_X, xc, grid.dx, grid.m,
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES))
            isValid = false;
        break;
    }
    case 'c':   // 1D curvilinear grids are fundamentally undefined
        logGridErr(MOLE_ERR_INVALID_1D_CURVILINEAR, 
                    "grid1D[construct]", "");
        isValid = false;
        break;
    case 'n':   // nonuniform grids require user-supplied nodes_X
        if (grid.nodes_X.empty()) {
            logGridErr(MOLE_ERR_INVALID_NONUNIFORM_GRID, 
                        "grid1D[construct]", "");
            isValid = false;
        }
        break;
    default: // invalid topology 
        string errmsg = string_topology(grid.topology);
        logGridErr(MOLE_ERR_INVALID_GRID_TOPOLOGY, 
                    "grid1D[construct]", errmsg);
        isValid = false;
        break;   
    }

    if (isValid) setGridValidated();
    return isValid;
}

//
// This grid1D constructor creates and validates user supplied grid.
// Users use a gridParams1D struct to create a valid MOLE grid with
// this constructore. The minimum grid required attributes from a 
// user are: m, dx, and topology. Optionally. users can also provide 
// the grid coordinate arrays (nodes_X & centers_X), and whether 
// the grid has periodic boundary conditions (default = non-periodic)
//
grid1D::grid1D(const gridParams1D p1): gridBase(1) {
    grid.m = p1.m; 
    grid.topology = p1.topology;
    grid.dx = p1.dx; 
    grid.bc_isPeriodic = p1.bc_isPeriodic;
    grid.nodes_X = p1.nodes_X;
    grid.centers_X = p1.centers_X;

    if (!validGrid()){
        // log an error because grid is not valid
        string errmsg = "1D ";
        errmsg += string_topology(grid.topology);
        errmsg += "ncells = " + to_string(grid.m);
        errmsg += ", dx = "+to_string(grid.dx)+", Periodic = ";
        if (grid.bc_isPeriodic) errmsg += "YES.";
        else errmsg +="NO.";
        logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid1D[grid1D constructor]", errmsg);
    }
}

//
// Like the grid1D constructor, this constructor also creates and 
// validates a user supplied grid. The similar minimum requirements
// apply to a gridParams1D. The inners contains previously logged
// errors that need to be accumulated with the MOLE grid.
//
grid1D::grid1D(const gridParams1D p1, 
                const stack<MOLE_Errors>& inerrs): gridBase(1) {
    grid.m = p1.m; 
    grid.topology = p1.topology;
    grid.dx = p1.dx; 
    grid.bc_isPeriodic = p1.bc_isPeriodic;
    grid.nodes_X = p1.nodes_X;
    grid.centers_X = p1.centers_X;

    // scan the error log for previous errors
    stack<MOLE_Errors> tmp_stk = inerrs;
    while (!tmp_stk.empty()){
        logGridErr(tmp_stk.top().errCode, tmp_stk.top().errLocation,
                    tmp_stk.top().paramError);
        tmp_stk.pop();
    }

    if (!validGrid()){
        // log an error because grid is not valid
        string errmsg = "1D ";
        errmsg += string_topology(grid.topology);
        errmsg += "ncells = " + to_string(grid.m);
        errmsg += ", dx = "+to_string(grid.dx)+", Periodic = ";
        if (grid.bc_isPeriodic) errmsg += "YES.";
        else errmsg +="NO.";
        logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid1D[grid1D constructor]", errmsg);
    }
}

// ------------------------------------------------------------------
//
// MOLE 2D Grid Class methods (declarations in MOLE_grid.h)
//
// ------------------------------------------------------------------

// 
// Functions that generate 2D Grid Coordinates
//

//
// n2DGrid creates a 2D rectangular grid from 2 input coordinate 
// vectors x, y, and it outputs the corresponding 2D grid in two 
// 2D-arrays,  X and Y, with the rectangular grid coordinates
// [X, Y] = n2DGrid( x, y)
//
void nd2DGrid(const Array1D& x, const Array1D& y,
              Array2D& OutX, Array2D& OutY) {
    size_t m, n;
    m = x.size(); 
    n = y.size();
    
    // generating the 2D grid 
    for (size_t i = 0; i < m; ++i) {
        for (size_t j = 0; j < n; ++j) {
            OutX(i, j) = x[i];
            OutY(i, j) = y[j];
        }
    }
}
//
// valid2DCoordinates validates a user-supplied coordinate array 
// against an expected valid grid coordinate one. If the user did not
// provide an array of coordinates, and the grid is uniform, the
// expected value is assigned.
//
bool gridBase::valid2DCoordinates(Array2D& userInput, 
                                const Array2D& expected,
                                Real dx, Real dy, size_t m, size_t n,
                                int sizeMismatchErr,
                                int badCoordsErr) {
    if (userInput.empty()) {
        userInput = expected;   // auto-generate
        return true;
    }
    if (userInput.rows() != expected.rows() ||
        userInput.cols() != expected.cols()) {
        string sparams = "m = " + to_string(m);
        sparams += ", n = " + to_string(n) + ", dx = ";
        sparams += to_string(dx) + ", dy = " + to_string(dy);
        logGridErr(sizeMismatchErr, "grid2D[construct]", sparams);
        return false;
    }
    if (!numEqualArray(expected, userInput, 4.0)) {//eps*4.0 precision 
        string sparams = "m = " + to_string(m);
        sparams += ", n = " + to_string(n) + ", dx = ";
        sparams += to_string(dx) + ", dy = " + to_string(dy);
        logGridErr(badCoordsErr, "grid2D[construct]", sparams);
        return false;
    }
    return true;
}
//
// Checks whether the member 2D grid is valid or not and reports all
// errors found with the grid in its error stack. When the grid 
// topology is uniform, this function also generates coordinate 
// arrays not provided by the user.
//
bool grid2D::validGrid() {
    bool isValid = true;

    if (grid.m <= 0 || grid.n <= 0) {
        logGridErr(MOLE_ERR_INVALID_GRID_SIZE, "grid2D[construct]", 
            to_string(grid.m));
        isValid = false;
    }

    // u = uniform, c = curvilinear, n = 'non-uniform
    switch (grid.topology) {
    case 'u': {
        if (!validSpacing(grid.dx) || !validSpacing(grid.dy)) {
            string errmsg = "dx = ";
            errmsg += to_string(grid.dx) + ", dy = ";
            errmsg += to_string(grid.dy);
            logGridErr(MOLE_ERR_INVALID_GRID_SPACING, 
                "grid2D[construct]", errmsg);
            isValid = false;
            break;
        }
        // Generate grid or validate user-provided coordinates
        Array1D xn(grid.m + 1), yn(grid.n + 1);
        Array2D X(grid.m + 1, grid.n + 1, 0.0), 
                Y(grid.m + 1, grid.n + 1, 0.0);

        // Computing or verifying nodal coordinates
        // xn = (0:m) * dx and and yn = (0:n) * dy
        generateNodalPts(grid.m, grid.dx, xn);
        generateNodalPts(grid.n, grid.dy, yn);
        // [grid.nodes_X, grid.nodes_Y] = nd2Dgrid(xn, yn)
        nd2DGrid(xn, yn, X, Y);
        if (!valid2DCoordinates(grid.nodes_X, X, grid.dx, grid.dy,
                                grid.m+1, grid.n+1,  
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES)){
                isValid = false;
            }
        if (!valid2DCoordinates(grid.nodes_Y, Y, grid.dx, grid.dy, 
                                grid.m+1, grid.n+1, 
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES )){
                isValid = false;
            }
        // Computing or verifying cell center coordinates                        
        // xc = [0, (0.5:m-0.5) * dx, m*dx]  and 
        // yc = [0, (0.5:n-0.5) * dy, n*dy] 
        Array1D xc(grid.m + 2), yc(grid.n + 2);
        generateCenterPts(grid.m, grid.dx, xc);
        generateCenterPts(grid.n, grid.dy, yc);
        // [grid.centers_X, grid.centers_Y] = nd2Dgrid(xc, yc)
        X.resize(grid.m + 2, grid.n + 2);
        Y.resize(grid.m + 2, grid.n + 2);
        nd2DGrid(xc, yc, X, Y);

        if (!valid2DCoordinates(grid.centers_X, X, grid.dx, grid.dy,
                                grid.m+2, grid.n+2,  
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES)){
                isValid = false;
        }
        if (!valid2DCoordinates(grid.centers_Y, Y, grid.dx, grid.dy, 
                                grid.m+2, grid.n+2, 
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES )){
                isValid = false;
        }
        // Computing and validating normal faces 
        // yu = (0.5:n-0.5) * dy; and xv = (0.5:m-0.5) * dx; 
        Array1D yu(grid.n), xv(grid.m); 

        // xv = xc[1:m], yu = yc[1:n]
        std::copy(xc.begin() + 1, xc.begin() + grid.m+1, xv.begin());
        std::copy(yc.begin() + 1, yc.begin() + grid.n+1, yu.begin());
        // [grid.faces_u_X, grid.faces_u_Y] = ndgrid(xu=xn, yu);
        X.resize(grid.m + 1, grid.n);
        Y.resize(grid.m + 1, grid.n);
        nd2DGrid(xn, yu, X, Y);
        if (!valid2DCoordinates(grid.faces_u_X, X, grid.dx, grid.dy,
                                grid.m+1, grid.n, 
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }
        if (!valid2DCoordinates(grid.faces_u_Y, Y, grid.dx, grid.dy,
                                grid.m+1, grid.n,
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
        // [grid.faces_v_X, grid.faces_v_Y] = ndgrid(xv, yv=yn);
        X.resize(grid.m, grid.n + 1);
        Y.resize(grid.m, grid.n + 1);
        nd2DGrid(xv, yn, X, Y);
        if (!valid2DCoordinates(grid.faces_v_X, X, grid.dx, grid.dy,
                                grid.m, grid.n+1, 
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }
        if (!valid2DCoordinates(grid.faces_v_Y, Y, grid.dx, grid.dy,
                                grid.m, grid.n+1,
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
        break;
    }
    case 'c':  // User must provide at least nodal coordinates
        if (grid.nodes_X.empty() || grid.nodes_Y.empty()){
            logGridErr(MOLE_ERR_INVALID_CURVILINEAR_GRID, 
                    "grid2D[construct]", "");
            isValid = false;
        }
        break;
    case 'n':   // nonuniform grids require user-supplied nodes_X
        if (grid.nodes_X.empty() || grid.nodes_Y.empty()) {
            logGridErr(MOLE_ERR_INVALID_NONUNIFORM_GRID, 
                        "grid2D[construct]", "");
            isValid = false;
        }
        break;
    default: // invalid grid topology 
        string errmsg = string_topology(grid.topology);
        logGridErr(MOLE_ERR_INVALID_GRID_TOPOLOGY, 
                    "grid2D[construct]", errmsg);
        isValid = false;
        break;   
    }

    if (isValid) setGridValidated();
    return isValid;
}

//
// This grid2D constructor creates and validates a 2D grid. 
// User needs to input at least m, n, dx, dy and topology in 
// a gridParam2D structure, and optionally they can also provide the
// grid coordinate arrays  (nodes_X, Nodes_Y, centers_X, centers_Y,
// and faces).  This function also initializes the GridBase error_log
// For curvilinear and nonuniform grids, users need to providal
// nodal grid information
//
grid2D::grid2D(gridParams2D p2): gridBase(2) {
    grid.m = p2.m; 
    grid.n = p2.n;
    grid.topology = p2.topology;
    grid.dx = p2.dx; 
    grid.dy = p2.dy;
    grid.bc_isPeriodic[0] = p2.bc_isPeriodic[0];
    grid.bc_isPeriodic[1] = p2.bc_isPeriodic[1]; 
    grid.nodes_X = p2.nodes_X;
    grid.nodes_Y = p2.nodes_Y;
    grid.centers_X = p2.centers_X;
    grid.centers_Y = p2.centers_Y;
    grid.faces_u_X = p2.faces_u_X;
    grid.faces_u_Y = p2.faces_u_Y; 
    grid.faces_v_X = p2.faces_v_X;
    grid.faces_v_Y = p2.faces_v_Y;

    if (!validGrid()){
        // log error that grid was not generated
        string errmsg = "2D ";
        errmsg += string_topology(grid.topology);
        errmsg += ", m cells = " + to_string(grid.m);
        errmsg += ", n cells = " + to_string(grid.n);
        errmsg += ", dx = "+to_string(grid.dx);
        errmsg += ", dy = "+to_string(grid.dy)+", x-Periodic = ";
        if (grid.bc_isPeriodic[0]) errmsg += "YES";
        else errmsg +="NO";
        errmsg += ", y-Periodic = ";
        if (grid.bc_isPeriodic[1]) errmsg += "YES.";
        else errmsg +="NO."; 
        logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid2D[grid2D constructor]", errmsg);
    }
}

//
// Like the grid2D constructor, this constructor also creates and 
// validates a user supplied grid. The similar minimum requirements
// apply to a gridParams2D. The inners contains previously logged
// errors that need to be accumulated with the MOLE grid.
//
grid2D::grid2D(gridParams2D p2, 
                const stack<MOLE_Errors>& inerrs): gridBase(2) {
    grid.m = p2.m; 
    grid.n = p2.n;
    grid.topology = p2.topology;
    grid.dx = p2.dx; 
    grid.dy = p2.dy;
    grid.bc_isPeriodic[0] = p2.bc_isPeriodic[0];
    grid.bc_isPeriodic[1] = p2.bc_isPeriodic[1]; 
    grid.nodes_X = p2.nodes_X;
    grid.nodes_Y = p2.nodes_Y;
    grid.centers_X = p2.centers_X;
    grid.centers_Y = p2.centers_Y;
    grid.faces_u_X = p2.faces_u_X;
    grid.faces_u_Y = p2.faces_u_Y; 
    grid.faces_v_X = p2.faces_v_X;
    grid.faces_v_Y = p2.faces_v_Y;
    
    // scan the error log for previous errors
    stack<MOLE_Errors> tmp_stk = inerrs;
    while (!tmp_stk.empty()){
        logGridErr(tmp_stk.top().errCode, tmp_stk.top().errLocation,
                    tmp_stk.top().paramError);
        tmp_stk.pop();
    }

    if (!validGrid()){
        // log error that grid was not generated
        string errmsg = "2D ";
        errmsg += string_topology(grid.topology);
        errmsg += ", m cells = " + to_string(grid.m);
        errmsg += ", n cells = " + to_string(grid.n);
        errmsg += ", dx = "+to_string(grid.dx);
        errmsg += ", dy = "+to_string(grid.dy)+", x-Periodic = ";
        if (grid.bc_isPeriodic[0]) errmsg += "YES";
        else errmsg +="NO";
        errmsg += ", y-Periodic = ";
        if (grid.bc_isPeriodic[1]) errmsg += "YES.";
        else errmsg +="NO."; 
        logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid2D[grid2D constructor]", errmsg);
    }
}


// ------------------------------------------------------------------
//
// MOLE 3D Grid Class methods (declarations in MOLE_grid.h)
//
// ------------------------------------------------------------------

// 
// Functions that generate 3D Grid Coordinates
//

//
// n3DGrid creates a 3D grid from 3 input coordinate vectors x, y, 
// and z. The function outputs the corresponding 3D grid in three 
// 3D-arrays,  X, Y and Z, with the rectangular grid coordinates
// [X, Y, Z] = n2DGrid(x, y, z)
//
void nd3DGrid(const Array1D& x, const Array1D& y, const Array1D& z, 
              Array3D& OutX, Array3D& OutY, Array3D& OutZ) {
    size_t m, n, o;
    m = x.size(); 
    n = y.size();
    o = z.size();
    
    // generating the 2D grid 
    for (size_t i = 0; i < m; ++i) {
        for (size_t j = 0; j < n; ++j) {
            for(size_t k = 0; k < o; k++){
                OutX(i, j, k) = x[i];
                OutY(i, j, k) = y[j];
                OutZ(i, j, k) = z[k];
            }

        }
    }
}

//
// valid3DCoordinates validates a user-supplied coordinate array 
// against an expected valid grid coordinate one. If the user did not
// provide an array of coordinates, and the grid is uniform, the
// expected value is assigned.
//
bool gridBase::valid3DCoordinates(Array3D& userInput, 
                                const Array3D& expected,
                                Real dx, Real dy, Real dz, 
                                size_t m, size_t n, size_t o,
                                int sizeMismatchErr,
                                int badCoordsErr) {
    if (userInput.empty()) {
        userInput = expected;   // auto-generate
        return true;
    }
    if (userInput.dim1() != expected.dim1() ||
        userInput.dim2() != expected.dim2() ||
        userInput.dim3() != expected.dim3()) {
        string sparams = "m = " + to_string(m);
        sparams += ", n = " + to_string(n) + ", dx = ";
        sparams += to_string(dx) + ", dy = " + to_string(dy);
        logGridErr(sizeMismatchErr, "grid3D[construct]", sparams);
        return false;
    }
    if (!numEqualArray(expected, userInput, 4.0)) {//eps*4.0 precision 
        string sparams = "m = " + to_string(m);
        sparams += ", n = " + to_string(n) + ", o = ";
        sparams += to_string(o) + ", dx = " + to_string(dx);
        sparams += ", dy = " + to_string(dy) + ", dz = ";
        sparams += to_string(dz);
        logGridErr(badCoordsErr, "grid3D[construct]", sparams);
        return false;
    }
    return true;
}
//
// Checks whether the member 3D grid is valid or not, and reports all
// errors found with the grid in its error stack. When the grid 
// topology is uniform, this function also generates coordinate 
// arrays not provided by the user.
//
bool grid3D::validGrid() {
    bool isValid = true;

    if (grid.m <= 0 || grid.n <= 0 || grid.o <=0) {
        logGridErr(MOLE_ERR_INVALID_GRID_SIZE, "grid3D[construct]", 
            to_string(grid.m));
        isValid = false;
    }

    // u = uniform, c = curvilinear, n = 'non-uniform
    switch (grid.topology) {
    case 'u': {
        if (!validSpacing(grid.dx) || !validSpacing(grid.dy) ||
            !validSpacing(grid.dz)) {
            string errmsg = "dx = " + to_string(grid.dx);
            errmsg += ", dy = " + to_string(grid.dy);
            errmsg += ", dz = " + to_string(grid.dz);
            logGridErr(MOLE_ERR_INVALID_GRID_SPACING, 
                "grid3D[construct]", errmsg);
            isValid = false;
            break;
        }

        // Generate grid or validate user-provided coordinates
        Array1D xn(grid.m + 1), yn(grid.n + 1), zn(grid.o + 1);
        Array3D X(grid.m + 1, grid.n + 1, grid.o + 1, 0.0), 
                Y(grid.m + 1, grid.n + 1, grid.o + 1, 0.0),
                Z(grid.m + 1, grid.n + 1, grid.o + 1, 0.0);

        // Computing or verifying nodal coordinates
        // xn = (0:m) * dx; and yn = (0:n) * dy and zn = (0:o) * dz
        generateNodalPts(grid.m, grid.dx, xn);
        generateNodalPts(grid.n, grid.dy, yn);
        generateNodalPts(grid.o, grid.dz, zn);
        // [grid.nodes_X,grid.nodes_Y,grid.nodes_Z] = 
        //      nd3Dgrid(xn, yn, zn)
        nd3DGrid(xn, yn, zn, X, Y, Z);
        if (!valid3DCoordinates(grid.nodes_X, X, grid.dx, grid.dy,
                            grid.dz, grid.m+1, grid.n+1, grid.o+1,  
                            MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                            MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }
        if (!valid3DCoordinates(grid.nodes_Y, Y, grid.dx, grid.dy, 
                            grid.dz, grid.m+1, grid.n+1, grid.o+1, 
                            MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                            MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }
        if (!valid3DCoordinates(grid.nodes_Z, Z, grid.dx, grid.dy, 
                            grid.dz, grid.m+1, grid.n+1, grid.o+1, 
                            MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                            MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }                       
                 
        // Computing or verifying cell center coordinates
        // xc = [0, (0.5:m-0.5) * dx, m*dx],  
        // yc = [0, (0.5:n-0.5) * dy, n*dy], and 
        // zc = [0, (0.5:o-0.5) * dz, o*dz];
        // [grid.centers_X, grid.centers_Y, grid.center_Z] = 
        //          nd2Dgrid(xc, yc, zc); 
        Array1D xc(grid.m + 2), yc(grid.n + 2), zc(grid.o + 2);
        generateCenterPts(grid.m, grid.dx, xc);
        generateCenterPts(grid.n, grid.dy, yc);
        generateCenterPts(grid.o, grid.dz, zc);

        X.resize(grid.m + 2, grid.n + 2, grid.o + 2);
        Y.resize(grid.m + 2, grid.n + 2, grid.o + 2);
        Z.resize(grid.m + 2, grid.n + 2, grid.o + 2);
        nd3DGrid(xc, yc, zc, X, Y, Z);

        if (!valid3DCoordinates(grid.centers_X, X, grid.dx, grid.dy,
                            grid.dz, grid.m+2, grid.n+2, grid.o+2, 
                            MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                            MOLE_ERR_INVALID_NODAL_COORDINATES)){
                isValid = false;
        }
        if (!valid3DCoordinates(grid.centers_Y, Y, grid.dx, grid.dy, 
                            grid.dz, grid.m+2, grid.n+2, grid.o+2, 
                            MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                            MOLE_ERR_INVALID_NODAL_COORDINATES )){
                isValid = false;
        }
        if (!valid3DCoordinates(grid.centers_Z, Z, grid.dx, grid.dy, 
                            grid.dz, grid.m+2, grid.n+2, grid.o+2, 
                            MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                            MOLE_ERR_INVALID_NODAL_COORDINATES )){
                isValid = false;
        }
        // Computing and validating normal faces 
        // xv=(0.5:m-0.5)*dx yu=(0.5:n-0.5)*dy and zu=(0.5:o-0.5)*dz; 
        // xu = xn, yv = yn, zw = zn, xw = xv, yw = yu, zv=zu
        // ndgrid(xn, yu, zu); dimension (m+1) x n x o
        // ndgrid(xv, yn, zv); dimension m x (n+1) x o
        // ndgrid(xw, yw, zn); dimension m x n x (o+1)
        Array1D yu(grid.n), xv(grid.m), zu(grid.o); 
        // xv = xc[1:m], yu = yc[1:n]. zu = zc[1:o]
        std::copy(xc.begin() + 1, xc.begin() + grid.m+1, xv.begin());
        std::copy(yc.begin() + 1, yc.begin() + grid.n+1, yu.begin());
        std::copy(zc.begin() + 1, zc.begin() + grid.o+1, zu.begin());

        // [grid.faces_u_X, grid.faces_u_Y, grid.faces_u_Z] = 
        // nd3grid(xu=xn, yu, zu);
        X.resize(grid.m+1, grid.n, grid.o);
        Y.resize(grid.m+1, grid.n, grid.o);
        Z.resize(grid.m+1, grid.n, grid.o);
        nd3DGrid(xn, yu, zu, X, Y, Z);
        if (!valid3DCoordinates(grid.faces_u_X, X, grid.dx, grid.dy,
                                grid.dz, grid.m+1, grid.n, grid.o, 
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }
        if (!valid3DCoordinates(grid.faces_u_Y, Y, grid.dx, grid.dy,
                                grid.dz, grid.m+1, grid.n, grid.o, 
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
        if (!valid3DCoordinates(grid.faces_u_Z, Z, grid.dx, grid.dy,
                                grid.dz, grid.m+1, grid.n, grid.o, 
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
        // [grid.faces_v_X, grid.faces_v_Y, grid.faces_v_Z] = 
        // nd3grid(xv, yv=yn, zv=zu);
        X.resize(grid.m, grid.n+1, grid.o);
        Y.resize(grid.m, grid.n+1, grid.o);
        Z.resize(grid.m, grid.n+1, grid.o);
        nd3DGrid(xv, yn, zu, X, Y, Z);
        if (!valid3DCoordinates(grid.faces_v_X, X, grid.dx, grid.dy,
                                grid.dz, grid.m, grid.n+1, grid.o, 
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }
        if (!valid3DCoordinates(grid.faces_v_Y, Y, grid.dx, grid.dy,
                                grid.dz, grid.m, grid.n+1, grid.o,
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
       if (!valid3DCoordinates(grid.faces_v_Z, Z, grid.dx, grid.dy,
                                grid.dz, grid.m, grid.n+1, grid.o,
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
        // [grid.faces_w_X, grid.faces_w_Y, grid.faces_w_Z] = 
        // nd3grid(xw=xv, yw=yu, zw=zn);
        X.resize(grid.m, grid.n, grid.o+1);
        Y.resize(grid.m, grid.n, grid.o+1);
        Z.resize(grid.m, grid.n, grid.o+1);
        nd3DGrid(xv, yu, zn, X, Y, Z);
        if (!valid3DCoordinates(grid.faces_w_X, X, grid.dx, grid.dy,
                                grid.dz, grid.m, grid.n, grid.o+1, 
                                MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
                                MOLE_ERR_INVALID_NODAL_COORDINATES)){
            isValid = false;
        }
        if (!valid3DCoordinates(grid.faces_w_Y, Y, grid.dx, grid.dy,
                                grid.dz, grid.m, grid.n, grid.o+1,
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
       if (!valid3DCoordinates(grid.faces_w_Z, Z, grid.dx, grid.dy,
                                grid.dz, grid.m, grid.n, grid.o+1,
                                MOLE_ERR_GRID_CENTERS_SZ_MISMATCH,
                                MOLE_ERR_INVALID_CENTER_COORDINATES)){
            isValid = false;                    
        }
        break;
    }
    case 'c':  // User must provide at least nodal coordinates
        if (grid.nodes_X.empty() || grid.nodes_Y.empty() ||
            grid.nodes_Z.empty()){
            logGridErr(MOLE_ERR_INVALID_CURVILINEAR_GRID, 
                    "grid3D[construct]", "");
            isValid = false;
            }
        break;
        

    case 'n':   // nonuniform grids require user-supplied nodes_X
        if (grid.nodes_X.empty() || grid.nodes_Y.empty() ||
            grid.nodes_Z.empty()) {
            logGridErr(MOLE_ERR_INVALID_NONUNIFORM_GRID, 
                        "grid3D[construct]", "");
            isValid = false;
            }
        break;
    default: // invalid grid topology 
        string errmsg = string_topology(grid.topology);
        logGridErr(MOLE_ERR_INVALID_GRID_TOPOLOGY, 
                    "grid3D[construct]", errmsg);
        isValid = false;
        break;   
    }

    if (isValid) setGridValidated();
    return isValid;
}

//
// This grid3D constructor creates and validates a 3D grid. 
// User needs to input at least m, n, o, dx, dy, dz and topology in 
// a gridParam3D structure, and optionally they can also provide the
// grid coordinate arrays  (nodes_X, Nodes_Y, Nodes_Z, centers_X, 
// centers_Y, centers_Z, and faces).  This function also initializes
// the GridBase error_log. For curvilinear and nonuniform grids, 
// users need to providal nodal grid information
//
grid3D::grid3D(gridParams3D p3): gridBase(3) {
    grid.m = p3.m; 
    grid.n = p3.n;
    grid.o = p3.o;
    grid.topology = p3.topology;
    grid.dx = p3.dx; 
    grid.dy = p3.dy;
    grid.dz = p3.dz;
    grid.bc_isPeriodic[0] = p3.bc_isPeriodic[0];
    grid.bc_isPeriodic[1] = p3.bc_isPeriodic[1]; 
    grid.bc_isPeriodic[2] = p3.bc_isPeriodic[2];
    grid.nodes_X = p3.nodes_X;
    grid.nodes_Y = p3.nodes_Y;
    grid.nodes_Z = p3.nodes_Z;
    grid.centers_X = p3.centers_X;
    grid.centers_Y = p3.centers_Y;
    grid.centers_Z = p3.centers_Z;
    grid.faces_u_X = p3.faces_u_X;
    grid.faces_u_Y = p3.faces_u_Y; 
    grid.faces_u_Z = p3.faces_u_Z;
    grid.faces_v_X = p3.faces_v_X;
    grid.faces_v_Y = p3.faces_v_Y;
    grid.faces_v_Z = p3.faces_v_Z;
    grid.faces_w_X = p3.faces_w_X;
    grid.faces_w_Y = p3.faces_w_Y;
    grid.faces_w_Z = p3.faces_w_Z;

    if (!validGrid()){
        // log error that grid was not generated
        string errmsg = "3D ";
        errmsg += string_topology(grid.topology);
        errmsg += ", m cells = " + to_string(grid.m);
        errmsg += ", n cells = " + to_string(grid.n);
        errmsg += ", o cells = " + to_string(grid.o);
        errmsg += ", dx = "+to_string(grid.dx);
        errmsg += ", dy = "+to_string(grid.dy);
        errmsg += ", dz = "+to_string(grid.dz)+", x-Periodic = ";
        if (grid.bc_isPeriodic[0]) errmsg += "YES";
        else errmsg +="NO";
        errmsg += ", y-Periodic = ";
        if (grid.bc_isPeriodic[1]) errmsg += "YES";
        else errmsg +="NO"; 
        errmsg += ", z-Periodic = ";
        if (grid.bc_isPeriodic[2]) errmsg += "YES.";
        else errmsg +="NO.";
        logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid3D[grid3D constructor]", errmsg);
    }
}

//
// Like the grid3D constructor, this constructor also creates and 
// validates a user supplied grid. The similar minimum requirements
// apply to a gridParams3D. The inners contains previously logged
// errors that need to be accumulated with the MOLE grid.
//
grid3D::grid3D(gridParams3D p3, 
                const stack<MOLE_Errors>& inerrs): gridBase(3) {
    grid.m = p3.m; 
    grid.n = p3.n;
    grid.o = p3.o;
    grid.topology = p3.topology;
    grid.dx = p3.dx; 
    grid.dy = p3.dy;
    grid.dz = p3.dz;
    grid.bc_isPeriodic[0] = p3.bc_isPeriodic[0];
    grid.bc_isPeriodic[1] = p3.bc_isPeriodic[1]; 
    grid.bc_isPeriodic[2] = p3.bc_isPeriodic[2];
    grid.nodes_X = p3.nodes_X;
    grid.nodes_Y = p3.nodes_Y;
    grid.nodes_Z = p3.nodes_Z;
    grid.centers_X = p3.centers_X;
    grid.centers_Y = p3.centers_Y;
    grid.centers_Z = p3.centers_Z;
    grid.faces_u_X = p3.faces_u_X;
    grid.faces_u_Y = p3.faces_u_Y; 
    grid.faces_u_Z = p3.faces_u_Z;
    grid.faces_v_X = p3.faces_v_X;
    grid.faces_v_Y = p3.faces_v_Y;
    grid.faces_v_Z = p3.faces_v_Z;
    grid.faces_w_X = p3.faces_w_X;
    grid.faces_w_Y = p3.faces_w_Y;
    grid.faces_w_Z = p3.faces_w_Z;

    // scan the error log for previous errors
    stack<MOLE_Errors> tmp_stk = inerrs;
    while (!tmp_stk.empty()){
        logGridErr(tmp_stk.top().errCode, tmp_stk.top().errLocation,
                    tmp_stk.top().paramError);
        tmp_stk.pop();
    }

    if (!validGrid()){
        // log error that grid was not generated
        string errmsg = "3D ";
        errmsg += string_topology(grid.topology);
        errmsg += ", m cells = " + to_string(grid.m);
        errmsg += ", n cells = " + to_string(grid.n);
        errmsg += ", o cells = " + to_string(grid.o);
        errmsg += ", dx = "+to_string(grid.dx);
        errmsg += ", dy = "+to_string(grid.dy);
        errmsg += ", dz = "+to_string(grid.dz)+", x-Periodic = ";
        if (grid.bc_isPeriodic[0]) errmsg += "YES";
        else errmsg +="NO";
        errmsg += ", y-Periodic = ";
        if (grid.bc_isPeriodic[1]) errmsg += "YES";
        else errmsg +="NO"; 
        errmsg += ", z-Periodic = ";
        if (grid.bc_isPeriodic[2]) errmsg += "YES.";
        else errmsg +="NO.";
        logGridErr(MOLE_ERR_GRID_CONSTRUCTION_FAILED, 
                "grid3D[grid3D constructor]", errmsg);
    }
}
// ------------------------------------------------------------------
//
// MOLE gridNull Class methods (declarations in MOLE_grid.h)
//
// ------------------------------------------------------------------
//
// gridNull sole constructor requires a paramsNull struct and errors
//
gridNull::gridNull(paramsNull in_p, 
                const stack<MOLE_Errors>& inerrs): gridBase(0){
    // scan the error log for previous errors
    stack<MOLE_Errors> tmp_stk = inerrs;
    while (!tmp_stk.empty()){
        logGridErr(tmp_stk.top().errCode, tmp_stk.top().errLocation,
                    tmp_stk.top().paramError);
        tmp_stk.pop();
    }
    if(ErrData.num_errs == 0){
        ErrData.num_errs  = inerrs.size();
    } else {
        ErrData.num_errs += inerrs.size();
    }
    ErrData.type_errs.push("MOLE Grid");
}
// ----------------------------------------------------------------
// 
// gridVar makeGrid is a factory function that works for any of the 3 
// grid dimensionalities, intended for cases when the users need to 
// define the dimensionality at runtime. The function takes a variant
// grid structure paramVars and produces a variant grid class gridVar
//
// ----------------------------------------------------------------
gridVar makeGrid(paramVars params, const stack<MOLE_Errors>& errs){
    // you need to include the errors that are already in the 
    // stack to the 
    // the corresponding grid structure
    return std::visit([&errs](auto&& p) -> gridVar {
        using T = std::decay_t<decltype(p)>;
        if constexpr (std::is_same_v<T, gridParams1D>) { 
            return grid1D(p, errs);
        } else if constexpr (std::is_same_v<T, gridParams2D>) {
            return grid2D(p, errs);
        } else if constexpr (std::is_same_v<T, gridParams3D>){
            return grid3D(p, errs);
        } else if constexpr (std::is_same_v<T, paramsNull>){
            return gridNull(p, errs);
        }
        
    }, params);
}

// ---------------------------------------------------------
// Dispatch function which takes a gridVar (generic grid) and
// validates it using the instantiated MOLE grid class (i.e.,
// grid1D, grid2D or grid3D) for the actual grid validation
// ---------------------------------------------------------
bool isValidGrid(gridVar& g) {
    return std::visit([](auto&& gridObj) 
    { return gridObj.validGrid(); }, g);
}

