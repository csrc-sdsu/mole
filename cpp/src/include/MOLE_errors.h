/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research 
 * Foundation (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html 
 * for details.
 */

/*
 * @file MOLE_errors.h
 *
 * @brief Error handling for the MOLE library.
 *
 * @date 2026/06/24
 *
 */
#ifndef MOLE_ERRORS_H
#define MOLE_ERRORS_H

#include <iostream>
#include <unordered_map>
#include <string>

using namespace std;
// MOLE errors are stored in a stack to allow tracking and 
// backtracking of errors. Every error entry contains the error code, 
// the location (MOLE function name) where the error occurred, and 
// an optional input value that caused the error (this can be a 
// concatenation of parameters).
#include <stack> // Using std stack class

// 
// MOLE DEBUGGING MODES
//
// We will define the following MOLE library debug modes. 
// The MOLE library has been designed in a way that it does not 
// break the execution of a user code, instead it creates and 
// maintains an error logging mechanism that allows users to 
// check for possible errors after a MOLE operation. In addition, 
// the logged errors can be reported to std output or to a file.

// 1. DEBUG_DEFAULT_MD (default behaviour - returns a grid 
// that has errors)
// <MOLEObject>.hasError (e.g., hasGridErrors()) 
// Users and application builders are responsible for checking
//  for errors and implementing their error corrections.
// What support does a user get from the MOLE library at this point?
//  A user can call MOLE functions to either:
// A: print the errors to standard output
// B: print errors to a file

// 2. DEBUG_REPORTS_STDOUT_MD (has to be passed to the MOLE API - 
// returns an object that has errors )
// The MOLE library will report errors to standard output and return 
// control to the users. What support does a user get from the MOLE 
// library at this point?
// A user can call MOLE functions to either:
// A: print the errors to standard output
// B: print errors to a file

// 3. DEBUG_AND_ABORT_MD (Report, then raise SIGTRAP so a debugger
// stops at that particular failure point). The MOLE library will
// report errors to standard output and raise SIGTRAP. Without a
// debugger or signal handler attached, the process terminates.

// A debug mode governs only what happens to a MOLE object that
// failed validation. An object that validated is unaffected by the
// mode it was built with. The mode is not a property of the object;
// it is applied once, at construction, and is not stored.
#define DEBUG_DEFAULT_MD 0
#define DEBUG_REPORTS_STDOUT_MD 1
#define DEBUG_AND_SIGTRAP_MD  2
#define DEBUG_AND_ABORT_MD   3

// Predefined error codes for the MOLE library. These codes are used
// to identify specific errors that may occur during the execution 
// of MOLE functions. These error symbols are used throughout the 
// MOLE library to provide consistent error handling and reporting.
//
// Initialization Errors. 10 - 99 gridBuilder errors
//
#define MOLE_ERR_GRID_UNCHECKED 11   // Grid has not been validated
#define MOLE_ERR_GRID_FLAGGED_W_ERRS 12 // Grid flagged with errors
#define MOLE_ERR_INVALID_GRID_ARGS 13 // Grid is invalid
#define MOLE_ERR_GRID_CONSTRUCTION_FAILED 14
#define MAKE_GRID_INVALID_INPUT_ARGS 15
#define MAKE_GRID_MISSING_ARGS 16
#define MAKE_GRID_UNKNOWN_ATTRIBUTE 17
#define MAKE_GRID_DUPLICATE_ATTRIBUTES 18
//
// Grid definition Errors. Error codes 100-199
//
#define MOLE_ERR_INVALID_GRID_DIM 100 // Invalid grid dimension
#define MOLE_ERR_INVALID_GRID_TOPOLOGY 101 // Invalid grid topology
#define MOLE_ERR_INVALID_GRID_SPACING 102 // Invalid grid spacing
#define MOLE_ERR_INVALID_GRID_SIZE 103 // Invalid grid size
#define MOLE_ERR_GRID_NODAL_SZ_MISMATCH 104 // nodal size mismatch
#define MOLE_ERR_GRID_CENTERS_SZ_MISMATCH 105 // center size mismatch
#define MOLE_ERR_GRID_FACES_SZ_MISMATCH 106 // faces size mismatch
#define MOLE_ERR_INVALID_INPUT_TYPE 107 // Invalid input type 
#define MOLE_ERR_ARRAY_HAS_NULL_POINTER 108 // Array has null pointer 
#define MOLE_ERR_INVALID_CELL_COUNT 109 // Invalid grid cell count
#define MOLE_ERR_INVALID_ISPERIODIC_DIM 110 // invalid array dim
#define MOLE_ERR_ISPERIODIC_TYPE 111 // invalid array type
#define MOLE_ERR_INVALID_CURVILINEAR_GRID 112 // Need nodal coordines
#define MOLE_ERR_INVALID_1D_CURVILINEAR 113 // 1D Curvilinear invalid
#define MOLE_ERR_INVALID_NONUNIFORM_GRID 114 // Need nodal coordines
#define MOLE_ERR_INVALID_ARRAY_INDEX 115 // invalid array indexing
#define MOLE_ERR_INVALID_NODAL_COORDINATES 116 // invalid user coords
#define MOLE_ERR_INVALID_CENTER_COORDINATES 117 // invalid user coords
#define MOLE_ERR_INVALID_NORMAL_FACE_COORDS 118 // invalid coords

//
// Flat array defition Errors. Error codes 200-299
//
#define MOLE_ERR_INVALID_ARRAY_SIZE 200 //invalid array sizes
#define MOLE_ERR_ARRAY_SIZE_OVERFLOW 201 // array allocation overflow
#define MOLE_ERR_ARRAY_INDEX_OUTBOUNDS 202 //array index out of bounds
#define MOLE_ERR_FAILED_ARRAY_ALLOC 203 // array alloc failed
#define MOLE_ERR_FAILED_ARRAY_RESIZE 204 // array resize failed

//
// MD Operators and Numerical Errors codes 300 - 499
//
#define MOLE_ERR_DIVISION_BY_ZERO 300
#define MOLE_ERR_INF_VALUE 301
#define MOLE_ERR_NAN_VALUE 302
// PROVISIONAL: names, numbers and messages for 303-308 are pending
// sign-off.
#define MOLE_ERR_OP_INVALID_ORDER 303 // k is not 2, 4, 6 or 8
#define MOLE_ERR_OP_GRID_HAS_ERRORS 304 // input grid has errors
#define MOLE_ERR_OP_INSUFFICIENT_CELLS 305 // cells < 2k along an axis
#define MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY 306 // grid is not uniform
#define MOLE_ERR_OP_INPUT_SIZE_MISMATCH 307 // apply() input size wrong
#define MOLE_ERR_OP_NOT_BUILT 308 // operator not built from a grid

//
// Utils Errors. Error codes 500 - 599
//
#define MOLE_ERR_UTILS_INVALID_MESH_SIZE 500 // empty meshgrid input
#define MOLE_ERR_UTILS_SIZE_MISMATCH 501 // trapz x, y sizes differ
#define MOLE_ERR_UTILS_ROW_MISMATCH 502 // spjoin_rows A, B rows differ
#define MOLE_ERR_UTILS_COL_MISMATCH 503 // spjoin_cols A, B cols differ
#define MOLE_ERR_UTILS_NOT_SQUARE 504 // spsolve_eigen A not square
#define MOLE_ERR_UTILS_RHS_ROW_MISMATCH 505 // spsolve_eigen A, b rows
#define MOLE_ERR_UTILS_SINGULAR_MATRIX 506 // spsolve_eigen A singular
#define MOLE_ERR_UTILS_TOO_FEW_POINTS 507 // trapz needs >= 2 points

//
// Dictionary of error codes and their corresponding messages 
// for printing error messages in the MOLE library.
//
static unordered_map<int, string> MOLE_errors_messages = {
    // 011
    {MOLE_ERR_GRID_UNCHECKED, 
    "Grid has not been validated, call validateGrid() first"},
    // 012
    {MOLE_ERR_GRID_FLAGGED_W_ERRS,
    "Grid has errors and is flagged as invalid"},
     // 013
    {MOLE_ERR_INVALID_GRID_ARGS, 
    "Error(s) in input parameters, resulting MOLE grid is invalid."},
     // 014
    {MOLE_ERR_GRID_CONSTRUCTION_FAILED,
    "Grid construction failed, review the list of errors"},
     // 015
    {MAKE_GRID_INVALID_INPUT_ARGS,
    "Grid attribute value has the wrong type for that attribute"},
    // 016
    {MAKE_GRID_MISSING_ARGS,
    "A required grid attribute was not supplied"},
    // 017
    {MAKE_GRID_UNKNOWN_ATTRIBUTE,
    "Not a MOLE grid attribute name. Parsing stops here, because "
    "the type of the value following an unknown name is unknown"},
    // 018
    {MAKE_GRID_DUPLICATE_ATTRIBUTES,
    "Grid attribute supplied more than once"},
    // 100
    {MOLE_ERR_INVALID_GRID_DIM, 
    "Invalid grid dimension entered. Valid values are 1, 2, or 3"},
    // 101
    {MOLE_ERR_INVALID_GRID_TOPOLOGY, 
    "Invalid grid topology entered. Valid values are 'u'=uniform "
    "or 'c'=curvilinear) or 'n'=non-uniform"},
    // 102
    {MOLE_ERR_INVALID_GRID_SPACING, 
    "Grid spacing must be > 0.0 and a valid, finite real number"},
    // 103
    {MOLE_ERR_INVALID_GRID_SIZE, 
    "Grid size must be a natural number > 0"},
    // 104
    {MOLE_ERR_GRID_NODAL_SZ_MISMATCH, 
    "Nodal grid coordinates array size mismatch"},
    // 105
    {MOLE_ERR_GRID_CENTERS_SZ_MISMATCH, 
    "Center grid coordinates array size mismatch"},
    // 106
    {MOLE_ERR_GRID_FACES_SZ_MISMATCH, 
    "Normal faces coordinates array size mismatch"},
    // 107
    {MOLE_ERR_INVALID_INPUT_TYPE, 
        "Invalid input type for input name"},
    // 108
    {MOLE_ERR_ARRAY_HAS_NULL_POINTER, 
    "Array has a null pointer. Array allocation may have failed"},
    // 109
    {MOLE_ERR_INVALID_CELL_COUNT, "Non-positive cell count"},
    // 110
    {MOLE_ERR_INVALID_ISPERIODIC_DIM, 
        "Wrong size for isPeriodic 1D:(1x1), 2D:(2x1), 3D:(3x1)"},
    // 111
    {MOLE_ERR_ISPERIODIC_TYPE, 
        "isPeriodic requires a boolean array"},
    // 112
    {MOLE_ERR_INVALID_CURVILINEAR_GRID, 
    "Curvilinear grids need user-provided nodal coordinates"},
    // 113
    {MOLE_ERR_INVALID_1D_CURVILINEAR, 
    "Curvilinear grids fundamentally cannot be one dimensional"},
    // 114
    {MOLE_ERR_INVALID_NONUNIFORM_GRID, 
    "Non-uniform grids need user-provided nodal coordinates"},
    // 115
    {MOLE_ERR_INVALID_ARRAY_INDEX,
    "One or more indices to the array are out of bound," 
    "check array dimensions"},
    // 116
    {MOLE_ERR_INVALID_NODAL_COORDINATES, 
    "User-provided nodal coordinates do not agree with other "
    "uniform grid parameters passed"},
    // 117
    {MOLE_ERR_INVALID_CENTER_COORDINATES, 
    "User-provided center coordinates do not agree with other "
    "uniform grid parameters passed"},
    // 118
    {MOLE_ERR_INVALID_NORMAL_FACE_COORDS,
    "User-provided normal face coordinates do not agree with "
    "other uniform grid parameters passed"},
    // 200
    {MOLE_ERR_INVALID_ARRAY_SIZE,
    "Array dimensions need to be natural numbers >= 1"},
    // 201
    {MOLE_ERR_ARRAY_SIZE_OVERFLOW,
    "Array dimensions too large to fit in memory"},
    // 202
    {MOLE_ERR_ARRAY_INDEX_OUTBOUNDS,
    "Array index is out of bounds." },
    // 203
    {MOLE_ERR_FAILED_ARRAY_ALLOC, "Array allocation failed."},
    // 204
    {MOLE_ERR_FAILED_ARRAY_RESIZE, "Array resize operation failed."},
    // 300
    {MOLE_ERR_DIVISION_BY_ZERO, "Division by zero."},
    // 301
    {MOLE_ERR_INF_VALUE, "Infinity value detected."},
    // 302
    {MOLE_ERR_NAN_VALUE, "NaN value detected."},
    // 303 - 308 (PROVISIONAL, pending sign-off)
    {MOLE_ERR_OP_INVALID_ORDER,
    "Operator order k must be 2, 4, 6 or 8."},
    {MOLE_ERR_OP_GRID_HAS_ERRORS,
    "Operator cannot be built because the input grid has errors."},
    {MOLE_ERR_OP_INSUFFICIENT_CELLS,
    "Number of cells along an axis must be at least 2k."},
    {MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY,
    "Operator supports uniform grids only."},
    {MOLE_ERR_OP_INPUT_SIZE_MISMATCH,
    "Input array size does not match the operator."},
    {MOLE_ERR_OP_NOT_BUILT,
    "Operator was not built from a grid."},
    // 500
    {MOLE_ERR_UTILS_INVALID_MESH_SIZE,
    "Meshgrid input vectors must have at least one element."},
    // 501
    {MOLE_ERR_UTILS_SIZE_MISMATCH,
    "Input vectors x and y must have the same number of elements."},
    // 502
    {MOLE_ERR_UTILS_ROW_MISMATCH,
    "Matrices A and B must have the same number of rows."},
    // 503
    {MOLE_ERR_UTILS_COL_MISMATCH,
    "Matrices A and B must have the same number of columns."},
    // 504
    {MOLE_ERR_UTILS_NOT_SQUARE,
    "Matrix A must be square."},
    // 505
    {MOLE_ERR_UTILS_RHS_ROW_MISMATCH,
    "The number of rows in A differs from the ones in rhs."},
    // 506
    {MOLE_ERR_UTILS_SINGULAR_MATRIX,
    "Factorization error: Matrix is singular."},
    // 507
    {MOLE_ERR_UTILS_TOO_FEW_POINTS,
    "Input vectors x and y must have at least two elements."},
};

// MOLE_Error basic structure a stack of this structure is used to
// keep track of errors that occur within the MOLE framework.
struct MOLE_Errors {
    int errCode; // Logged error codes
    string errLocation; // Report location where the error occurred 
    string paramError;  // Holds additional information on the error
};

// MOLE_Error General Stack Operations
// 1. Initializes the error stack  
void MOLEerr_init(stack<MOLE_Errors>& errorStack);

// 2. Pushes an error onto the error stack
void MOLEerr_log(stack<MOLE_Errors>& errorStack, int errCode, 
    const string& location, const string& inputParam = "");

// 3. Checks whether the error stack contains a specific error code
bool MOLEerr_contains(const stack<MOLE_Errors>& errorStack, int targetCode);

// 4. Checks whether there are any errors in the stack. 
bool MOLEerr_haserrors(const stack<MOLE_Errors>& errorStack);

// 5. Removes a specific error from the stack
void MOLEerr_remove(stack<MOLE_Errors>& errorStack, int targetCode);

// 6. These functions are used for printing the error stack to 
// standard output
void MOLEerr_print(const stack<MOLE_Errors>& errorStack);

// 7. Writes error output to a log file (not implemented yet)
void MOLEerr_dumpErrLog(stack<MOLE_Errors>& errorStack, string logType);

// ParamsNull is a struct used for reporting errors with any
// MOLE Grid Objects whenever the grid dimensionality has not been
// determined, and errors are occurring.
struct paramsNull {
    size_t num_errs = 0; // Number of errors
    stack<string> type_errs; // Types of MOLE errors 
};


#endif // MOLE_ERRORS_H
