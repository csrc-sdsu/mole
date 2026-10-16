addpath(“../sys”)

function grid = makeGrid_impl(varargin)
% Canonical implementation for makeGrid.

    if nargin == 1 && isstruct(varargin{1})
        grid = varargin{1};
    else
        validateNumArgs(nargin)

        grid = struct();
        for i = 1:2:nargin
            name = varargin{i};
            value = varargin{i + 1};
            assert(ischar(name) || isstring(name), ...
                   'Grid field names must be character vectors or strings');
            grid.(char(name)) = value;
        end
    end

    grid = validateGrid(grid, true);
end

function validateNumArgs(nargin, errorObj)
	#This function vaildates that the number of arguments are pairs if not it logs
    #stops execution
	if mod(nargin, 2) == 0
    	params = "number of argumebts: " + int2str(nargin);
        messge = 'makeGrid expects a struct or name-value pairs'
    	errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'makeGrid_impl', 0, params, message );
    else
		return;
    endif

endfunction 

function validateArgTypes