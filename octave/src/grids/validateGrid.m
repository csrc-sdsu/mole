function grid = validateGrid(grid, allowPartial, errorObj)
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
% Throws validateGrid:SizeMismatch if pre-populated coordinate arrays
% disagree with m/n/o, and validateGrid:CurvilinearMissingNodes if a
% curvilinear grid lacks node coordinates.
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
    if nargin < 3
        errorObj = MOLE_errors();
    end
    if nargin < 2
        allowPartial = false;
    end

    if ~isstruct(grid) || ~isscalar(grid)
        params = sprintf('grid must be a scalar or a struct; received class %s with size %s.', class(grid), mat2str(size(grid)));
        errorObj.log_error('MOLE_ERR_INVALID_INPUT_TYPE', 'validateGrid', true, params);
    end

    if ~isfield(grid, 'bc')
        grid.bc = struct();
    elseif ~isstruct(grid.bc) || ~isscalar(grid.bc)
        params = sprintf('grid.bc must be a scalar or a struct; received class %s with size %s.', class(grid.bc), mat2str(size(grid.bc)));
        errorObj.log_error('MOLE_ERR_INVALID_INPUT_TYPE', 'validateGrid', false, params);
    end

    if isfield(grid, 'dc') && ~isfield(grid.bc, 'dc')
        grid.bc.dc = grid.dc;
    end
    if isfield(grid, 'nc') && ~isfield(grid.bc, 'nc')
        grid.bc.nc = grid.nc;
    end

    if ~isfield(grid, 'dim')
        grid.dim = localInferDim(grid);
    elseif isequal(grid.dim, 1) || isequal(grid.dim, 2) || isequal(grid.dim, 3)
        % Only a legal dim value can meaningfully "conflict" with the fields
        % present; anything else falls through to the switch below, which
        % raises validateGrid:InvalidDim.
        inferredDim = localInferDim(grid);
        if inferredDim > grid.dim
            #Inferred dimension logged error
            params = sprintf('grid.dim is %d, but supplied fields imply at least %d dimensions.', grid.dim, inferredDim);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'validateGrid', false, params);
        end
    end

    if ~isfield(grid, 'topology')
        if localHasCurvilinearEvidence(grid)
            grid.topology = 'curvilinear';
        else
            grid.topology = 'uniform';
        end
    elseif localHasCurvilinearEvidence(grid) && ~strcmpi(grid.topology, 'curvilinear')
        params = sprintf('Supplied coordinates imply a curvilinear grid, but grid.topology is %s.', grid.topology);
        errorObj.log_error('MOLE_ERR_INVALID_GRID_TOPOLOGY', 'validateGrid', false, params);
    end

    switch grid.dim
    case 1
        localRequire(grid, {'m'}, allowPartial, 'MOLE_ERR_INVALID_GRID_SIZE', errorObj);
        localValidateCellCounts(grid, {'m'}, errorObj);
        grid = localNormalizeIfUniform1D(grid, allowPartial, errorObj);
    case 2
        localRequire(grid, {'m', 'n'}, allowPartial, 'MOLE_ERR_INVALID_GRID_SIZE', errorObj);
        localValidateCellCounts(grid, {'m', 'n'}, errorObj);
        grid = localNormalizeIfUniform2D(grid, allowPartial, errorObj);
    case 3
        localRequire(grid, {'m', 'n', 'o'}, allowPartial, 'MOLE_ERR_INVALID_GRID_SIZE', errorObj);
        localValidateCellCounts(grid, {'m', 'n', 'o'}, errorObj);
        grid = localNormalizeIfUniform3D(grid, allowPartial, errorObj);
    otherwise
        params = sprintf('grid.dim must be 1, 2, or 3; received class %s with size %s.', class(grid.dim), mat2str(size(grid.dim)));
        errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'validateGrid', false, params);
    end
end

function localRequire(grid, names, allowPartial, errName, errorObj)
    for i = 1:numel(names)
        if ~isfield(grid, names{i}) && ~allowPartial
            params = sprintf('Missing required field grid.%s during full validation.', names{i});
            errorObj.log_error(errName, 'localRequire', true, params);
        end
    end
end

function dim = localInferDim(grid)
    if isfield(grid, 'o') || isfield(grid, 'dz') || isfield(grid, 'Z')
        dim = 3;
    elseif isfield(grid, 'n') || isfield(grid, 'dy') || isfield(grid, 'Y')
        dim = 2;
    else
        dim = 1;
    end
end

function tf = localHasNodeField(grid, fieldName)
    tf = isfield(grid, 'nodes') && isstruct(grid.nodes) && isscalar(grid.nodes) && isfield(grid.nodes, fieldName);
end

function tf = localHasCurvilinearEvidence(grid)
% True when the grid's own fields imply curvilinear topology: legacy
% top-level X/Y/Z, or raw (caller-supplied) grid.nodes.X/Y/Z. Once
% grid.faces/grid.centers have been derived by validateGrid itself, the
% presence of grid.nodes.X/Y/Z is that generated output, not caller intent,
% so it no longer counts as curvilinear evidence.
    hasLegacyFields = isfield(grid, 'X') || isfield(grid, 'Y') || isfield(grid, 'Z');
    hasRawNodes = localHasNodeField(grid, 'X') || localHasNodeField(grid, 'Y') || localHasNodeField(grid, 'Z');
    hasGeneratedGeometry = isfield(grid, 'faces') || isfield(grid, 'centers');
    tf = hasLegacyFields || (hasRawNodes && ~hasGeneratedGeometry);
end

function localValidateCellCounts(grid, names, errorObj)
% Cell counts (m, n, o) must be positive, finite, integer-valued scalars.
    for i = 1:numel(names)
        name = names{i};
        if ~isfield(grid, name)
            continue;
        end
        value = grid.(name);
        if ~isnumeric(value) || ~isscalar(value) || ~isreal(value)
            params = sprintf('grid.%s must be a real numeric scalar.', name);
            errorObj.log_error('MOLE_ERR_INVALID_INPUT_TYPE', 'localValidateCellCounts', true, params);
        elseif ~isfinite(value)
            params = sprintf('grid.%s must be finite.', name);
            errorObj.log_error('MOLE_ERR_INVALID_CELL_COUNT', 'localValidateCellCounts', true, params);
        elseif value <= 0 || value ~= round(value)
            params = sprintf('grid.%s must be a positive integer.', name);
            errorObj.log_error('MOLE_ERR_INVALID_CELL_COUNT', 'localValidateCellCounts', true, params);
        end
    end
end

function localValidateSpacing(grid, names, errorObj)
% Step sizes (dx, dy, dz) must be positive, finite, real numeric scalars.
    for i = 1:numel(names)
        name = names{i};
        value = grid.(name);
        if ~isnumeric(value) || ~isscalar(value) || ~isreal(value)
            params = sprintf('grid.%s must be a real numeric scalar.', name);
            errorObj.log_error('MOLE_ERR_INVALID_INPUT_TYPE', 'localValidateSpacing', true, params);
        elseif ~isfinite(value)
            params = sprintf('grid.%s must be finite.', name);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localValidateSpacing', true, params);
        elseif value <= 0
            params = sprintf('grid.%s must be positive.', name);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localValidateSpacing', true, params);
        end
    end
end

function grid = localNormalizeIfUniform1D(grid, allowPartial, errorObj)
    hasUniform = isfield(grid, 'm') && isfield(grid, 'dx');
    if hasUniform
        grid = localNormalizeGrid1D(grid, errorObj);
    elseif ~allowPartial && strcmpi(grid.topology, 'uniform')
        params = 'Uniform 1-D grid requires grid.dx.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localNormalizeIfUniform1D', true, params);
    end
end

function grid = localNormalizeIfUniform2D(grid, allowPartial, errorObj)
    % Curvilinear grids have their own normalisation path
    if strcmp(grid.topology, 'curvilinear')
        hasCounts = isfield(grid, 'm') && isfield(grid, 'n');
        hasNodes = isfield(grid, 'nodes') && isstruct(grid.nodes) && isscalar(grid.nodes) && isfield(grid.nodes, 'X') && isfield(grid.nodes, 'Y');
        if hasCounts && (hasNodes || ~allowPartial)
            grid = localNormalizeCurvilinear2D(grid, errorObj);
        end
        return;
    end

    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy');
    if hasUniform
        grid = localNormalizeGrid2D(grid, errorObj);
    elseif ~allowPartial && strcmpi(grid.topology, 'uniform')
        params = 'Uniform 2-D grid requires grid.dx and grid.dy.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localNormalizeIfUniform2D', true, params);
    end
end

function grid = localNormalizeIfUniform3D(grid, allowPartial, errorObj)
    % Curvilinear grids have their own normalisation path
    if strcmp(grid.topology, 'curvilinear')
        hasCounts = isfield(grid, 'm') && isfield(grid, 'n') && isfield(grid, 'o');
        hasNodes = isfield(grid, 'nodes') && isstruct(grid.nodes) && isscalar(grid.nodes) && isfield(grid.nodes, 'X') && isfield(grid.nodes, 'Y') && isfield(grid.nodes, 'Z');
        if hasCounts && (hasNodes || ~allowPartial)
            grid = localNormalizeCurvilinear3D(grid, errorObj);
        end
        return;
    end

    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && isfield(grid, 'o') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy') && isfield(grid, 'dz');
    if hasUniform
        grid = localNormalizeGrid3D(grid, errorObj);
    elseif ~allowPartial && strcmpi(grid.topology, 'uniform')
        params = 'Uniform 3-D grid requires grid.dx, grid.dy, and grid.dz.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localNormalizeIfUniform3D', true, params);
    end
end

function grid = localNormalizeGrid1D(grid, errorObj)
    if isfield(grid, 'dim')
        if grid.dim ~= 1
            params = sprintf('grid.dim must be 1 for 1-D normalization; received %d.', grid.dim);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'localNormalizeGrid1D', true, params);
        end
    else
        grid.dim = 1;
    end

    if ~isfield(grid, 'm')
        params = 'Missing required field grid.m.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SIZE', 'localNormalizeGrid1D', true, params);
    end
    if ~isfield(grid, 'dx')
        params = 'Missing required field grid.dx.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localNormalizeGrid1D', true, params);
    end

    localValidateSpacing(grid, {'dx'}, errorObj);

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

    [bc.dc, bc.nc, bc.hasData] = localNormalizeBoundaryCoefficients(bc, 2, errorObj);
    if bc.hasData
        bc.isPeriodic = isempty(find(bc.dc .* bc.dc + bc.nc .* bc.nc, 1));
    else
        bc.isPeriodic = false;
    end

    grid.bc = bc;
    if grid.bc.isPeriodic
        grid.topology = 'periodic';
    else
        grid.topology = 'uniform';
    end

    grid = localGenerateCoordinates1D(grid);
end

function grid = localNormalizeGrid2D(grid, errorObj)
    if isfield(grid, 'dim')
        if grid.dim ~= 2
            params = sprintf('grid.dim must be 2 for 2-D normalization; received %d.', grid.dim);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'localNormalizeGrid2D', true, params);
        end
    else
        grid.dim = 2;
    end

    if ~isfield(grid, 'm')
        params = 'Missing required field grid.m.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SIZE', 'localNormalizeGrid2D', true, params);
    end
    if ~isfield(grid, 'n')
        params = 'Missing required field grid.n.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SIZE', 'localNormalizeGrid2D', true, params);
    end
    if ~isfield(grid, 'dx')
        params = 'Missing required field grid.dx.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localNormalizeGrid2D', true, params);
    end
    if ~isfield(grid, 'dy')
        params = 'Missing required field grid.dy.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localNormalizeGrid2D', true, params);
    end

    localValidateSpacing(grid, {'dx', 'dy'}, errorObj);

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

    [bc.dc, bc.nc, bc.hasData] = localNormalizeBoundaryCoefficients(bc, 4, errorObj);
    if bc.hasData
        bc.isPeriodic = [isempty(find(bc.dc(1:2).^2 + bc.nc(1:2).^2, 1)); ...
                         isempty(find(bc.dc(3:4).^2 + bc.nc(3:4).^2, 1))];
    else
        bc.isPeriodic = [false; false];
    end

    grid.bc = bc;
    if any(grid.bc.isPeriodic)
        grid.topology = 'periodic';
    else
        grid.topology = 'uniform';
    end

    grid = localGenerateCoordinates2D(grid);
end

function grid = localNormalizeGrid3D(grid, errorObj)
    if isfield(grid, 'dim')
        if grid.dim ~= 3
            params = sprintf('grid.dim must be 3 for 3-D normalization; received %d.', grid.dim);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'localNormalizeGrid3D', true, params);
        end
    else
        grid.dim = 3;
    end

    countNames = {'m', 'n', 'o'};
    for i = 1:numel(countNames)
        if ~isfield(grid, countNames{i})
            params = sprintf('Missing required field grid.%s.', countNames{i});
            errorObj.log_error('MOLE_ERR_INVALID_GRID_SIZE', 'localNormalizeGrid3D', true, params);
        end
    end

    spacingNames = {'dx', 'dy', 'dz'};
    for i = 1:numel(spacingNames)
        if ~isfield(grid, spacingNames{i})
            params = sprintf('Missing required field grid.%s.', spacingNames{i});
            errorObj.log_error('MOLE_ERR_INVALID_GRID_SPACING', 'localNormalizeGrid3D', true, params);
        end
    end

    localValidateSpacing(grid, {'dx', 'dy', 'dz'}, errorObj);

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

    [bc.dc, bc.nc, bc.hasData] = localNormalizeBoundaryCoefficients(bc, 6, errorObj);
    if bc.hasData
        bc.isPeriodic = [isempty(find(bc.dc(1:2).^2 + bc.nc(1:2).^2, 1)); ...
                         isempty(find(bc.dc(3:4).^2 + bc.nc(3:4).^2, 1)); ...
                         isempty(find(bc.dc(5:6).^2 + bc.nc(5:6).^2, 1))];
    else
        bc.isPeriodic = [false; false; false];
    end

    grid.bc = bc;
    if any(grid.bc.isPeriodic)
        grid.topology = 'periodic';
    else
        grid.topology = 'uniform';
    end

    grid = localGenerateCoordinates3D(grid);
end

function [dc, nc, hasData] = localNormalizeBoundaryCoefficients(bc, expectedCount, errorObj)
    hasDC = isfield(bc, 'dc');
    hasNC = isfield(bc, 'nc');

    if ~hasDC && ~hasNC
        dc = [];
        nc = [];
        hasData = false;
        return;
    end

    if hasDC ~= hasNC
        params = 'grid.bc.dc and grid.bc.nc must be provided together.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'localNormalizeBoundaryCoefficients', true, params);
    end

    if isempty(bc.dc) && isempty(bc.nc)
        dc = [];
        nc = [];
        hasData = false;
        return;
    end

    if isempty(bc.dc) || isempty(bc.nc)
        params = 'grid.bc.dc and grid.bc.nc must both be empty or both be non-empty.';
        errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'localNormalizeBoundaryCoefficients', true, params);
    end

    dc = localNormalizeBoundaryVector(bc.dc, expectedCount, 'grid.bc.dc', errorObj);
    nc = localNormalizeBoundaryVector(bc.nc, expectedCount, 'grid.bc.nc', errorObj);
    hasData = true;
end

function values = localNormalizeBoundaryVector(values, expectedCount, fieldName, errorObj)
    if ~isnumeric(values)
        params = sprintf('%s must be numeric.', fieldName);
        errorObj.log_error('MOLE_ERR_INVALID_INPUT_TYPE', 'localNormalizeBoundaryVector', true, params);
    end
    if ~isvector(values)
        params = sprintf('%s must be a scalar or vector.', fieldName);
        errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'localNormalizeBoundaryVector', true, params);
    end

    values = double(values(:));
    if numel(values) == 1
        values = repmat(values, expectedCount, 1);
    elseif numel(values) ~= expectedCount
        params = sprintf('%s must be a scalar or a %dx1 vector.', fieldName, expectedCount);
        errorObj.log_error('MOLE_ERR_INVALID_GRID_ARGS', 'localNormalizeBoundaryVector', true, params);
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

function grid = localNormalizeCurvilinear2D(grid, errorObj)
    if isfield(grid, 'dim')
        if grid.dim ~= 2
            params = sprintf('grid.dim must be 2 for 2-D curvilinear normalization; received %d.', grid.dim);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'localNormalizeCurvilinear2D', true, params);
        end
    else
        grid.dim = 2;
    end
    grid.m = double(grid.m);
    grid.n = double(grid.n);
    grid = localValidateCurvilinearNodes2D(grid, errorObj);
    grid = localDeriveCurvilinearCoordinates2D(grid);
end

function grid = localValidateCurvilinearNodes2D(grid, errorObj)
    m = grid.m; n = grid.n;
    if ~isfield(grid, 'nodes')
        params = 'Curvilinear grid requires grid.nodes.X and grid.nodes.Y before full validation.';
        errorObj.log_error('MOLE_ERR_INVALID_CURVILINEAR_GRID', 'localValidateCurvilinearNodes2D', true, params);
    end
    if ~isstruct(grid.nodes) || ~isscalar(grid.nodes)
        params = sprintf('grid.nodes must be a scalar struct; received class %s with size %s.', class(grid.nodes), mat2str(size(grid.nodes)));
        errorObj.log_error('MOLE_ERR_INVALID_INPUT_TYPE', 'localValidateCurvilinearNodes2D', true, params);
    end
    if ~isfield(grid.nodes, 'X') || ~isfield(grid.nodes, 'Y')
        params = 'Curvilinear grid requires grid.nodes.X and grid.nodes.Y before full validation.';
        errorObj.log_error('MOLE_ERR_INVALID_CURVILINEAR_GRID', 'localValidateCurvilinearNodes2D', true, params);
    end
    expected = [m+1, n+1];
    if ~isequal(size(grid.nodes.X), expected) || ~isequal(size(grid.nodes.Y), expected)
        params = sprintf('Curvilinear grid.nodes.X/Y must be (%d x %d); received sizes %s and %s.', m+1, n+1, mat2str(size(grid.nodes.X)), mat2str(size(grid.nodes.Y)));
        errorObj.log_error('MOLE_ERR_GRID_NODAL_SZ_MISMATCH', 'localValidateCurvilinearNodes2D', true, params);
    end
    localValidateCurvilinearNodeData(grid.nodes, {'X', 'Y'}, errorObj);
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

function grid = localNormalizeCurvilinear3D(grid, errorObj)
    if isfield(grid, 'dim')
        if grid.dim ~= 3
            params = sprintf('grid.dim must be 3 for 3-D curvilinear normalization; received %d.', grid.dim);
            errorObj.log_error('MOLE_ERR_INVALID_GRID_DIM', 'localNormalizeCurvilinear3D', true, params);
        end
    else
        grid.dim = 3;
    end
    grid.m = double(grid.m);
    grid.n = double(grid.n);
    grid.o = double(grid.o);
    grid = localValidateCurvilinearNodes3D(grid, errorObj);
    grid = localDeriveCurvilinearCoordinates3D(grid);
end

function grid = localValidateCurvilinearNodes3D(grid, errorObj)
    m = grid.m; n = grid.n; o = grid.o;
    if ~isfield(grid, 'nodes')
        params = 'Curvilinear grid requires grid.nodes.X, grid.nodes.Y, and grid.nodes.Z before full validation.';
        errorObj.log_error('MOLE_ERR_INVALID_CURVILINEAR_GRID', 'localValidateCurvilinearNodes3D', true, params);
    end
    if ~isstruct(grid.nodes) || ~isscalar(grid.nodes)
        params = sprintf('grid.nodes must be a scalar struct; received class %s with size %s.', class(grid.nodes), mat2str(size(grid.nodes)));
        errorObj.log_error('MOLE_ERR_INVALID_INPUT_TYPE', 'localValidateCurvilinearNodes3D', true, params);
    end
    if ~isfield(grid.nodes, 'X') || ~isfield(grid.nodes, 'Y') || ~isfield(grid.nodes, 'Z')
        params = 'Curvilinear grid requires grid.nodes.X, grid.nodes.Y, and grid.nodes.Z before full validation.';
        errorObj.log_error('MOLE_ERR_INVALID_CURVILINEAR_GRID', 'localValidateCurvilinearNodes3D', true, params);
    end
    expected = [m+1, n+1, o+1];
    if ~isequal(size(grid.nodes.X), expected) || ~isequal(size(grid.nodes.Y), expected) || ...
       ~isequal(size(grid.nodes.Z), expected)
        params = sprintf('Curvilinear grid.nodes.X/Y/Z must be (%d x %d x %d); received X=%s, Y=%s, and Z=%s.', m+1, n+1, o+1, mat2str(size(grid.nodes.X)), mat2str(size(grid.nodes.Y)), mat2str(size(grid.nodes.Z)));
        errorObj.log_error('MOLE_ERR_GRID_NODAL_SZ_MISMATCH', 'localValidateCurvilinearNodes3D', true, params);
    end
    localValidateCurvilinearNodeData(grid.nodes, {'X', 'Y', 'Z'}, errorObj);
end

function localValidateCurvilinearNodeData(nodes, fieldNames, errorObj)
% Curvilinear node coordinates must be real, finite numeric data -- correct
% array shape alone doesn't guarantee they're safe to interpolate/derive from.
    for i = 1:numel(fieldNames)
        name = fieldNames{i};
        value = nodes.(name);
        if ~isnumeric(value) || ~isreal(value)
            params = sprintf('grid.nodes.%s must contain real numeric data.', name);
            errorObj.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'localValidateCurvilinearNodeData', true, params);
        elseif ~all(isfinite(value(:)))
            params = sprintf('grid.nodes.%s must contain only finite values.', name);
            errorObj.log_error('MOLE_ERR_INVALID_NODAL_COORDINATES', 'localValidateCurvilinearNodeData', true, params);
        end
    end
end

function grid = localDeriveCurvilinearCoordinates3D(grid)
    NX = grid.nodes.X;
    NY = grid.nodes.Y;
    NZ = grid.nodes.Z;

    % u-faces: full range in x, bilinear average over y and z
    grid.faces.u.X = 0.25 * (NX(:,1:end-1,1:end-1) + NX(:,2:end,1:end-1) + ...
                              NX(:,1:end-1,2:end)   + NX(:,2:end,2:end));
    grid.faces.u.Y = 0.25 * (NY(:,1:end-1,1:end-1) + NY(:,2:end,1:end-1) + ...
                              NY(:,1:end-1,2:end)   + NY(:,2:end,2:end));
    grid.faces.u.Z = 0.25 * (NZ(:,1:end-1,1:end-1) + NZ(:,2:end,1:end-1) + ...
                              NZ(:,1:end-1,2:end)   + NZ(:,2:end,2:end));

    % v-faces: full range in y, bilinear average over x and z
    grid.faces.v.X = 0.25 * (NX(1:end-1,:,1:end-1) + NX(2:end,:,1:end-1) + ...
                              NX(1:end-1,:,2:end)   + NX(2:end,:,2:end));
    grid.faces.v.Y = 0.25 * (NY(1:end-1,:,1:end-1) + NY(2:end,:,1:end-1) + ...
                              NY(1:end-1,:,2:end)   + NY(2:end,:,2:end));
    grid.faces.v.Z = 0.25 * (NZ(1:end-1,:,1:end-1) + NZ(2:end,:,1:end-1) + ...
                              NZ(1:end-1,:,2:end)   + NZ(2:end,:,2:end));

    % w-faces: full range in z, bilinear average over x and y
    grid.faces.w.X = 0.25 * (NX(1:end-1,1:end-1,:) + NX(2:end,1:end-1,:) + ...
                              NX(1:end-1,2:end,:)   + NX(2:end,2:end,:));
    grid.faces.w.Y = 0.25 * (NY(1:end-1,1:end-1,:) + NY(2:end,1:end-1,:) + ...
                              NY(1:end-1,2:end,:)   + NY(2:end,2:end,:));
    grid.faces.w.Z = 0.25 * (NZ(1:end-1,1:end-1,:) + NZ(2:end,1:end-1,:) + ...
                              NZ(1:end-1,2:end,:)   + NZ(2:end,2:end,:));

    % cell centers: trilinear average of 8 surrounding nodes
    grid.centers.X = 0.125 * ( ...
        NX(1:end-1,1:end-1,1:end-1) + NX(2:end,1:end-1,1:end-1) + ...
        NX(1:end-1,2:end,1:end-1)   + NX(2:end,2:end,1:end-1)   + ...
        NX(1:end-1,1:end-1,2:end)   + NX(2:end,1:end-1,2:end)   + ...
        NX(1:end-1,2:end,2:end)     + NX(2:end,2:end,2:end));
    grid.centers.Y = 0.125 * ( ...
        NY(1:end-1,1:end-1,1:end-1) + NY(2:end,1:end-1,1:end-1) + ...
        NY(1:end-1,2:end,1:end-1)   + NY(2:end,2:end,1:end-1)   + ...
        NY(1:end-1,1:end-1,2:end)   + NY(2:end,1:end-1,2:end)   + ...
        NY(1:end-1,2:end,2:end)     + NY(2:end,2:end,2:end));
    grid.centers.Z = 0.125 * ( ...
        NZ(1:end-1,1:end-1,1:end-1) + NZ(2:end,1:end-1,1:end-1) + ...
        NZ(1:end-1,2:end,1:end-1)   + NZ(2:end,2:end,1:end-1)   + ...
        NZ(1:end-1,1:end-1,2:end)   + NZ(2:end,1:end-1,2:end)   + ...
        NZ(1:end-1,2:end,2:end)     + NZ(2:end,2:end,2:end));
end
