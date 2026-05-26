function varargout = resolveNodalCounts(grid, dim)
% PURPOSE
% Resolve nodal counts from a grid struct for nodal operators.
%
% DESCRIPTION
% The grid-first API uses top-level m/n/o primarily for cell-based operator
% wrappers. Nodal operators need nodal counts, so this helper derives them
% from the grid descriptor. If grid.shape is 'nodal', top-level m/n/o are
% treated as nodal counts. Otherwise, nodal counts default to cell counts
% plus one. Callers may override this by supplying grid.nodeCounts.
%
% SYNTAX
% m = resolveNodalCounts(grid, 1)
% [m, n] = resolveNodalCounts(grid, 2)
% [m, n, o] = resolveNodalCounts(grid, 3)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    assert(isstruct(grid), 'grid must be a struct');
    assert(ismember(dim, [1 2 3]), 'dim must be 1, 2, or 3');

    if isfield(grid, 'shape')
        isNodalShape = strcmpi(grid.shape, 'nodal');
    else
        isNodalShape = false;
    end

    if isfield(grid, 'nodeCounts') && isstruct(grid.nodeCounts)
        counts = grid.nodeCounts;
    else
        counts = struct();
    end

    m = localCount(grid, counts, 'm', isNodalShape);
    if dim == 1
        varargout = {m};
        return;
    end

    n = localCount(grid, counts, 'n', isNodalShape);
    if dim == 2
        varargout = {m, n};
        return;
    end

    o = localCount(grid, counts, 'o', isNodalShape);
    varargout = {m, n, o};
end

function count = localCount(grid, counts, fieldName, isNodalShape)
    if isfield(counts, fieldName)
        count = double(counts.(fieldName));
        return;
    end

    assert(isfield(grid, fieldName), ['grid.' fieldName ' is required']);
    baseCount = double(grid.(fieldName));
    if isNodalShape
        count = baseCount;
    else
        count = baseCount + 1;
    end
end