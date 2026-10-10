classdef MOLE.errors < handle
    properties (Constant = true)
        % MOLE error codes supported by the Octave interface.
        % The source table's C++-only debugging entries (codes 000-010) are omitted.
        % Octave does not accept 'struct' as a containers.Map ValueType.  'any' is
        % required here because each map value is a scalar struct.
        MOLE_errors = containers.Map('KeyType', 'char', 'ValueType', 'any');

        % Codes 011-099: input user parameter errors.
        MOLE_errors('MOLE_ERR_GRID_UNCHECKED') = struct("Code", 11, "Message", "Grid has not been validated or checked for operations. All grids are initialized with this error until they are validated.");
        MOLE_errors('MOLE_ERR_GRID_FLAGGED_W_ERRS') = struct("Code", 12, "Message", "Grid failed to be validated and it has been flagged with ERRORS");
        MOLE_errors('MOLE_ERR_INVALID_GRID_ARGS') = struct("Code", 13, "Message", "Error(s) in input parameters, resulting grid is invalid.");
        MOLE_errors('MOLE_ERR_GRID_CONSTRUCTION_FAILED') = struct("Code", 14, "Message", "Grid construction failed, see full list of errors");
        MOLE_errors('MAKE_GRID_INVALID_INPUT_ARGS') = struct("Code", 15, "Message", "Invalid number of arguments passed during grid creation, valid inputs are pairs of the form <grid_attribute, value>");
        MOLE_errors('MAKE_GRID_MISSING_ARGS') = struct("Code", 16, "Message", "The number of arguments doesn't match the args actually passed.");
        MOLE_errors('MAKE_GRID_UNKNOWN_ATTRIBUTE') = struct("Code", 17, "Message", "Unknown grid structure attribute name.");
        MOLE_errors('MAKE_GRID_DUPLICATE_ATTRIBUTES') = struct("Code", 18, "Message", "Duplicate grid attribute passed");

        % Codes 100-199: grid and vector errors.
        MOLE_errors('MOLE_ERR_INVALID_GRID_DIM') = struct("Code", 100, "Message", "Invalid grid dimension");
        MOLE_errors('MOLE_ERR_INVALID_GRID_TOPOLOGY') = struct("Code", 101, "Message", "Invalid grid topology");
        MOLE_errors('MOLE_ERR_INVALID_GRID_SPACING') = struct("Code", 102, "Message", "Invalid grid spacing");
        MOLE_errors('MOLE_ERR_INVALID_GRID_SIZE') = struct("Code", 103, "Message", "Invalid grid size");
        MOLE_errors('MOLE_ERR_GRID_NODAL_SZ_MISMATCH') = struct("Code", 104, "Message", "Mismatch in the size of the nodal grid array(s)");
        MOLE_errors('MOLE_ERR_GRID_CENTERS_SZ_MISMATCH') = struct("Code", 105, "Message", "Mismatch in the size of the grid centers array(s)");
        MOLE_errors('MOLE_ERR_GRID_FACES_SZ_MISMATCH') = struct("Code", 106, "Message", "Mismatch in the size of the grid faces array(s)");
        MOLE_errors('MOLE_ERR_INVALID_INPUT_TYPE') = struct("Code", 107, "Message", "Invalid input type for input name");
        MOLE_errors('MOLE_ERR_ARRAY_HAS_NULL_POINTER') = struct("Code", 108, "Message", "Array has a null pointer either allocation failed or user passed a null pointer");
        MOLE_errors('MOLE_ERR_INVALID_CELL_COUNT') = struct("Code", 109, "Message", "Non-positive cell count (m/n/o <= 0)");
        MOLE_errors('MOLE_ERR_INVALID_ISPERIODIC_DIM') = struct("Code", 110, "Message", "Invalid dimension for the isPeriodic member");
        MOLE_errors('MOLE_ERR_ISPERIODIC_TYPE') = struct("Code", 111, "Message", "isPeriodic is not boolean");
        MOLE_errors('MOLE_ERR_INVALID_CURVILINEAR_GRID') = struct("Code", 112, "Message", "Curvilinear grids need user-provided nodal grid coordinates");
        MOLE_errors('MOLE_ERR_INVALID_1D_CURVILINEAR') = struct("Code", 113, "Message", "Curvilinear grids cannot be one dimensional");
        MOLE_errors('MOLE_ERR_INVALID_NONUNIFORM_GRID') = struct("Code", 114, "Message", "Nonuniform grids need user-provided nodal grid coordinates");
        MOLE_errors('MOLE_ERR_INVALID_ARRAY_INDEX') = struct("Code", 115, "Message", "One or more indices to the array are not valid, check arrays sizes");
        MOLE_errors('MOLE_ERR_INVALID_NODAL_COORDINATES') = struct("Code", 116, "Message", "User-provided nodal coordinates do not agree with other uniform grid parameters");
        MOLE_errors('MOLE_ERR_INVALID_CENTER_COORDINATES') = struct("Code", 117, "Message", "User-provided cell center coordinates do not agree with other uniform grid parameters");
        MOLE_errors('MOLE_ERR_INVALID_NORMAL_FACE_COORDS') = struct("Code", 118, "Message", "User-provided normal face coordinates do not agree with other uniform grid parameters");

        % Codes 200-299: MOLE array errors.
        MOLE_errors('MOLE_ERR_INVALID_ARRAY_SIZE') = struct("Code", 200, "Message", "Array dimensions need to be natural numbers >= 1");
        MOLE_errors('MOLE_ERR_ARRAY_SIZE_OVERFLOW') = struct("Code", 201, "Message", "Array allocation overflow");
        MOLE_errors('MOLE_ERR_ARRAY_INDEX_OUTBOUNDS') = struct("Code", 202, "Message", "The array index is out of bound.");
        MOLE_errors('MOLE_ERR_FAILED_ARRAY_ALLOC') = struct("Code", 203, "Message", "Fail to allocate array <array name>");
        MOLE_errors('MOLE_ERR_FAILED_ARRAY_RESIZE') = struct("Code", 204, "Message", "Fail to resize array <array name>");

        % Codes 300-600: MOLE operator errors.
        MOLE_errors('MOLE_ERR_DIVISION_BY_ZERO') = struct("Code", 300, "Message", "Division by zero");
        MOLE_errors('MOLE_ERR_INF_VALUE') = struct("Code", 301, "Message", "Infinite value detected");
        MOLE_errors('MOLE_ERR_NAN_VALUE') = struct("Code", 302, "Message", "NaN value detected");

        % Codes 119, 303, and 304 are omitted because the source table does not
        % provide complete code-symbol/message entries for those rows.
    end

    properties (Access = private)
        errorStack = {} % Try implementation if it doents work combine stack with error struct
    endproperties 

    methods (Access = private)
        function push(obj, moleError)
            #This funciton pushes a value onto the stack and checks its a struct object 
            if ~isstruct(val)
                error('Stack:type', 'Stack values should be structs')
            endif
            obj.errorStack{end+1} = moleError; 
        endfunction 
        function isError(obj,error)

        end
        function val = pop(obj)
            #This function pops the top element of the stack 
            if obj.isEmpty()
                error('Stack:empty', 'Cannot pop from an empty stack');
            endif
            #Get top element and set the last element as empty 
            val = obj.errorStack{end}; 
            obj.errorStack(end) = []; 
        endfunction 

        function moleError = top(obj) 
            #Peak at the top and return the top elements fo stack
            if obj.isEmpty()    #Check stack is not empty
                error('Stack:empty', 'Cannot peek an empty stack');
            endif
            moleError = obj.errorStack{end}; 
        endfunction 

        
        function tf = isEmpty(obj)
            #Check if stack is empty 
            tf = isempty(obj.errorStack); 
        endfunction 

        function n = size(obj)
            #Get the stack size 
            n = numel(obj.erroStack); 
        endfunction 

        function print(obj) 
        %There are some formatting erors here that need fixing
            fprintf('Stack with %d error(s):\n', obj.size()); 
            for i = numel(obj.Data):-1:1 e = obj.Data{i}; 
            fprintf(' [%d] Code=%d Location=%s
            Param=%s\n', ... i, e.errCode,
            e.errLocation, e.paramError); 
        endfunction
    endmethods
endclassde
classdef Mole_Errors < handle
    properties (Access)

    end
