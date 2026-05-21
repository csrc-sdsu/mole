function grid = validateGrid_impl(grid, allowPartial)
% Canonical implementation for validateGrid.

    if nargin < 2
        allowPartial = false;
    end

    assert(isstruct(grid), 'grid must be a struct');

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
        localRequire(grid, {'m'}, allowPartial, 'validateGrid:MissingField1D');
        grid = localNormalizeIfUniform1D(grid, allowPartial);
    case 2
        localRequire(grid, {'m', 'n'}, allowPartial, 'validateGrid:MissingField2D');
        grid = localNormalizeIfUniform2D(grid, allowPartial);
    case 3
        localRequire(grid, {'m', 'n', 'o'}, allowPartial, 'validateGrid:MissingField3D');
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

function grid = localNormalizeIfUniform1D(grid, allowPartial)
    hasUniform = isfield(grid, 'm') && isfield(grid, 'dx');
    if hasUniform
        grid = localNormalizeGrid1D(grid);
    elseif ~allowPartial && strcmpi(grid.type, 'uniform')
        error('validateGrid:MissingUniform1D', ...
              'Uniform 1-D grid requires grid.m and grid.dx');
    end
end

function grid = localNormalizeIfUniform2D(grid, allowPartial)
    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy');
    if hasUniform
        grid = localNormalizeGrid2D(grid);
    elseif ~allowPartial && strcmpi(grid.type, 'uniform')
        error('validateGrid:MissingUniform2D', ...
              'Uniform 2-D grid requires grid.m, grid.n, grid.dx, and grid.dy');
    end
end

function grid = localNormalizeIfUniform3D(grid, allowPartial)
    hasUniform = isfield(grid, 'm') && isfield(grid, 'n') && isfield(grid, 'o') && ...
                 isfield(grid, 'dx') && isfield(grid, 'dy') && isfield(grid, 'dz');
    if hasUniform
        grid = localNormalizeGrid3D(grid);
    elseif ~allowPartial && strcmpi(grid.type, 'uniform')
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
        grid.type = 'periodic';
    else
        grid.type = 'uniform';
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
        grid.type = 'periodic';
    else
        grid.type = 'uniform';
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
        grid.type = 'periodic';
    else
        grid.type = 'uniform';
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
