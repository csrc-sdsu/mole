/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * @file MOLE_Errors.h
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
// Predefined error codes for the MOLE library. These codes are used
// to identify specific errors that may occur during the execution 
// of MOLE functions. These error symbols are used throughout the 
// MOLE library to provide consistent error handling and reporting.
//
// Initialization Errors. 001 = grid not validated
//
#define MOLE_ERR_GRID_UNCHECKED 001   // Grid has not been validated
#define MOLE_ERR_INVALID_GRID_ARGS 002 // Grid is invalid
#define MOLE_ERR_GRID_CONSTRUCTION_FAILED 003
#define MAKE_GRID_INVALID_INPUT_ARGS 004
#define MAKE_GRID_MISSING_ARGS 005
#define MAKE_GRID_UNKNOWN_ATTRIBUTE 006
#define MAKE_GRID_DUPLICATE_ATTRIBUTES 007
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
#define MOLE_ERR_INVALID_NORMAL_FACE_COORDINATES 118 // invalid coords

//
// Flat array defition Errors. sError codes 200-299
//
#define MOLE_ERR_INVALID_ARRAY_SIZE 200 //invalid array sizes
#define MOLE_ERR_ARRAY_SIZE_OVERFLOW 201 // array allocation overflow
#define MOLE_ERR_ARRAY_INDEX_OUTBOUNDS 202 // array index out of bounds

//
// Dictionary of error codes and their corresponding messages 
// for printing error messages in the MOLE library.
//
static unordered_map<int, string> MOLE_errors_messages = {
    // 001
    {MOLE_ERR_GRID_UNCHECKED, 
    "Grid has not been validated, call validateGrid() first"},
     // 002
    {MOLE_ERR_INVALID_GRID_ARGS, 
    "Error(s) in input parameters, resulting MOLE grid is invalid."},
     // 003
    {MOLE_ERR_GRID_CONSTRUCTION_FAILED,
    "Grid construction failed, review the list of errors"},
     // 004
    {MAKE_GRID_INVALID_INPUT_ARGS, ""},
    // 005
    {MAKE_GRID_MISSING_ARGS,""},
    // 006 
    {MAKE_GRID_UNKNOWN_ATTRIBUTE,""},
    // 007
    {MAKE_GRID_DUPLICATE_ATTRIBUTES,""},
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
    {MOLE_ERR_INVALID_NORMAL_FACE_COORDINATES,
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
};

// MOLE errors are stored in a stack to allow tracking and 
// backtracking of errors. Every error entry contains the error code, 
// the location (MOLE function name) where the error occurred, and 
// an optional input value that caused the error (this can be a 
// concatenation of parameters).
#include <stack> // Using std stack class

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
bool MOLEerr_contains(const stack<MOLE_Errors> errorStack, int targetCode);

// 4. Checks whether there are any errors in the stack
bool MOLEerr_haserrors(stack<MOLE_Errors>& errorStack);

// 5. Removes a specific error from the stack
void MOLEerr_remove(stack<MOLE_Errors>& errorStack, int targetCode);

// 6. These functions are used for printing the error stack to 
// standard output
void MOLEerr_print(const stack<MOLE_Errors>& errorStack);

// 7. Writes error output to a log file (not implemented yet)
void MOLEerr_dumpErrLog(stack<MOLE_Errors>& errorStack, string logType);

// ParamsNull is a struct used for reporting errors with any
// MOLE objects (classes). The structure can accumulate errors from
// other MOLE classes (i.e, grids, boundaries, etc)in type_errs
struct paramsNull {
    size_t num_errs = 0; // Number of errors
    stack<string> type_errs; // Types of MOLE errors 
};


#endif // MOLE_ERRORS_H