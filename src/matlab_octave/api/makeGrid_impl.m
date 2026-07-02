function grid = makeGrid_impl(varargin)
% Canonical implementation for makeGrid.

    if nargin == 1 && isstruct(varargin{1})
        grid = varargin{1};
    else
        if mod(nargin, 2) ~= 0
            grid = struct();
            grid = addGridError(grid, 100, 'makeGrid:InvalidInput', '', 'makeGrid expects a struct or name-value pairs');
            return;
        end

        grid = struct();
        for i = 1:2:nargin
            name = varargin{i};
            value = varargin{i + 1};
            if ~(ischar(name) || isstring(name))
                grid = addGridError(grid, 100, 'makeGrid:InvalidFieldName', '', 'Grid field names must be character vectors or strings');
                return;
            end
            grid.(char(name)) = value;
        end
    end

    grid = validateGrid(grid, true);
end