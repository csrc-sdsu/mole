

function grid = makeGrid(varargin)
    % PURPOSE
    % Construct a grid from name/value pairs or a parameter structure and
    % pass it to validateGrid for partial validation and normalization.
    %
    % SYNTAX
    % grid = makeGrid(params)
    % grid = makeGrid(name1, value1, name2, value2, ...)
    %
    % DESCRIPTION
    %   params : Octave struct containing grid parameters.
    %    name_i : Grid field name supplied as a character array or string.
    %   value_i : Value assigned to the corresponding grid field.
    %     grid : Returned grid structure containing supplied parameters,
    %            inferred metadata, and coordinates when enough information
    %            is available.
    %
    % Common grid fields include dim, topology, cell counts m/n/o, uniform
    % spacings dx/dy/dz, and supplied nodal coordinates in nodes.X/Y/Z.
    % Coordinate arrays use ndgrid layout. Complete curvilinear geometry
    % requires nodes.X and nodes.Y, together with nodes.Z in three dimensions.
    %
    % Name/value pairs can be supplied in any order. Repeated field names overwrite
    % previously supplied values. After parsing all pairs, the grid values are validated.
    %
    % ----------------------------------------------------------------------------
    % SPDX-License-Identifier: GPL-3.0-or-later
    % © 2008-2024 San Diego State University Research Foundation (SDSURF).
    % See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
    % ----------------------------------------------------------------------------
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'sys'));
	errorObj = MOLE_errors();
    if nargin == 1 && isstruct(varargin{1})
        grid = varargin{1};
    else
        validateNumArgs(nargin, errorObj)
        grid = struct();
        for i = 1:2:nargin
            name = varargin{i};
            value = varargin{i + 1};
            if (ischar(name) || isstring(name))
            	grid.(char(name)) = value;
            else
            	params = sprintf('Name: %s , Value: %s ', name, value)
            	errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'makeGrid', true, params)
            endif
        end
    end

    grid = validateGrid(grid, true, errorObj);
end

function validateNumArgs(nargin, errorObj)
	#This function vaildates that the number of arguments are pairs if not it logs
    #stops execution
	if mod(nargin, 2) ~= 0
    	params = sprintf('number of arguments: %d', nargin);
    	errorObj.log_error('MAKE_GRID_INVALID_INPUT_ARGS', 'makeGrid', true, params);
    else
		  return;
    endif

endfunction

