function [I, err] = interpol(grid, direction)
% PURPOSE
% Returns an interpolation operator for the specified transfer direction.
%
% DESCRIPTION
% Unified public entry point — accepts only the grid-struct form. Validates
% the grid and dispatches to interpol_impl, which routes to the correct
% dimensional transfer implementation based on grid.dim and direction.
%
% Parameters:
%   I         : Sparse matrix — interpolation operator
%   grid      : Grid struct produced by makeGrid or validateGrid
%   direction : Transfer direction string — one of:
%               'CentersToFaces'  — interior cell centers to face centers
%               'FacesToCenters'  — face centers to cell centers
%               'NodesToCenters'  — corner nodes to cell centers
%               'CentersToNodes'  — cell centers to corner nodes
%
% SYNTAX
% I = interpol(grid, direction)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid) || ~(ischar(direction) || isstring(direction))
        error('interpol:InvalidSignature', ...
              'interpol(grid, direction) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    grid = validateGrid(grid);
    err = grid.error;
    if err.hasError
        I = [];
        return;
    end
    I = interpol_impl(grid, direction);
end
