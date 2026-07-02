function [N, err] = nodalOp_impl(grid, k)
% PURPOSE
% Grid-first nodal derivative operator for 1-D, 2-D, and 3-D uniform grids.
%
% DESCRIPTION
% This operator resolves nodal counts from the grid descriptor and builds
% the corresponding nodal mimetic operator.
%
% SYNTAX
% N = nodalOp_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    grid = validateGrid(grid, true);
    err = grid.error;
    if err.hasError
        N = [];
        return;
    end

    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');

    if strcmpi(grid.type, 'curvilinear')
        N = nodalCurv_impl(grid, k);
        return;
    end

    switch grid.dim
    case 1
        [mNodes] = resolveNodalCounts(grid, 1);
        assert(isfield(grid, 'dx'), 'grid.dx is required');
        N = localNodal1D(k, mNodes, grid.dx);

    case 2
        [mNodes, nNodes] = resolveNodalCounts(grid, 2);
        assert(isfield(grid, 'dx'), 'grid.dx is required');
        assert(isfield(grid, 'dy'), 'grid.dy is required');

        Nx = localNodal1D(k, mNodes, grid.dx);
        Ny = localNodal1D(k, nNodes, grid.dy);
        Im = speye(mNodes, mNodes);
        In = speye(nNodes, nNodes);
        N = [kron(In, Nx); kron(Ny, Im)];

    case 3
        [mNodes, nNodes, oNodes] = resolveNodalCounts(grid, 3);
        assert(isfield(grid, 'dx'), 'grid.dx is required');
        assert(isfield(grid, 'dy'), 'grid.dy is required');
        assert(isfield(grid, 'dz'), 'grid.dz is required');

        Nx = localNodal1D(k, mNodes, grid.dx);
        Ny = localNodal1D(k, nNodes, grid.dy);
        Nz = localNodal1D(k, oNodes, grid.dz);

        Im = speye(mNodes, mNodes);
        In = speye(nNodes, nNodes);
        Io = speye(oNodes, oNodes);

        Sx = kron(kron(Io, In), Nx);
        Sy = kron(kron(Io, Ny), Im);
        Sz = kron(kron(Nz, In), Im);
        N = [Sx; Sy; Sz];

    otherwise
        error('nodalOp:InvalidDim', 'grid.dim must be 1, 2, or 3');
    end
end

function N = localNodal1D(k, mNodes, dx)
    m = mNodes - 1;
    n_rows = m+1;
    n_cols = n_rows;

    N = sparse(n_rows, n_cols);

    neighbors = zeros(1, k+1); % Bandwidth = k+1
    neighbors(1) = -k/2;
    len = k+1;
    j = 1;

    for i = 2 : len
        neighbors(i) = neighbors(i-1)+1;
    end

    A = vander(neighbors)';
    b = zeros(len, 1);
    b(len-1) = 1;
    coeffs = A\b;

    for i = k/2+1 : n_rows-k/2
        N(i, j:j+len-1) = coeffs;
        j = j+1;
    end

    p = k/2;
    q = k+1;
    A = sparse(p, q);
    for i = 1 : p
        neighbors = zeros(1, q);
        neighbors(1) = 1-i;
        neighbors(2) = neighbors(1)+1;

        for j = 3 : q
            neighbors(j) = neighbors(j-1)+1;
        end

        V = vander(neighbors)';
        b = zeros(q, 1);
        b(q-1) = 1;
        coeffs = V\b;
        A(i, 1:q) = coeffs;
    end

    N(1:p, 1:q) = A;

    Pp = fliplr(speye(p));
    Pq = fliplr(speye(q));
    A = -Pp*A*Pq;
    N(n_rows-p+1:n_rows, n_cols-q+1:n_cols) = A;

    N = (1/dx)*N;
end