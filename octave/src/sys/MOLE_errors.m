classdef MOLE_errors < handle
% PURPOSE
% Canonical implementation for MOLE_errors class
% it implements mole error logging for both errors that stop execution .
% and errors that dont stop execution
% DESCRIPTION
% This error class implements error logging prints error messages and raises 
% fatal errors that stop exuction and errors that stop execution defined by the user
% input flag. 
% Errors are implemented using a json file structure. Upon calling error_catalog(key)
% function. The error structure is loaded into memory and remembered after for every
% execution of the function. Thereby keeping the object loaded even after creating
% new objects and calls to other functions.
%
% SYNTAX
% errorObj = MOLE_errors()
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    properties (Access = private)
        numErrors = 0
    end
    methods
        function obj = MOLE_errors()

        end

        function tf = haveErrors(obj)
            % PURPOSE
            % Check whether this object has recorded any MOLE errors.
            %
            % SYNTAX
            % tf = obj.haveErrors()
            %
            % DESCRIPTION
            %   obj : MOLE_errors object.
            %    tf : Logical scalar. Returns true when the recorded error count
            %         is greater than zero, and false otherwise.
            %
            % Recorded errors include both errors printed without aborting and
            % errors raised as exceptions by log_error.
            tf = ~(obj.numErrors == 0);
        end
        function num = getNumErrors(obj)
            % PURPOSE
            % Return the number of MOLE errors recorded by this object.
            %
            % SYNTAX
            % num = obj.getNumErrors()
            %
            % DESCRIPTION
            %   obj : MOLE_errors object.
            %   num : Numeric scalar containing the cumulative recorded error count.
            %         A newly constructed object has a count of zero.
            %
            % Each successfully logged error increases the count once, including
            % errors raised as exceptions. Calls rejected before logging do not
            % increase the count.
            num = obj.numErrors;
        end

        function log_error(obj, errorName, location, onErrorAbort, params)
            % PURPOSE
            % Report a MOLE error, increment the error count, and optionally
            % raise an exception.
            %
            % SYNTAX
            % obj.log_error(errorName, location)
            % obj.log_error(errorName, location, onErrorAbort)
            % obj.log_error(errorName, location, onErrorAbort, params)
            %
            % DESCRIPTION
            %            obj : MOLE_errors object receiving the recorded error.
            %      errorName : Character array identifying an error in errors.json.
            %       location : Character array describing where the error occurred.
            %   onErrorAbort : Optional logical scalar. true raises an exception;
            %                  false prints the error report. Defaults to false.
            %         params : Optional character array describing the input values
            %                  or circumstances associated with the error.
            %                  Defaults to an empty character array.
            %
            % Retrieves the error code and message from the error catalog and
            % formats them with the supplied name, location, and parameter text.
            % The object's error count is incremented once before reporting.
            %
            % When onErrorAbort is false, prints the formatted report and returns.
            % When true, raises an exception with identifier ['MOLE:' errorName].
            % The recorded count remains incremented if the caller catches it.
            %
            % An unknown catalog key raises MOLE:UNKNOWN_ERROR_NAME without
            % incrementing the count. For a recognized key, invalid location,
            % params, or onErrorAbort inputs print a diagnostic and return without
            % incrementing the count.
            %
            % This method returns no output.
            if nargin < 4
                onErrorAbort = false;
            end
            if nargin < 5
                params = '';
            end

            errorInfo = error_catalog(errorName);

            if ~ischar(location) || ~ischar(params)
                %Check if params an location sare strings
                disp('MOLE error location and params must be character arrays');
                return;
            end
            if ~islogical(onErrorAbort) || ~isscalar(onErrorAbort)
              disp('onErrorAbort must be true or false');
              return;
            end
            %Get error information from mapping and create error structure
            errCode = errorInfo.Code;
            errorStruct = struct('errorName', errorName, 'errorCode', ...
                            errCode, 'errorLocation', location, 'paramError', params, ...
                            'message', errorInfo.Message);
            errorMessage = createErrorMessage(errorStruct);
            obj.numErrors = obj.numErrors + 1;
            %Breaking error logic or proceed to print error only
            if onErrorAbort
                error(['MOLE:' errorName], '%s', errorMessage);
            else
                obj.MOLEerr_print(errorMessage);
            end
        end

        function MOLEerr_print(obj, errorMessage)
            %This function takes in an error struct as specified above
            % It also takes in an error messages to print corresponding
            % to the error code
            startLogStr = sprintf([ ...
                '========================================\nMOLE Error\n' ...
                '========================================\n']);
            fprintf('%s', startLogStr);
            fprintf('%s', errorMessage);
        end
    end
end

function outputStr = createErrorMessage(errorStruct)
    %This function creates a messge string with the error struct attributes
    outputStr = sprintf('Error: %s\nCode: %d\nParams: %s\nLocations: %s\nMessage: %s\n', ...
        errorStruct.errorName, errorStruct.errorCode, ...
        errorStruct.paramError, errorStruct.errorLocation, ...
        errorStruct.message);
end

function entry = error_catalog(key)
    %This function loads our error if our error sturcture is empty
    %ERRORS is persistenc across function so it is only loaded once
    %Check if error exists
    persistent ERRORS;
    if (isempty (ERRORS))
        filename = fullfile(fileparts (mfilename ('fullpath')), 'errors.json');
        ERRORS = jsondecode (fileread (filename));
    end
    if ~ischar(key)
        error('MOLE:UNKNOWN_ERROR_NAME', ...
              'MOLE error name must be a character array.');
    end
    if (~isfield(ERRORS, key))
    %Check if error name exists in mapping
        error('MOLE:UNKNOWN_ERROR_NAME', 'Unknown MOLE error name: %s', ...
        key);
    end
    entry = ERRORS.(key);
end
