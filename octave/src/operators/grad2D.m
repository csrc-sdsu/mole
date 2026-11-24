function G = grad2D(k, grid, errorObj)
% PURPOSE
% Construct a two-dimensional mimetic gradient on a uniform Cartesian grid.
%
% SYNTAX
% G = grad2D(k, grid)
% G = grad2D(k, grid, errorObj)
%
% DESCRIPTION
%        k : Order of accuracy: 2, 4, 6, or 8.
%     grid : Validated two-dimensional MOLE grid with m, n, dx, dy, and
%            logical grid.bc.isPeriodic flags for the x and y axes.
% errorObj : Optional MOLE_errors object receiving construction errors.
%
% Each axis requires at least 2*k cells. The operator acts on U(:), with
% x varying along the first array dimension. Periodic axes use only their
% interior center values; nonperiodic axes include both boundary values.
% G returns the x-face derivatives followed by the y-face derivatives.
% Periodic face values contain one value at each unique periodic face.
%
% The one-dimensional operators are constructed through grad using small
% axis grids. Coordinate arrays are not copied or regenerated.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    if nargin < 3
        errorObj = MOLE_errors();
    end
    if nargin < 2
        errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'grad2D', true, ...
                           'grad2D expects k, grid, and an optional error object.');
    end
    if ~grid.valid
        errorObj.log_error('MOLE_ERR_OP_GRID_HAS_ERRORS', 'grad2D', true);
    end
    if ~isscalar(grid.dim) || grid.dim ~= 2
        errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'grad2D', true, ...
                           'grad2D requires a 2-dimensional grid.');
    end
    if ~strcmpi(grid.topology, 'uniform')
        errorObj.log_error('MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY', 'grad2D', true);
    end
    if numel(grid.bc.isPeriodic) ~= 2
    errorObj.log_error('MOLE_ERR_INVALID_ISPERIODIC_DIM', 'grad2D', true, ...
                      'Two periodic flags are required, one for each axis.');
    end
    %Build a 1D grid for both the x and y dimension to apply gradient operator
    xGrid = struct('dim', 1, 'valid', grid.valid, ...
                   'topology', grid.topology, 'm', grid.m, 'dx', grid.dx, ...
                   'bc', struct('isPeriodic', grid.bc.isPeriodic(1)));
    yGrid = xGrid;
    yGrid.m = grid.n;
    yGrid.dx = grid.dy;
    yGrid.bc.isPeriodic = grid.bc.isPeriodic(2);

    Gx = grad(k, xGrid, errorObj);
    Gy = grad(k, yGrid, errorObj);

    if grid.bc.isPeriodic(1)
        Im = speye(grid.m);
    else
        Im = sparse(1:grid.m, 2:grid.m+1, ones(1, grid.m), grid.m, grid.m+2);
    end
    if grid.bc.isPeriodic(2)
        In = speye(grid.n);
    else
        In = sparse(1:grid.n, 2:grid.n+1, ones(1, grid.n), grid.n, grid.n+2);
    end

    G = [kron(In, Gx); kron(Gy, Im)];
end
