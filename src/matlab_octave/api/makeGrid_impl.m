function grid = makeGrid_impl(varargin)
% Canonical implementation for makeGrid.

    if nargin == 1 && isstruct(varargin{1})
        grid = varargin{1};
    else
        assert(mod(nargin, 2) == 0, ...
               'makeGrid expects a struct or name-value pairs');

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