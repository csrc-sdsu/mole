addpath(“../sys”)

function grid = makeGrid_impl(varargin)
% Canonical implementation for makeGrid.
	errorObj = MOLE_errors()
    if nargin == 1 && isstruct(varargin{1})
        grid = varargin{1};
    else
        validateNumArgs(nargin)
        grid = struct();
        for i = 1:2:nargin
            name = varargin{i};
            value = varargin{i + 1};
            if (ischar(name) || isstring(name))
            	grid.(char(name)) = value;
            else
            	params = sprintf('Name: %s , Value: %s ', name, value)
            	errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'makeGrid_impl', true, params, message)
            endif
        end
    end

    grid = validateGrid(grid, true);
end

function validateNumArgs(nargin, errorObj)
	#This function vaildates that the number of arguments are pairs if not it logs
    #stops execution
	if mod(nargin, 2) == 0
    	params = "number of argumebts: " + int2str(nargin);
    	errorObj.log_error( 'MAKE_GRID_INVALID_INPUT_ARGS' , 'makeGrid_impl', true, params);
    else
		return;
    endif

endfunction 

