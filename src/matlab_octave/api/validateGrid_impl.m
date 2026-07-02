function grid = validateGrid_impl(grid, allowPartial)
% PURPOSE
% Canonical implementation for validateGrid — normalizes and enriches a
% grid struct with coordinate arrays for nodes, faces, and centers.
%
% DESCRIPTION
% Accepts a partial or complete grid struct, infers dim and type from
% present fields, normalizes grid.bc.{dc,nc,isPeriodic}, and populates
% grid.nodes, grid.faces, and grid.centers with meshgrid-style arrays.
% For curvilinear grids, grid.nodes.X/Y must be supplied by the caller;
% faces and centers are derived by interpolation.
% On validation failure, returns immediately with grid.error populated.
% Grid-related errors use codes 100-199.
%
% Parameters:
%   grid         : Input struct (partial or complete)
%   allowPartial : (optional) logical, default false — skip missing-field
%                  errors during incremental construction
%
% SYNTAX
% grid = validateGrid_impl(grid)
% grid = validateGrid_impl(grid, allowPartial)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin < 2
        allowPartial = false;
    end

    if ~isstruct(grid)
        grid = struct();
        grid = addGridError(grid, 100, 'validateGrid:InvalidInput', '', 'grid must be a struct');
        return;
    end

    if ~isfield(grid, 'error') || ~isstruct(grid.error)
        grid.error = struct('hasError', false, 'code', 0, 'id', '', 'field', '', 'message', '');
    end

    if ~isfield(grid, 'bc') || ~isstruct(grid.bc)
        grid.bc = struct();
    end

    if isfield(grid, 'dc') && ~isfield(grid.bc, 'dc')
        grid.bc.dc = grid.dc;
    end
    if isfield(grid, 'nc') && ~isfield(grid.bc, 'nc')
        grid.bc.nc = grid.nc;
    end

    if ~isfield(grid, 'dim')
        if isfield(grid, 'o') || isfield(grid, 'dz') || isfield(grid, 'Z')
            grid.dim = 3;
        elseif isfield(grid, 'n') || isfield(grid, 'dy') || isfield(grid, 'Y')
            grid.dim = 2;
        else
            grid.dim = 1;
        end
    end

    if ~isfield(grid, 'type')
        if isfield(grid, 'X') || isfield(grid, 'Y') || isfield(grid, 'Z')
            grid.type = 'curvilinear';
        elseif isfield(grid, 'x') || isfield(grid, 'y') || isfield(grid, 'z')
            grid.type = 'nonuniform';
        else
            grid.type = 'uniform';
        end
    end

    switch grid.dim
    case 1
        grid = localRequire(grid, {'m'}, allowPartial, 'validateGrid:MissingField1D');
        if grid.error.hasError, return; end
        grid = localNormalizeIfUniform1D(grid, allowPartial);
        if grid.error.hasError, return; end
    case 2
        grid = localRequire(grid, {'m', 'n'}, allowPartial, 'validateGrid:MissingField2D');
        if grid.error.hasError, return; end
        grid = localNormalizeIfUniform2D(grid, allowPartial);
        if grid.error.hasError, return; end
    case 3
        grid = localRequire(grid, {'m', 'n', 'o'}, allowPartial, 'validateGrid:MissingField3D');
        if grid.error.hasError, return; end
        grid = localNormalizeIfUniform3D(grid, allowPartial);
        if grid.error.hasError, return; end
    otherwise
        grid = addGridError(grid, 102, 'validateGrid:InvalidDim', 'dim', 'grid.dim must be 1, 2, or 3');
        return;
    end
end

function grid = localRequire(grid, names, allowPartial, errId)
    for i = 1:numel(names)
        if ~isfield(grid, names{i}) && ~allowPartial
            grid = addGridError(grid, 101, errId, names{i}, ['Missing required field grid.' names{i}]);
            return;
        end
    end
end

function grid = localNormalizeIfUniform1D(grid, allowPartial)
    hasUniform = isfield(grid, 'm') && isfield(grid, 'dx');
    if hasUniform
        grid = localNormalizeGrid1D(grid);
    elseif ~allowPartial && strcmpi(grid.type, 'uniform')
        grid = addGridError(grid, 103, 'validateGrid:MissingUniform1D', '', 'Uniform 1-D grid requires grid.m and grid.dx');
        return;
    end
end

function grid = localNormalizeIfUniform2D(grid, allowPartial)
    % Curvilinear grids have their own normalisation path
    if strcmp(grid.type, 'curvilinear')
        if isfield(grid, 'm') && isfield(grid, 'n')
            grid = localNormalizeCurvilinear2D(grid);
        end
        return;
    end

    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy');
    if hasUniform
        grid = localNormalizeGrid2D(grid);
    elseif ~allowPartial && strcmpi(grid.type, 'uniform')
        grid = addGridError(grid, 103, 'validateGrid:MissingUniform2D', '', 'Uniform 2-D grid requires grid.m, grid.n, grid.dx, and grid.dy');
        return;
    end
end

function grid = localNormalizeIfUniform3D(grid, allowPartial)
    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && isfield(grid, 'o') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy') && isfield(grid, 'dz');
    if hasUniform
        grid = localNormalizeGrid3D(grid);
    elseif ~allowPartial && strcmpi(grid.type, 'uniform')
        grid = addGridError(grid, 103, 'validateGrid:MissingUniform3D', '', 'Uniform 3-D grid requires grid.m, grid.n, grid.o, grid.dx, grid.dy, and grid.dz');
        return;
    end
end

function grid = localNormalizeGrid1D(grid)
    if isfield(grid, 'dim')
        if grid.dim ~= 1
            grid = addGridError(grid, 102, 'validateGrid:InvalidDim1D', 'dim', 'grid.dim must be 1 for 1-D operators');
            return;
        end
    else
        grid.dim = 1;
    end

    if ~isfield(grid, 'm'), grid = addGridError(grid, 101, 'validateGrid:MissingM', 'm', 'grid.m is required'); return; end
    if ~isfield(grid, 'dx'), grid = addGridError(grid, 103, 'validateGrid:MissingDx', 'dx', 'grid.dx is required for uniform 1-D operators'); return; end

    grid.m = double(grid.m);
    grid.dx = double(grid.dx);

    if isfield(grid, 'bc') && isstruct(grid.bc)
        bc = grid.bc;
    else
        bc = struct();
    end

    if isfield(grid, 'dc') && ~isfield(bc, 'dc')
        bc.dc = grid.dc;
    end
    if isfield(grid, 'nc') && ~isfield(bc, 'nc')
        bc.nc = grid.nc;
    end

    [bc.dc, bc.nc, bc.hasData, errGrid] = localNormalizeBoundaryCoefficients(grid, bc, 2, 'validateGrid:InvalidBC1D');
    if errGrid.error.hasError
        grid = errGrid;
        return;
    end
    [bc.isPeriodic, grid] = localNormalizeIsPeriodic(grid, bc, bc.hasData, 1, 'validateGrid:InvalidBC1D');
    if grid.error.hasError, return; end

    grid.bc = bc;
    if grid.bc.isPeriodic
        grid.type = 'periodic';
    else
        grid.type = 'uniform';
    end

    grid = localGenerateCoordinates1D(grid);
end

function grid = localNormalizeGrid2D(grid)
    if isfield(grid, 'dim')
        if grid.dim ~= 2
            grid = addGridError(grid, 102, 'validateGrid:InvalidDim2D', 'dim', 'grid.dim must be 2 for 2-D operators');
            return;
        end
    else
        grid.dim = 2;
    end

    if ~isfield(grid, 'm'), grid = addGridError(grid, 101, 'validateGrid:MissingM', 'm', 'grid.m is required'); return; end
    if ~isfield(grid, 'n'), grid = addGridError(grid, 101, 'validateGrid:MissingN', 'n', 'grid.n is required'); return; end
    if ~isfield(grid, 'dx'), grid = addGridError(grid, 103, 'validateGrid:MissingDx', 'dx', 'grid.dx is required for uniform 2-D operators'); return; end
    if ~isfield(grid, 'dy'), grid = addGridError(grid, 103, 'validateGrid:MissingDy', 'dy', 'grid.dy is required for uniform 2-D operators'); return; end

    grid.m = double(grid.m);
    grid.n = double(grid.n);
    grid.dx = double(grid.dx);
    grid.dy = double(grid.dy);

    if isfield(grid, 'bc') && isstruct(grid.bc)
        bc = grid.bc;
    else
        bc = struct();
    end

    if isfield(grid, 'dc') && ~isfield(bc, 'dc')
        bc.dc = grid.dc;
    end
    if isfield(grid, 'nc') && ~isfield(bc, 'nc')
        bc.nc = grid.nc;
    end

    [bc.dc, bc.nc, bc.hasData, errGrid] = localNormalizeBoundaryCoefficients(grid, bc, 4, 'validateGrid:InvalidBC2D');
    if errGrid.error.hasError
        grid = errGrid;
        return;
    end
    [bc.isPeriodic, grid] = localNormalizeIsPeriodic(grid, bc, bc.hasData, 2, 'validateGrid:InvalidBC2D');
    if grid.error.hasError, return; end

    grid.bc = bc;
    if any(grid.bc.isPeriodic)
        grid.type = 'periodic';
    else
        grid.type = 'uniform';
    end

    grid = localGenerateCoordinates2D(grid);
end

function grid = localNormalizeGrid3D(grid)
    if isfield(grid, 'dim')
        if grid.dim ~= 3
            grid = addGridError(grid, 102, 'validateGrid:InvalidDim3D', 'dim', 'grid.dim must be 3 for 3-D operators');
            return;
        end
    else
        grid.dim = 3;
    end

    if ~isfield(grid, 'm'), grid = addGridError(grid, 101, 'validateGrid:MissingM', 'm', 'grid.m is required'); return; end
    if ~isfield(grid, 'n'), grid = addGridError(grid, 101, 'validateGrid:MissingN', 'n', 'grid.n is required'); return; end
    if ~isfield(grid, 'o'), grid = addGridError(grid, 101, 'validateGrid:MissingO', 'o', 'grid.o is required'); return; end
    if ~isfield(grid, 'dx'), grid = addGridError(grid, 103, 'validateGrid:MissingDx', 'dx', 'grid.dx is required for uniform 3-D operators'); return; end
    if ~isfield(grid, 'dy'), grid = addGridError(grid, 103, 'validateGrid:MissingDy', 'dy', 'grid.dy is required for uniform 3-D operators'); return; end
    if ~isfield(grid, 'dz'), grid = addGridError(grid, 103, 'validateGrid:MissingDz', 'dz', 'grid.dz is required for uniform 3-D operators'); return; end

    grid.m = double(grid.m);
    grid.n = double(grid.n);
    grid.o = double(grid.o);
    grid.dx = double(grid.dx);
    grid.dy = double(grid.dy);
    grid.dz = double(grid.dz);

    if isfield(grid, 'bc') && isstruct(grid.bc)
        bc = grid.bc;
    else
        bc = struct();
    end

    if isfield(grid, 'dc') && ~isfield(bc, 'dc')
        bc.dc = grid.dc;
    end
    if isfield(grid, 'nc') && ~isfield(bc, 'nc')
        bc.nc = grid.nc;
    end

    [bc.dc, bc.nc, bc.hasData, errGrid] = localNormalizeBoundaryCoefficients(grid, bc, 6, 'validateGrid:InvalidBC3D');
    if errGrid.error.hasError
        grid = errGrid;
        return;
    end
    [bc.isPeriodic, grid] = localNormalizeIsPeriodic(grid, bc, bc.hasData, 3, 'validateGrid:InvalidBC3D');
    if grid.error.hasError, return; end

    grid.bc = bc;
    if any(grid.bc.isPeriodic)
        grid.type = 'periodic';
    else
        grid.type = 'uniform';
    end

    grid = localGenerateCoordinates3D(grid);
end

function [dc, nc, hasData, grid] = localNormalizeBoundaryCoefficients(grid, bc, expectedCount, errId)
    hasDC = isfield(bc, 'dc');
    hasNC = isfield(bc, 'nc');

    if ~hasDC && ~hasNC
        dc = [];
        nc = [];
        hasData = false;
        return;
    end

    if hasDC ~= hasNC
        grid = addGridError(grid, 104, errId, 'bc', 'grid.bc.dc and grid.bc.nc must be provided together');
        dc=[]; nc=[]; hasData=false; return;
    end

    if isempty(bc.dc) && isempty(bc.nc)
        dc = [];
        nc = [];
        hasData = false;
        return;
    end

    if isempty(bc.dc) || isempty(bc.nc)
        grid = addGridError(grid, 104, errId, 'bc', 'grid.bc.dc and grid.bc.nc must both be empty or both be non-empty');
        dc=[]; nc=[]; hasData=false; return;
    end

    [dc, grid] = localNormalizeBoundaryVector(grid, bc.dc, expectedCount, 'grid.bc.dc', errId);
    if grid.error.hasError, nc=[]; hasData=false; return; end
    [nc, grid] = localNormalizeBoundaryVector(grid, bc.nc, expectedCount, 'grid.bc.nc', errId);
    if grid.error.hasError, dc=[]; hasData=false; return; end
    hasData = true;
end

function [values, grid] = localNormalizeBoundaryVector(grid, values, expectedCount, fieldName, errId)
    if ~isnumeric(values)
        grid = addGridError(grid, 105, errId, fieldName, [fieldName ' must be numeric']);
        values=[]; return;
    end
    if ~isvector(values)
        grid = addGridError(grid, 105, errId, fieldName, [fieldName ' must be a scalar or vector']);
        values=[]; return;
    end

    values = double(values(:));
    if numel(values) == 1
        values = repmat(values, expectedCount, 1);
    elseif numel(values) ~= expectedCount
        grid = addGridError(grid, 105, errId, fieldName, sprintf('%s must be a scalar or a %dx1 vector', fieldName, expectedCount));
        values=[]; return;
    end
end

function grid = localGenerateCoordinates1D(grid)
    m  = grid.m;
    dx = grid.dx;

    x_node   = (0:m)' * dx;                              % (m+1)×1
    x_center = [0; ((1:m) - 0.5)' * dx; m * dx];        % (m+2)×1
    x_face   = x_node;                                   % (m+1)×1

    grid.nodes.X   = x_node;
    grid.centers.X = x_center;
    grid.faces.X   = x_face;
end

function grid = localGenerateCoordinates2D(grid)
    m = grid.m; n = grid.n;
    dx = grid.dx; dy = grid.dy;

    xn = (0:m) * dx;                          % node x: m+1 values
    yn = (0:n) * dy;                           % node y: n+1 values
    xc = [0, (0.5:m-0.5) * dx, m*dx];         % center x: m+2 values
    yc = [0, (0.5:n-0.5) * dy, n*dy];         % center y: n+2 values
    xu = xn;                                   % u-face x: m+1 (same as nodes)
    yu = (0.5:n-0.5) * dy;                    % u-face y: n values
    xv = (0.5:m-0.5) * dx;                    % v-face x: m values
    yv = yn;                                   % v-face y: n+1 (same as nodes)

    [grid.nodes.X,   grid.nodes.Y]   = ndgrid(xn, yn);
    [grid.centers.X, grid.centers.Y] = ndgrid(xc, yc);
    [grid.faces.u.X, grid.faces.u.Y] = ndgrid(xu, yu);
    [grid.faces.v.X, grid.faces.v.Y] = ndgrid(xv, yv);
end

function grid = localGenerateCoordinates3D(grid)
    m = grid.m; n = grid.n; o = grid.o;
    dx = grid.dx; dy = grid.dy; dz = grid.dz;

    xn = (0:m) * dx;
    yn = (0:n) * dy;
    zn = (0:o) * dz;
    xc = [0, (0.5:m-0.5) * dx, m*dx];
    yc = [0, (0.5:n-0.5) * dy, n*dy];
    zc = [0, (0.5:o-0.5) * dz, o*dz];

    [grid.nodes.X,   grid.nodes.Y,   grid.nodes.Z]   = ndgrid(xn, yn, zn);
    [grid.centers.X, grid.centers.Y, grid.centers.Z] = ndgrid(xc, yc, zc);

    [grid.faces.u.X, grid.faces.u.Y, grid.faces.u.Z] = ndgrid(xn, (0.5:n-0.5)*dy, (0.5:o-0.5)*dz);
    [grid.faces.v.X, grid.faces.v.Y, grid.faces.v.Z] = ndgrid((0.5:m-0.5)*dx, yn, (0.5:o-0.5)*dz);
    [grid.faces.w.X, grid.faces.w.Y, grid.faces.w.Z] = ndgrid((0.5:m-0.5)*dx, (0.5:n-0.5)*dy, zn);
end

function grid = localNormalizeCurvilinear2D(grid)
    if isfield(grid, 'dim')
        if grid.dim ~= 2
            grid = addGridError(grid, 102, 'validateGrid:InvalidDim2D', 'dim', 'grid.dim must be 2 for 2-D operators');
            return;
        end
    else
        grid.dim = 2;
    end
    grid.m = double(grid.m);
    grid.n = double(grid.n);
    grid = localValidateCurvilinearNodes2D(grid);
    if grid.error.hasError, return; end
    grid = localDeriveCurvilinearCoordinates2D(grid);
end

function grid = localValidateCurvilinearNodes2D(grid)
    m = grid.m; n = grid.n;
    if ~isfield(grid, 'nodes') || ~isfield(grid.nodes, 'X') || ~isfield(grid.nodes, 'Y')
        grid = addGridError(grid, 106, 'validateGrid:CurvilinearMissingNodes', 'nodes', 'Curvilinear grid requires grid.nodes.X and grid.nodes.Y to be set before calling validateGrid.');
        return;
    end
    expected = [m+1, n+1];
    if ~isequal(size(grid.nodes.X), expected) || ~isequal(size(grid.nodes.Y), expected)
        grid = addGridError(grid, 107, 'validateGrid:SizeMismatch', 'nodes', ...
            sprintf('Curvilinear grid.nodes.X/Y must be (%d x %d); got %s and %s.', ...
            m+1, n+1, mat2str(size(grid.nodes.X)), mat2str(size(grid.nodes.Y))));
        return;
    end
end

function grid = localDeriveCurvilinearCoordinates2D(grid)
    NX = grid.nodes.X;
    NY = grid.nodes.Y;
    % u-faces: average adjacent nodes along y (columns)
    grid.faces.u.X = 0.5 * (NX(:, 1:end-1) + NX(:, 2:end));
    grid.faces.u.Y = 0.5 * (NY(:, 1:end-1) + NY(:, 2:end));
    % v-faces: average adjacent nodes along x (rows)
    grid.faces.v.X = 0.5 * (NX(1:end-1, :) + NX(2:end, :));
    grid.faces.v.Y = 0.5 * (NY(1:end-1, :) + NY(2:end, :));
    % cell centers: bilinear average of 4 surrounding nodes
    grid.centers.X = 0.25 * (NX(1:end-1, 1:end-1) + NX(2:end, 1:end-1) + ...
                              NX(1:end-1, 2:end)   + NX(2:end, 2:end));
    grid.centers.Y = 0.25 * (NY(1:end-1, 1:end-1) + NY(2:end, 1:end-1) + ...
                              NY(1:end-1, 2:end)   + NY(2:end, 2:end));
end

function [isPeriodic, grid] = localNormalizeIsPeriodic(grid, bc, hasData, numAxes, errId)
    if isfield(bc, 'isPeriodic')
        if ~islogical(bc.isPeriodic) && ~isnumeric(bc.isPeriodic)
            grid = addGridError(grid, 105, errId, 'bc.isPeriodic', 'isPeriodic must be logical');
            isPeriodic = []; return;
        end
        isPeriodic = logical(bc.isPeriodic(:));
        if numel(isPeriodic) == 1
            isPeriodic = repmat(isPeriodic, numAxes, 1);
        elseif numel(isPeriodic) ~= numAxes
            grid = addGridError(grid, 105, errId, 'bc.isPeriodic', sprintf('isPeriodic must be a scalar or %dx1 logical vector', numAxes));
            isPeriodic = []; return;
        end
        
        if hasData
            for a = 1:numAxes
                idx1 = 2*a - 1;
                idx2 = 2*a;
                if isPeriodic(a) && ~isempty(find(bc.dc(idx1:idx2).^2 + bc.nc(idx1:idx2).^2, 1))
                    grid = addGridError(grid, 108, 'validateGrid:PeriodicBCConflict', 'bc', 'Periodic axis cannot carry non-periodic BC coefficients');
                    return;
                end
            end
        end
    else
        isPeriodic = false(numAxes, 1);
        if hasData
            for a = 1:numAxes
                idx1 = 2*a - 1;
                idx2 = 2*a;
                isPeriodic(a) = isempty(find(bc.dc(idx1:idx2).^2 + bc.nc(idx1:idx2).^2, 1));
            end
        end
    end
end
