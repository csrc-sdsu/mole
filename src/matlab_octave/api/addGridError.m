function grid = addGridError(grid, code, id, field, message)
% ADDGRIDERROR Attach a standardized error structure to a grid-like object.
%   If input is not a struct, create a struct so callers can safely return
%   grid.error instead of throwing.

    if nargin < 5, message = ''; end
    if nargin < 4, field = ''; end
    if nargin < 3, id = 'grid:Error'; end
    if nargin < 2, code = 100; end

    if ~isstruct(grid)
        grid = struct();
    end

    if ~isfield(grid, 'error') || ~isstruct(grid.error)
        grid.error = struct('hasError', false, ...
                            'code', 0, ...
                            'id', '', ...
                            'field', '', ...
                            'message', '');
    end

    grid.error.hasError = true;
    grid.error.code = code;
    grid.error.id = char(id);
    grid.error.field = char(field);
    grid.error.message = char(message);
end
