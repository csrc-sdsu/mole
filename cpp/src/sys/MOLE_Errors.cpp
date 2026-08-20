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

 #include "MOLE_errors.h"
 #include <ctime>
 #include <fstream>

 // This function initializes the error stack by 
 // clearing any existing errors
 void MOLEerr_init(stack<MOLE_Errors>& errorStack){
    errorStack = stack<MOLE_Errors>(); // Clear the stack
}

// This function pushes an error onto the error stack
// (default for inputParam is already given in the MOLE_Errors.h
// declaration; C++ forbids repeating it here)
void MOLEerr_log(stack<MOLE_Errors>& errorStack, int errCode, 
    const string& location, const string& inputParam){
    MOLE_Errors err;
    err.errCode = errCode;
    err.errLocation = location;
    err.paramError = inputParam;
    errorStack.push(err);
}

// This is an auxiliary function that checks whether a specific error
// code exists in the error stack. It returns true if the error code 
// is found, otherwise false.
bool MOLEerr_contains(const stack<MOLE_Errors>& errorStack, int targetCode) {
    stack<MOLE_Errors> tempStack = errorStack;
    while (!tempStack.empty()) {
        if (tempStack.top().errCode == targetCode) return true;
        tempStack.pop();
    }
    return false;
}

// This function checks whether there are any errors logged in 
// the error stack. It returns true if there are errors.
bool MOLEerr_haserrors(const stack<MOLE_Errors>& errorStack)
{
    return !errorStack.empty();
}

// This function removes a specific error from the error stack.
// errorStack is passed by reference. The targetCode is the error 
// code to be removed. 
void MOLEerr_remove(stack<MOLE_Errors>& errorStack, int targetCode) {
    stack<MOLE_Errors> tempStack;

    // Pop everything, keep the elements we want, reverse order 
    // into tempStack
    while (!errorStack.empty()) {
        MOLE_Errors err = errorStack.top();
        errorStack.pop();
        if (err.errCode != targetCode) {
            tempStack.push(err);
        }
    }

    // tempStack now has kept elements in reverse order — 
    // push back to restore the backtracing original order
    while (!tempStack.empty()) {
        errorStack.push(tempStack.top());
        tempStack.pop();
    }
}

// This auxiliaryfunction prints out any error arguments logged 
// in the error stack. It is used inside MOLEerr_print.
void MOLEerr_print_args(const string& strargx) {
    if (!strargx.empty()) {
        cout << "with arg value(s): " << strargx << endl;
    } else {
        cout << endl;
    }
}

// writeErrtoStOut writes an error to the log_error file
void writeErrtoStdOut(int errNum, int errCode, string errLocation, 
                      string errParams, const std::string& errMsg) {
    cout << "Error #" << errNum << ": MOLE Error code [" << 
          errCode << "] - "<< errMsg << endl;
    cout << "occurred inside:" << errLocation;
          MOLEerr_print_args(errParams);
}

// Produces a timestamp string to create a unique filename to output
// log_errors messages and backtracing information
std::string getDateTimeString() {
    std::time_t now = std::time(nullptr);
    char buf[100];
    std::strftime(buf, sizeof(buf), "%Y%m%d_%H%M%S", 
                  std::localtime(&now));
    return std::string(buf);
}

// MOLEerr_write_args is similar to MOLEerr_print_args but it writes 
// to a log_error file instead of standard output 
void MOLEerr_write_args(std::ofstream& ofile, 
                        const string& strargx) {
    if (!strargx.empty()) {
        ofile << "with arg value(s): " << strargx << endl;
    } else {
        ofile << endl;
    }
}

// writeErrtoFile writes an error to the log_error file
void writeErrtoFile(std::ofstream& ofile, int errNum, int errCode,
                  string errLocation, string errParams, 
                  const std::string& errMsg) {
    ofile << "Error #" << errNum << ": MOLE Error code [" << 
          errCode << "] - "<< errMsg << endl;
    ofile << "occurred inside:" << errLocation;
          MOLEerr_write_args(ofile, errParams);
}

// This function prints out to std output any errors logged in a
// stack, preserving the error stack for further enabled debugging.
void MOLEerr_print(const stack<MOLE_Errors>& errorStack){
    // Create a copy to preserve the original stack
    stack<MOLE_Errors> tempStack = errorStack;
    if (tempStack.empty()) {
        cout << "No errors logged." << endl;
        return;
    }
    cout << "========================================"<< endl;
    cout << "Backtracing all logged MOLE Errors :" << endl;
    cout << "========================================"<< endl;
    
    int i = 1;
    while (!tempStack.empty()) {
        MOLE_Errors err = tempStack.top();
        tempStack.pop();
        if (err.errCode == MOLE_ERR_GRID_UNCHECKED) {
            writeErrtoStdOut(i, err.errCode, err.errLocation, 
                err.paramError, MOLE_errors_messages[err.errCode]);
            i++;
            continue;
        }
        auto errMsg = MOLE_errors_messages.find(err.errCode);
        if (errMsg != MOLE_errors_messages.end()) { 
            writeErrtoStdOut(i, err.errCode, err.errLocation, 
                            err.paramError, errMsg->second);
        } else {
            cout << "Error #" << i << ": Invalid MOLE Error code [" 
                 << err.errCode << "] - "<< "occurred inside:" 
                 << err.errLocation;
            MOLEerr_print_args(err.paramError);
        }
        i++;
    }
}

// This function produces a file with all errors logged in a stack.
// The file name is a string form by the concatanetion of the MOLE
// class type associated with the erros (i.e., grid, operator, or 
// bcs) and a unique timestamp
void MOLEerr_dumpErrLog(stack<MOLE_Errors>& errorStack, 
    string logType){
    // create a string for the filename
    string filename = logType + getDateTimeString();
    std::ofstream outFile(filename);
    stack<MOLE_Errors> tempStack = errorStack;

    // Dump the logged errors to an output file
    if (tempStack.empty()) {
        outFile << "No errors logged." << endl;
        return;
    } 
    else {
        int i = 1;
        outFile << "========================================"<< endl;
        outFile << "Backtracing all logged MOLE Errors :" << endl;
        outFile << "========================================"<< endl;
        while (!tempStack.empty()) {
            MOLE_Errors err = tempStack.top();
            tempStack.pop();
            // if the grid has not been validated
            if (err.errCode == MOLE_ERR_GRID_UNCHECKED) {
                writeErrtoFile(outFile, i, MOLE_ERR_GRID_UNCHECKED,
                                err.errLocation, err.paramError,  
                                MOLE_errors_messages[err.errCode]);
                i++;
                continue;
            }
             // For all other MOLE errors recorded, check for valid
             // error code, in case the error log has been corrupted
            auto errMsg = MOLE_errors_messages.find(err.errCode);
            if (errMsg != MOLE_errors_messages.end()) { 
                writeErrtoFile(outFile, i, err.errCode, 
                    err.errLocation, err.paramError, errMsg->second);
            } 
            else {
                writeErrtoFile(outFile, i, 999, err.errLocation,
                   to_string(err.errCode), "Unknown MOLE error code ");
            }
            i++;
        }
    }
    outFile.close(); 
}