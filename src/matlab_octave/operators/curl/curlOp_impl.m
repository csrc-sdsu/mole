function C = curlOp_impl(grid, k)
% PURPOSE
% Grid-first mimetic 2-D curl operator.
%
% DESCRIPTION
% Assembles the three-component discrete curl for a 2-D uniform grid.
% Row blocks: x-component (n*(m+1) rows), y-component ((n+1)*m rows),
% scalar z-curl (n*m rows). Delegates to curl2D for the matrix assembly;
% the implementation will be absorbed inline in Plan 3 when curl2D.m is
% removed.
%
% Parameters:
%   C    : Sparse matrix — 2-D mimetic curl operator
%   grid : Validated grid struct (must be dim=2)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% C = curlOp_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    grid = validateGrid(grid);

    assert(grid.dim == 2, ...
           'curlOp_impl:InvalidDim', 'curl is only implemented for 2-D grids');
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k must be even');

    C = curl2D(k, grid.m, grid.dx, grid.n, grid.dy);
end
