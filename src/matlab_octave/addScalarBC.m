function [A, b, err] = addScalarBC(A, b, k, grid, v)
% PURPOSE
% Apply scalar boundary conditions to a linear system for any grid dimension.
%
% DESCRIPTION
% Unified public entry point — accepts only the grid-struct form.
% Validates the grid, then dispatches to the appropriate dimensional
% implementation based on grid.dim. The grid struct must carry
% grid.bc.dc and grid.bc.nc (Dirichlet/Neumann coefficients).
%
% Parameters:
%   A    : Linear operator without boundary conditions added
%   b    : Right-hand-side vector without boundary conditions added
%   k    : Order of accuracy (even integer >= 2)
%   grid : Grid struct produced by makeGrid or validateGrid, with
%          grid.bc.dc and grid.bc.nc set
%   v    : Boundary values: 2×1 column vector (1D); cell array of
%          column vectors (2D: {left,right,bottom,top};
%          3D: {left,right,bottom,top,front,back})
%
% SYNTAX
% [A, b] = addScalarBC(A, b, k, grid, v)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 5 || ~isstruct(grid)
        error('addScalarBC:InvalidSignature', ...
              'addScalarBC(A, b, k, grid, v) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    grid = validateGrid(grid);
    err = grid.error;
    if err.hasError
        return;
    end
    [A, b] = addScalarBC_impl(A, b, k, grid, v);
end
