 function outputStr = constErrorMessage(errorStruct)
    #This function creates a messge string with the error struct attributes
    outputStr = sprintf("Error: %s\nCode: %d\nParams: %s\nLocations: %s\nMessage: %s\n", errorStruct.errorName, errorStruct.errorCode, errorStruct.paramError, errorStruct.errorLocation, errorStruct.message);
endfunction

classdef MOLE_errors < handle
    properties (Access = private)
        errorMap
        numErrors = 0
    endproperties


    methods
        function obj = MOLE_errors()
            obj.errorMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.errorMap('MOLE_ERR_GRID_UNCHECKED') = struct("Code", 11, "Message", "Grid has not been validated or checked for operations. All grids are initialized with this error until they are validated.");
            obj.errorMap('MOLE_ERR_GRID_FLAGGED_W_ERRS') = struct("Code", 12, "Message", "Grid failed to be validated and it has been flagged with ERRORS");
            obj.errorMap('MOLE_ERR_INVALID_GRID_ARGS') = struct("Code", 13, "Message", "Error(s) in input parameters, resulting grid is invalid.");
            obj.errorMap('MOLE_ERR_GRID_CONSTRUCTION_FAILED') = struct("Code", 14, "Message", "Grid construction failed, see full list of errors");
            obj.errorMap('MAKE_GRID_INVALID_INPUT_ARGS') = struct("Code", 15, "Message", "Invalid number of arguments passed during grid creation, valid inputs are pairs of the form <grid_attribute, value>");
            obj.errorMap('MAKE_GRID_MISSING_ARGS') = struct("Code", 16, "Message", "The number of arguments doesn't match the args actually passed.");
            obj.errorMap('MAKE_GRID_UNKNOWN_ATTRIBUTE') = struct("Code", 17, "Message", "Unknown grid structure attribute name.");
            obj.errorMap('MAKE_GRID_DUPLICATE_ATTRIBUTES') = struct("Code", 18, "Message", "Duplicate grid attribute passed");

            obj.errorMap('MOLE_ERR_INVALID_GRID_DIM') = struct("Code", 100, "Message", "Invalid grid dimension");
            obj.errorMap('MOLE_ERR_INVALID_GRID_TOPOLOGY') = struct("Code", 101, "Message", "Invalid grid topology");
            obj.errorMap('MOLE_ERR_INVALID_GRID_SPACING') = struct("Code", 102, "Message", "Invalid grid spacing");
            obj.errorMap('MOLE_ERR_INVALID_GRID_SIZE') = struct("Code", 103, "Message", "Invalid grid size");
            obj.errorMap('MOLE_ERR_GRID_NODAL_SZ_MISMATCH') = struct("Code", 104, "Message", "Mismatch in the size of the nodal grid array(s)");
            obj.errorMap('MOLE_ERR_GRID_CENTERS_SZ_MISMATCH') = struct("Code", 105, "Message", "Mismatch in the size of the grid centers array(s)");
            obj.errorMap('MOLE_ERR_GRID_FACES_SZ_MISMATCH') = struct("Code", 106, "Message", "Mismatch in the size of the grid faces array(s)");
            obj.errorMap('MOLE_ERR_INVALID_INPUT_TYPE') = struct("Code", 107, "Message", "Invalid input type for input name");
            obj.errorMap('MOLE_ERR_ARRAY_HAS_NULL_POINTER') = struct("Code", 108, "Message", "Array has a null pointer either allocation failed or user passed a null pointer");
            obj.errorMap('MOLE_ERR_INVALID_CELL_COUNT') = struct("Code", 109, "Message", "Non-positive cell count (m/n/o <= 0)");
            obj.errorMap('MOLE_ERR_INVALID_ISPERIODIC_DIM') = struct("Code", 110, "Message", "Invalid dimension for the isPeriodic member");
            obj.errorMap('MOLE_ERR_ISPERIODIC_TYPE') = struct("Code", 111, "Message", "isPeriodic is not boolean");
            obj.errorMap('MOLE_ERR_INVALID_CURVILINEAR_GRID') = struct("Code", 112, "Message", "Curvilinear grids need user-provided nodal grid coordinates");
            obj.errorMap('MOLE_ERR_INVALID_1D_CURVILINEAR') = struct("Code", 113, "Message", "Curvilinear grids cannot be one dimensional");
            obj.errorMap('MOLE_ERR_INVALID_NONUNIFORM_GRID') = struct("Code", 114, "Message", "Nonuniform grids need user-provided nodal grid coordinates");
            obj.errorMap('MOLE_ERR_INVALID_ARRAY_INDEX') = struct("Code", 115, "Message", "One or more indices to the array are not valid, check arrays sizes");
            obj.errorMap('MOLE_ERR_INVALID_NODAL_COORDINATES') = struct("Code", 116, "Message", "User-provided nodal coordinates do not agree with other uniform grid parameters");
            obj.errorMap('MOLE_ERR_INVALID_CENTER_COORDINATES') = struct("Code", 117, "Message", "User-provided cell center coordinates do not agree with other uniform grid parameters");
            obj.errorMap('MOLE_ERR_INVALID_NORMAL_FACE_COORDS') = struct("Code", 118, "Message", "User-provided normal face coordinates do not agree with other uniform grid parameters");

            obj.errorMap('MOLE_ERR_INVALID_ARRAY_SIZE') = struct("Code", 200, "Message", "Array dimensions need to be natural numbers >= 1");
            obj.errorMap('MOLE_ERR_ARRAY_SIZE_OVERFLOW') = struct("Code", 201, "Message", "Array allocation overflow");
            obj.errorMap('MOLE_ERR_ARRAY_INDEX_OUTBOUNDS') = struct("Code", 202, "Message", "The array index is out of bound.");
            obj.errorMap('MOLE_ERR_FAILED_ARRAY_ALLOC') = struct("Code", 203, "Message", "Fail to allocate array <array name>");
            obj.errorMap('MOLE_ERR_FAILED_ARRAY_RESIZE') = struct("Code", 204, "Message", "Fail to resize array <array name>");

            obj.errorMap('MOLE_ERR_DIVISION_BY_ZERO') = struct("Code", 300, "Message", "Division by zero");
            obj.errorMap('MOLE_ERR_INF_VALUE') = struct("Code", 301, "Message", "Infinite value detected");
            obj.errorMap('MOLE_ERR_NAN_VALUE') = struct("Code", 302, "Message", "NaN value detected");
        endfunction

        function tf = haveErrors(obj)
            #Check if there are any errors
            tf = obj.numErrors == 0;
        endfunction

        function log_error(obj, errorName, location, onErrorAbort = false, params = "")
            # This function logs an error and decides wether it will stop and error and print
            # the error error name, error code, error location, and error params which would stop execution. Otherwise it prints the error
            # onErrorAbort true means that its an error that stops execution and false are errors that keep going with exection even though and error occured
            if ~isKey(obj.errorMap, errorName)
                #Check if error name exists in mapping
                error("Unknown MOLE error name: %s", errorName);
            endif

            if ~ischar(location) || ~ischar(params)
                #Check if params an location sare strings
                disp("MOLE error location and params must be character arrays")
                return;
            endif

            if (~(onErrorAbort == true) && ~(onErrorAbort == false) )
                #Check if onErrorAbort is a boolean
                disp("onErrorAbort must be true or false");
                return;
            endif
            #Get error information from mapping and create error structure
            errorInfo = obj.errorMap(errorName);
            errCode = errorInfo.Code;
            errorStruct = struct("errorName", errorName, "errorCode", errCode, "errorLocation", location, "paramError", params, "message", errorInfo.Message);
            errorMessage = obj.constErrorMessage(errorStruct);
            obj.numErrors += 1;
            #Breaking error logic or proceed to print error only
            if onErrorAbort
                error("%s", errorMessage);
            else
                obj.MOLEerr_print(errorMessage);
            endif
        endfunction

        function MOLEerr_print(obj, errorMessage)
            #This function takes in an error struct as specified above
            # It also takes in an error messages to print corresponding to the error code
            startLogStr = "========================================\nLogged MOLE Error\n========================================\n";
            printf("%s", startLogStr);
            printf("%s", errorMessage);
        endfunction
    endmethods
endclassdef
