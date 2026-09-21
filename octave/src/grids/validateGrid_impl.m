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

    if nargin < 2
        allowPartial = false;
    end

    if ~isstruct(grid) || ~isscalar(grid)
        error('validateGrid:InvalidGrid', 'grid must be a scalar struct');
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
        grid.dim = localInferDim(grid);
    elseif isequal(grid.dim, 1) || isequal(grid.dim, 2) || isequal(grid.dim, 3)
        % Only a legal dim value can meaningfully "conflict" with the fields
        % present; anything else falls through to the switch below, which
        % raises validateGrid:InvalidDim.
        inferredDim = localInferDim(grid);
        if grid.dim ~= inferredDim
            error('validateGrid:DimMismatch', ...
                  'grid.dim is %d, but present fields imply a %d-D grid.', ...
                  grid.dim, inferredDim);
        end
    end

    if ~isfield(grid, 'topology')
        if localHasCurvilinearEvidence(grid)
            grid.topology = 'curvilinear';
        else
            grid.topology = 'uniform';
        end
    elseif localHasCurvilinearEvidence(grid) && ~strcmpi(grid.topology, 'curvilinear')
        error('validateGrid:TopologyMismatch', ...
              'grid.X/Y/Z or grid.nodes.X/Y/Z coordinates imply a curvilinear grid, but grid.topology is ''%s''.', ...
              grid.topology);
    end

    switch grid.dim
    case 1
        localRequire(grid, {'m'}, allowPartial, 'validateGrid:MissingField1D');
        localValidateCellCounts(grid, {'m'}, 'validateGrid:InvalidCellCount1D');
        grid = localNormalizeIfUniform1D(grid, allowPartial);
    case 2
        localRequire(grid, {'m', 'n'}, allowPartial, 'validateGrid:MissingField2D');
        localValidateCellCounts(grid, {'m', 'n'}, 'validateGrid:InvalidCellCount2D');
        grid = localNormalizeIfUniform2D(grid, allowPartial);
    case 3
        localRequire(grid, {'m', 'n', 'o'}, allowPartial, 'validateGrid:MissingField3D');
        localValidateCellCounts(grid, {'m', 'n', 'o'}, 'validateGrid:InvalidCellCount3D');
        grid = localNormalizeIfUniform3D(grid, allowPartial);
    otherwise
        error('validateGrid:InvalidDim', 'grid.dim must be 1, 2, or 3');
    end
end

function localRequire(grid, names, allowPartial, errId)
    for i = 1:numel(names)
        if ~isfield(grid, names{i}) && ~allowPartial
            error(errId, ['Missing required field grid.' names{i}]);
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
    tf = isfield(grid, 'nodes') && isstruct(grid.nodes) && isfield(grid.nodes, fieldName);
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

function localValidateCellCounts(grid, names, errId)
% Cell counts (m, n, o) must be positive, finite, integer-valued scalars.
    for i = 1:numel(names)
        name = names{i};
        if ~isfield(grid, name)
            continue;
        end
        value = grid.(name);
        if ~isnumeric(value) || ~isscalar(value) || ~isreal(value)
            error(errId, 'grid.%s must be a real numeric scalar', name);
        elseif ~isfinite(value)
            error(errId, 'grid.%s must be finite', name);
        elseif value <= 0 || value ~= round(value)
            error(errId, 'grid.%s must be a positive integer', name);
        end
    end
end

function localValidateSpacing(grid, names, errId)
% Step sizes (dx, dy, dz) must be positive, finite, real numeric scalars.
    for i = 1:numel(names)
        name = names{i};
        value = grid.(name);
        if ~isnumeric(value) || ~isscalar(value) || ~isreal(value)
            error(errId, 'grid.%s must be a real numeric scalar', name);
        elseif ~isfinite(value)
            error(errId, 'grid.%s must be finite', name);
        elseif value <= 0
            error(errId, 'grid.%s must be positive', name);
        end
    end
end

function grid = localNormalizeIfUniform1D(grid, allowPartial)
    hasUniform = isfield(grid, 'm') && isfield(grid, 'dx');
    if hasUniform
        grid = localNormalizeGrid1D(grid);
    elseif ~allowPartial && strcmpi(grid.topology, 'uniform')
        error('validateGrid:MissingUniform1D', ...
              'Uniform 1-D grid requires grid.m and grid.dx');
    end
end

function grid = localNormalizeIfUniform2D(grid, allowPartial)
    % Curvilinear grids have their own normalisation path
    if strcmp(grid.topology, 'curvilinear')
        if isfield(grid, 'm') && isfield(grid, 'n')
            grid = localNormalizeCurvilinear2D(grid);
        end
        return;
    end

    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy');
    if hasUniform
        grid = localNormalizeGrid2D(grid);
    elseif ~allowPartial && strcmpi(grid.topology, 'uniform')
        error('validateGrid:MissingUniform2D', ...
              'Uniform 2-D grid requires grid.m, grid.n, grid.dx, and grid.dy');
    end
end

function grid = localNormalizeIfUniform3D(grid, allowPartial)
    % Curvilinear grids have their own normalisation path
    if strcmp(grid.topology, 'curvilinear')
        if isfield(grid, 'm') && isfield(grid, 'n') && isfield(grid, 'o')
            grid = localNormalizeCurvilinear3D(grid);
        end
        return;
    end

    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && isfield(grid, 'o') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy') && isfield(grid, 'dz');
    if hasUniform
        grid = localNormalizeGrid3D(grid);
    elseif ~allowPartial && strcmpi(grid.topology, 'uniform')
        error('validateGrid:MissingUniform3D', ...
              'Uniform 3-D grid requires grid.m, grid.n, grid.o, grid.dx, grid.dy, and grid.dz');
    end
end

function grid = localNormalizeGrid1D(grid)
    if isfield(grid, 'dim')
        assert(grid.dim == 1, 'grid.dim must be 1 for 1-D operators');
    else
        grid.dim = 1;
    end

    assert(isfield(grid, 'm'), 'grid.m is required');
    assert(isfield(grid, 'dx'), 'grid.dx is required for uniform 1-D operators');

    localValidateSpacing(grid, {'dx'}, 'validateGrid:InvalidSpacing1D');

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

    [bc.dc, bc.nc, bc.hasData] = localNormalizeBoundaryCoefficients(bc, 2, 'validateGrid:InvalidBC1D');
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

function grid = localNormalizeGrid2D(grid)
    if isfield(grid, 'dim')
        assert(grid.dim == 2, 'grid.dim must be 2 for 2-D operators');
    else
        grid.dim = 2;
    end

    assert(isfield(grid, 'm'), 'grid.m is required');
    assert(isfield(grid, 'n'), 'grid.n is required');
    assert(isfield(grid, 'dx'), 'grid.dx is required for uniform 2-D operators');
    assert(isfield(grid, 'dy'), 'grid.dy is required for uniform 2-D operators');

    localValidateSpacing(grid, {'dx', 'dy'}, 'validateGrid:InvalidSpacing2D');

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

    [bc.dc, bc.nc, bc.hasData] = localNormalizeBoundaryCoefficients(bc, 4, 'validateGrid:InvalidBC2D');
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

function grid = localNormalizeGrid3D(grid)
    if isfield(grid, 'dim')
        assert(grid.dim == 3, 'grid.dim must be 3 for 3-D operators');
    else
        grid.dim = 3;
    end

    assert(isfield(grid, 'm'), 'grid.m is required');
    assert(isfield(grid, 'n'), 'grid.n is required');
    assert(isfield(grid, 'o'), 'grid.o is required');
    assert(isfield(grid, 'dx'), 'grid.dx is required for uniform 3-D operators');
    assert(isfield(grid, 'dy'), 'grid.dy is required for uniform 3-D operators');
    assert(isfield(grid, 'dz'), 'grid.dz is required for uniform 3-D operators');

    localValidateSpacing(grid, {'dx', 'dy', 'dz'}, 'validateGrid:InvalidSpacing3D');

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

    [bc.dc, bc.nc, bc.hasData] = localNormalizeBoundaryCoefficients(bc, 6, 'validateGrid:InvalidBC3D');
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

function [dc, nc, hasData] = localNormalizeBoundaryCoefficients(bc, expectedCount, errId)
    hasDC = isfield(bc, 'dc');
    hasNC = isfield(bc, 'nc');

    if ~hasDC && ~hasNC
        dc = [];
        nc = [];
        hasData = false;
        return;
    end

    if hasDC ~= hasNC
        error(errId, 'grid.bc.dc and grid.bc.nc must be provided together');
    end

    if isempty(bc.dc) && isempty(bc.nc)
        dc = [];
        nc = [];
        hasData = false;
        return;
    end

    if isempty(bc.dc) || isempty(bc.nc)
        error(errId, 'grid.bc.dc and grid.bc.nc must both be empty or both be non-empty');
    end

    dc = localNormalizeBoundaryVector(bc.dc, expectedCount, 'grid.bc.dc', errId);
    nc = localNormalizeBoundaryVector(bc.nc, expectedCount, 'grid.bc.nc', errId);
    hasData = true;
end

function values = localNormalizeBoundaryVector(values, expectedCount, fieldName, errId)
    assert(isnumeric(values), [fieldName ' must be numeric']);
    assert(isvector(values), [fieldName ' must be a scalar or vector']);

    values = double(values(:));
    if numel(values) == 1
        values = repmat(values, expectedCount, 1);
    elseif numel(values) ~= expectedCount
        error(errId, '%s must be a scalar or a %dx1 vector', fieldName, expectedCount);
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
        assert(grid.dim == 2, 'grid.dim must be 2 for 2-D operators');
    else
        grid.dim = 2;
    end
    grid.m = double(grid.m);
    grid.n = double(grid.n);
    grid = localValidateCurvilinearNodes2D(grid);
    grid = localDeriveCurvilinearCoordinates2D(grid);
end

function grid = localValidateCurvilinearNodes2D(grid)
    m = grid.m; n = grid.n;
    if ~isfield(grid, 'nodes') || ~isfield(grid.nodes, 'X') || ~isfield(grid.nodes, 'Y')
        error('validateGrid:CurvilinearMissingNodes', ...
            'Curvilinear grid requires grid.nodes.X and grid.nodes.Y to be set before calling validateGrid.');
    end
    expected = [m+1, n+1];
    if ~isequal(size(grid.nodes.X), expected) || ~isequal(size(grid.nodes.Y), expected)
        error('validateGrid:SizeMismatch', ...
            'Curvilinear grid.nodes.X/Y must be (%d x %d); got (%s) and (%s).', ...
            m+1, n+1, mat2str(size(grid.nodes.X)), mat2str(size(grid.nodes.Y)));
    end
    localValidateCurvilinearNodeData(grid.nodes, {'X', 'Y'});
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

function grid = localNormalizeCurvilinear3D(grid)
    if isfield(grid, 'dim')
        assert(grid.dim == 3, 'grid.dim must be 3 for 3-D operators');
    else
        grid.dim = 3;
    end
    grid.m = double(grid.m);
    grid.n = double(grid.n);
    grid.o = double(grid.o);
    grid = localValidateCurvilinearNodes3D(grid);
    grid = localDeriveCurvilinearCoordinates3D(grid);
end

function grid = localValidateCurvilinearNodes3D(grid)
    m = grid.m; n = grid.n; o = grid.o;
    if ~isfield(grid, 'nodes') || ~isfield(grid.nodes, 'X') || ...
       ~isfield(grid.nodes, 'Y') || ~isfield(grid.nodes, 'Z')
        error('validateGrid:CurvilinearMissingNodes', ...
            'Curvilinear grid requires grid.nodes.X, grid.nodes.Y, and grid.nodes.Z to be set before calling validateGrid.');
    end
    expected = [m+1, n+1, o+1];
    if ~isequal(size(grid.nodes.X), expected) || ~isequal(size(grid.nodes.Y), expected) || ...
       ~isequal(size(grid.nodes.Z), expected)
        error('validateGrid:SizeMismatch', ...
            'Curvilinear grid.nodes.X/Y/Z must be (%d x %d x %d); got X=(%s), Y=(%s), Z=(%s).', ...
            m+1, n+1, o+1, mat2str(size(grid.nodes.X)), mat2str(size(grid.nodes.Y)), mat2str(size(grid.nodes.Z)));
    end
    localValidateCurvilinearNodeData(grid.nodes, {'X', 'Y', 'Z'});
end

function localValidateCurvilinearNodeData(nodes, fieldNames)
% Curvilinear node coordinates must be real, finite numeric data -- correct
% array shape alone doesn't guarantee they're safe to interpolate/derive from.
    for i = 1:numel(fieldNames)
        name = fieldNames{i};
        value = nodes.(name);
        if ~isnumeric(value) || ~isreal(value)
            error('validateGrid:InvalidCurvilinearNodes', ...
                'grid.nodes.%s must be real numeric data', name);
        elseif ~all(isfinite(value(:)))
            error('validateGrid:InvalidCurvilinearNodes', ...
                'grid.nodes.%s must contain only finite values', name);
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
