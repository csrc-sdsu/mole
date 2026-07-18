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
 // clearing any existing errors
 void MOLEerr_init(stack<MOLE_Errors>& errorStack){
    errorStack = stack<MOLE_Errors>(); // Clear the stack
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
// code exists in the error stack. It returns true if the error code 
// is found, otherwise false.
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
          "occurred inside:" << errLocation;
          MOLEerr_print_args(errParams);
}

// Produces a timestamp string to create a unique filename to output
// log_errors messages and backtracing information
std::string getDateTimeString() {
#include <ctime>
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
#include <fstream>
void writeErrtoFile(std::ofstream& ofile, int errNum, int errCode,
                  string errLocation, string errParams, 
                  const std::string& errMsg) {
    ofile << "Error #" << errNum << ": MOLE Error code [" << 
          errCode << "] - "<< errMsg << endl;
          "occurred inside:" << errLocation;
          MOLEerr_write_args(ofile, errParams);
}

// This function prints out to std output any errors logged in a
// stack, preserving the error stack for further enabled debugging.
void MOLEerr_print(const stack<MOLE_Errors>& errorStack){
    // Create a copy to preserve the original stack
    stack<MOLE_ErrStack> tempStack = errorStack;
    if (tempStack.empty()) {
        cout << "No errors logged." << endl;
        return;
    }
    cout << "========================================"<< endl;
    cout << "Backtracing all logged MOLE Errors :" << endl;
    cout << "========================================"<< endl;
    
    int i = 0;
    while (!tempStack.empty()) {
        MOLE_ErrStack err = tempStack.top();
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
            cout << "Error #[" << err.errCode << "]: " 
                    << "is Unknown MOLE error code "
                    << "occurred inside: " 
                    << err.errLocation << "\n"; 
            cout << "Error #" << i << ": Invalid MOLE Error code [" 
                 << errCode << "] - "<< "occurred inside:" 
                 << errLocation;
            MOLEerr_print_args(errParams);
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

    // Dump the logged errors to an output file
    if (tempStack.empty()) {
        writeErrFile(outFile, 0, "No errors logged.");
        return;
    } 
    else {
        int i == 1;
        outFile << "========================================"<< endl;
        outFile << "Backtracing all logged MOLE Errors :" << endl;
        outFile << "========================================"<< endl;
        while (!tempStack.empty()) {
            MOLE_ErrStack err = tempStack.top();
            tempStack.pop();
            if (err.errCode == MOLE_ERR_GRID_UNCHECKED) {
                writeErrtoFile(outFile, i, MOLE_ERR_GRID_UNCHECKED,
                    err.Location, MOLE_errors_messages[err.errCode]);
                i++;
                continue;
            }
            auto errMsg = MOLE_errors_messages.find(err.errCode);
            if (errMsg != MOLE_errors_messages.end()) { 
                writeErrtoFile(outFile, i, err.errCode, err.Location,
                    errMsg->second, err.paramError);
            } 
            else {
                writeErrFile(outFile, i, 999, err.Location,
                   "Unknown MOLE error code ", to_string(err.errCode));
            }
            i++;
        }
    }
    outFile.close(); 
}