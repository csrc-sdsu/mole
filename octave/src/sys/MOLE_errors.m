classdef MOLE_errors < handle
    properties (Access = private)
        numErrors = 0
    endproperties
    methods
        function obj = MOLE_errors()

        endfunction

        function tf = haveErrors(obj)
            # Check if any errors occured
            tf = ~(obj.numErrors == 0);
        endfunction
        function num = getNumErrors(obj)
            num = obj.numErrors;
        endfunction

        function log_error(obj, errorName, location, onErrorAbort = false, params = "")
            # This function logs an error and decides wether it will stop and error and print
            # the error error name, error code, error location, and error
            # params which would stop execution. Otherwise it prints the error
            # onErrorAbort true means that its an error that stops execution
            # and false are errors that keep going with exection even
            # though and error occured
            errorInfo = error_catalog(errorName);

            if ~ischar(location) || ~ischar(params)
                #Check if params an location sare strings
                disp("MOLE error location and params must be character arrays");
                return;
            endif
            if ~islogical(onErrorAbort) || ~isscalar(onErrorAbort)
              disp("onErrorAbort must be true or false");
              return;
            endif
            #Get error information from mapping and create error structure
            errCode = errorInfo.Code;
            errorStruct = struct("errorName", errorName, "errorCode", ...
                            errCode, "errorLocation", location, "paramError", params, ...
                            "message", errorInfo.Message);
            errorMessage = createErrorMessage(errorStruct);
            obj.numErrors += 1;
            #Breaking error logic or proceed to print error only
            if onErrorAbort
                error(["MOLE:" errorName], "%s", errorMessage);
            else
                obj.MOLEerr_print(errorMessage);
            endif
        endfunction

        function MOLEerr_print(obj, errorMessage)
            #This function takes in an error struct as specified above
            # It also takes in an error messages to print corresponding
            # to the error code
            startLogStr = ...
            strcat("========================================\nLogged MOLE Error", ...
            "\n========================================\n");
            printf("%s", startLogStr);
            printf("%s", errorMessage);
        endfunction
    endmethods
endclassdef

function outputStr = createErrorMessage(errorStruct)
    #This function creates a messge string with the error struct attributes
    outputStr = sprintf("Error: %s\nCode: %d\nParams: %s\nLocations: %s\nMessage: %s\n", ...
        errorStruct.errorName, errorStruct.errorCode, ...
        errorStruct.paramError, errorStruct.errorLocation, ...
        errorStruct.message);
endfunction

function entry = error_catalog(key)
    #This function loads our error if our error sturcture is empty
    #ERRORS is persistenc across function so it is only loaded once
    #Check if error exists
    persistent ERRORS;
    if (isempty (ERRORS))
        filename = fullfile(fileparts (mfilename ("fullpath")), "errors.json");
        ERRORS = jsondecode (fileread (filename));
    endif
    if (!isfield(ERRORS, key))
    #Check if error name exists in mapping
        error("MOLE:UNKNOWN_ERROR_NAME", "Unknown MOLE error name: %s", ...
        key);
    endif
    entry = ERRORS.(key);
endfunction
