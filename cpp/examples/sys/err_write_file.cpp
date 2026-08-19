/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research 
 * Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html 
 * for details.
 */

/*
 * @file err_write_file.cpp
 *
 * @brief In this example we generate and exception and 
 *        catch it using the MOLE error handling mechanism
 *
 * @date 2026/08/12
 *
 */

#include <cmath>
#include <iostream>
#include "MOLE_arrays.h"

//
// A safe division operation that throws error exceptions
//
double safeDivide(double a, double b) {
    double result = a / b;
    if (std::isinf(result)) {
        throw std::runtime_error("Result = infinity (div by zero)");
    }
    if (std::isnan(result)) {
        throw std::runtime_error("Result = NaN (likely 0/0)");
    }
    return result;
}

int main() {
    cout << "==============================================" 
              << endl;
    cout << "This is a DEMO of MOLE's error log mechanism "  
              << endl;
    cout << "It generate 3 errors, logs them into an error"  
              << endl;
    cout << "stack, then outputs them to a text file."       
              << endl;   
    cout << "==============================================" 
              << endl;  

    stack<MOLE_Errors> errs;    // Must declare a error stack
    
    double  dx = 1.0;
    int     n_points = 0,
            x_size = 1;
    array1D x;

    // First we try to access the 10th element of an array that has
    // no elements (initial size = 0), we'll catch the error and log
    // into a MOLE stack
    try{
            x.data_(10) = 1.0;
    } catch (std::exception& e){
        string wparams = "array has size: ";
        wparams += to_string(x.data_.n_elem) + ", index = ";
        wparams += to_string(10) + " not valid";
        MOLEerr_log(errs, MOLE_ERR_ARRAY_INDEX_OUTBOUNDS,
                    "err_write_file", wparams);
    }

    // Second we attemp to create a second error by dividing by
    // zero
    int error_code = MOLE_ERR_INF_VALUE;
    try {
        dx = safeDivide(double(x_size), double(n_points));
    } catch (const std::runtime_error& e) {
        string wparams = "Numerator = ";

        wparams += to_string(x_size) + ", denominator = ";
        wparams += to_string(n_points);
        if (isnan(dx)){
            wparams += ", and result is a NaN";
            error_code = MOLE_ERR_NAN_VALUE;
        } else
            wparams += ", and result is infinity"; 

        MOLEerr_log(errs, error_code, "err_write_file", wparams);
    }

    // Third error is a Nan
    if (x_size != dx*n_points){
        string wparams = "dx != x_size [" + to_string(x_size);
        wparams += "] / n_points[" +to_string(n_points) + "]";
        MOLEerr_log(errs, MOLE_ERR_INVALID_NODAL_COORDINATES,
        "err_write_file", wparams);
    }

    // Creating a file containing the 3 error messages
    cout << "=======================================" << endl;  
    cout << "Filename = err_write_file + <timestamp>" << endl;
    cout << "=======================================" << endl;  
    MOLEerr_dumpErrLog(errs, "err_write_file");
    cout << "File created. Check your current directory." << endl;
    cout << "-----------------------------------------" << endl;

    return 0;
}
