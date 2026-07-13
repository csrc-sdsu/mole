/*
* SPDX-License-Identifier: GPL-3.0-or-later
* © 2008-2024 San Diego State University Research Foundation (SDSURF).
* See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details. 
*/
 
/*
 * @file mole_errors.cpp
 * 
 * @brief MOLE Error Handling and Tracking
 * 
 * @date 2026/06/24
 * 
 */

 #include "MOLE_Errors.h"

 // This function initializes the error stack by 
 // clearing any existing errors and setting grid validation
 // error to ensure the grid is validated before proceeding with 
 // MOLE operations.
 void MOLEerr_init(stack<MOLE_Errors>& errorStack){
    MOLE_Errors err;
    errorStack = stack<MOLE_Errors>(); // Clear the stack

    err.errCode = MOLE_ERR_GRID_UNCHECKED;
    err.errLocation = "NEW MOLE GRID";
    err.paramError = "";
    errorStack.push(err);
}

// This function pushes an error onto the error stack
void MOLEerr_log(stack<MOLE_Errors>& errorStack, int errCode, 
    const string& location, const string& inputParam = ""){
    MOLE_Errors err;
    err.errCode = errCode;
    err.errLocation = location;
    err.paramError = inputParam;
    errorStack.push(err);
}

// This is an auxiliary function that checks whether a specific error
// code exists in the error stack. It returns true if the error code is found, 
// otherwise false (this is used my MOLEerr_validgrid)
bool MOLEerr_contains(const stack<MOLE_Errors> errorStack, int targetCode) {
    stack<MOLE_Errors> tempStack = errorStack;
    while (!tempStack.empty()) {
        if (tempStack.top().errCode == targetCode) return true;
        tempStack.pop();
    }
    return false;
}

// This function checks whether there are any errors logged in 
// the error stack. It returns true if there are errors.
bool MOLEerr_haserrors(stack<MOLE_Errors>& errorStack)
{
    return !errorStack.empty();
}

// This function removes a specific error from the error stack.
// errorStack is passed by reference. The targetCode is the error 
// code to be removed. 
void MOLEerr_remove(stack<MOLE_Errors>& errorStack, int targetCode) {
    stack<MOLE_Errors> tempStack;

    // Pop everything, keep the elements we want, reverse order into tempStack
    while (!errorStack.empty()) {
        MOLE_Errors err = errorStack.top();
        errorStack.pop();
        if (err.errCode != targetCode) {
            tempStack.push(err);
        }
    }

    // tempStack now has the kept elements in reverse order — 
    // push back to restore original order
    while (!tempStack.empty()) {
        errorStack.push(tempStack.top());
        tempStack.pop();
    }
}

// This auxiliaryfunction prints out any error arguments logged 
// in the error stack. It is used inside MOLEerr_print.
void MOLEerr_print_args(const string& strargx) {
    if (!strargx.empty()) {
        cout << ", with input parameter sent: " << strargx << endl;
    } else {
        cout << endl;
    }
}

// This function prints out any errors logged in the stack.
// it preserves the error stack for other user support and debugging.
void MOLEerr_print(const stack<MOLE_Errors>& errorStack){
    // Create a copy to preserve the original stack
    stack<MOLE_ErrStack> tempStack = errorStack;
    if (tempStack.empty()) {
        cout << "No errors logged." << endl;
        return;
    }
    while (!tempStack.empty()) {
        MOLE_ErrStack err = tempStack.top();
        tempStack.pop();
        if (err.errCode == MOLE_ERR_GRID_UNCHECKED) {
            cout << MOLE_errors_messages[err.errCode] << endl;
            continue;
        }
        auto errMsg = MOLE_errors_messages.find(err.errCode);
        if (errMsg != MOLE_errors_messages.end()) { 
            cout << "Error [" << err.errCode << "]: " 
                 << errMsg->second << "\n"
                 << "occurred inside a call to: " << err.errLocation; 
            MOLEerr_print_args(err.paramError);
        } else {
            cout << "Error [" << err.errCode << "]: " 
                    << "Unknown MOLE error code "
                    << "occurred inside a call to: " 
                    << err.errLocation << "\n"; 
        }
    }

}
