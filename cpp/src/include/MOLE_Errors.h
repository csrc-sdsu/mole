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

// Initialization Errors. 001 = grid not validated
#define MOLE_ERR_GRID_UNCHECKED 001   // Grid has not been validated

// Grid definition Errors. Error codes 100-199
#define MOLE_ERR_INVALID_DIM 100 // Invalid grid dimension
#define MOLE_ERR_INVALID_TOPOLOGY 101 // Invalid grid topology
#define MOLE_ERR_INVALID_SPACING 102 // Invalid grid spacing
#define MOLE_ERR_INVALID_SIZE 103 // Invalid grid size
#define MOLE_ERR_NODE_MISMATCH 104 // Grid node array size mismatch
#define MOLE_ERR_CENTER_MISMATCH 105 // Grid center array size mismatch
#define MOLE_ERR_FACE_MISMATCH 106 // Grid face array size mismatch

// Dictionary of error codes and their corresponding messages 
// for printing error messages in the MOLE library.
static unordered_map<int, string> MOLE_errors_messages = {
    {MOLE_ERR_GRID_UNCHECKED, 
        "Grid has not been validated, call validateGrid() first"},
    {MOLE_ERR_INVALID_DIM, 
    "Invalid grid dimension entered. Valid values are 1, 2, or 3"},
    {MOLE_ERR_INVALID_TOPOLOGY, 
    "Invalid grid topology entered. Valid values are 'u'=uniform or 'c'=curvilinear) or 'n'=non-uniform"},
    {MOLE_ERR_INVALID_SPACING, "Grid spacing must be positive"},
    {MOLE_ERR_INVALID_SIZE, "Grid size must be positive"},
    {MOLE_ERR_NODE_MISMATCH, "Grid node array size mismatch"},
    {MOLE_ERR_CENTER_MISMATCH, "Grid center array size mismatch"},
    {MOLE_ERR_FACE_MISMATCH, "Grid face array size mismatch"},
};

// MOLE errors are stored in a stack to allow tracking and 
// backtracking of errors. Every error entry contains the error code, 
// the location (MOLE function name) where the error occurred, and 
// an optional input value that caused the error (this can be a 
// concatenation of parameters).
#include <stack> // Using std stack class

struct MOLE_Errors {
    int errCode; // Logged error codes
    string errLocation; // Location where the error occurred (function name)
    string paramError;  // when available, holds the invalid input value causing
};                           // the error

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
void MOLEerr_print(stack<MOLE_Errors>& errorStack);
void MOLEerr_print_args(const string& strargx);

// 8. Writes error output to a log file (not implemented yet)



#endif // MOLE_ERRORS_H