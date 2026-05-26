function [A, b] = addScalarBC_impl(A, b, k, grid, v)
% PURPOSE
% Canonical dim-dispatching implementation for unified addScalarBC.
%
% DESCRIPTION
% Reads grid.dim and calls the appropriate dimensional scalar BC
% implementation. The grid struct must be fully validated (bc.dc, bc.nc
% present and normalized) before this function is called.
%
% Parameters:
%   A    : Linear operator (modified in place)
%   b    : Right-hand-side vector (modified in place)
%   k    : Order of accuracy (even integer >= 2)
%   grid : Validated grid struct with grid.bc.dc and grid.bc.nc
%   v    : Boundary values (2×1 for 1D; cell array for 2D/3D)
%
% SYNTAX
% [A, b] = addScalarBC_impl(A, b, k, grid, v)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 1
        [A, b] = addScalarBC1D_impl(A, b, k, grid.m, grid.dx, ...
                                    grid.bc.dc, grid.bc.nc, v);
    case 2
        [A, b] = addScalarBC2D_impl(A, b, k, grid.m, grid.dx, ...
                                    grid.n, grid.dy, ...
                                    grid.bc.dc, grid.bc.nc, v);
    case 3
        [A, b] = addScalarBC3D_impl(A, b, k, grid.m, grid.dx, ...
                                    grid.n, grid.dy, ...
                                    grid.o, grid.dz, ...
                                    grid.bc.dc, grid.bc.nc, v);
    otherwise
        error('addScalarBC:InvalidDim', 'grid.dim must be 1, 2, or 3');
    end
end
