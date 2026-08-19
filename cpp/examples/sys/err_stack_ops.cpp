/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research 
 * Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html 
 * for details.
 */

/*
 * @file err_stack_ops.cpp
 *
 * @brief 8 examples of MOLE error handling functionality
 *
 * @date 2026/08/12
 *
 */
#include "MOLE_errors.h"
#include <vector>       // not needed if using "MOLE_grids.h" or 
                        // "MOLE_arrays.h" or MD operators
int main() {
    cout << "==============================================" << endl;
    cout << "This is a DEMO Of MOLE's error log mechanism "  << endl;   
    cout << "==============================================" << endl;  

    std::stack<MOLE_Errors> errs;    // Must declare a error stack
    cout << "The first operation: initializes an error log " << endl;  
    cout << "----------------------------------------------" << endl;
    // 1. Initialize the error stack (stack is empty)
    MOLEerr_init(errs);

    // 2. Logging an error into the stack after attempting to access
    //    an outbound entry in an array.  For more predefine MOLE
    //    error codes like MOLE_ERR_ARRAY_INDEX_OUTBOUNDS check
    //    MOLE_errors.h
    size_t array_size = 10;
    vector<double> x(10); 
    cout << "The second operation: logs an error to the stack"<< endl;   
    cout << "----------------------------------------------" << endl;
    for(size_t i = 0; i < 11; i++){
        if (i >= array_size){
            string emsg;
            emsg  = "index i = " + to_string(i) + " is >= ";
            emsg += "array_size: " + to_string(array_size); 
            // The Syntax for MOLEerr_log is:
            //  MOLEerr_log(errorStack : type stack<MOLE_Errors>,
            //              errCode : predefined interger error code
            //                       (see MOLE_errors.h for details),
            //              errlocation: a string identifier of the
            //                     location where the error occurred, 
            //              errParams (optional) : can be empty or
            //                      any information about the values
            //                      in the arguments (e.g, index i)
            MOLEerr_log(errs, MOLE_ERR_ARRAY_INDEX_OUTBOUNDS, 
                "MOLE_Example", emsg);
        }
    }

    // 3. Check if a particular error has been logged into the stack
    cout << "The third operation: checks for a particular error "
         << "in the stack. The error was previously logged." << endl;   
    if (MOLEerr_contains(errs, MOLE_ERR_ARRAY_INDEX_OUTBOUNDS)){
        cout << "[correct] error = MOLE_ERR_ARRAY_INDEX_OUTBOUNDS";
        cout << " was just logged into the stack" << endl;
    } else {
        cout << "Unexpected behavior occurred"
             << " Please, report this issue by opening an issue at: "
             << " https://github.com/csrc-sdsu/mole" << endl;
    }
    // 4. Writing errors to Standard Output
    cout << "----------------------------------------------" << endl;
    cout << "The fourth operation: writes error to stdout." << endl;
    cout << "The output follows this line." << endl;
    MOLEerr_print(errs);
    
    // 5. Creating a file containing the only error message
    cout << "==============================================" << endl;  
    cout << "The fifth operation: writes errors to an error file "
         << "with filename = err_stack_ops + <timestamp>" << endl;
    cout << "==============================================" << endl;  
    MOLEerr_dumpErrLog(errs, "err_stack_ops");
    cout << "File was created. Check your current directory." << endl;
    cout << "----------------------------------------------" << endl;

    // 6. check if the stack has errors, and 7. remove a particular 
    //  error from the stack (in this case the stack wiil be emptied)
    cout << "----------------------------------------------" << endl;
    cout << "The sixth and seventh operations: check for errors" << endl;
    cout << "in the stack and deletes the only error" << endl;
    cout << "----------------------------------------------" << endl;
    if (MOLEerr_haserrors(errs)){
        MOLEerr_remove(errs, MOLE_ERR_ARRAY_INDEX_OUTBOUNDS);
        cout << "[correct] Error found and now removed. The" << endl;
        cout << "8th operation should find an empty stack"  << endl;
    }


    // 8. check if stack is empty
    cout << "----------------------------------------------" << endl;
    cout << "The eight operation: checks for an empty stack" << endl;
    cout << "----------------------------------------------" << endl;
    if (errs.empty())             // The stack must be empty 
        cout << "[correct] Error stack is now empty" << endl;
    else
        cout << "Abnormal behavior after removing error from stack."
             << " Please, report this issue by opening an issue at: "
             << " https://github.com/csrc-sdsu/mole" << endl;
}
