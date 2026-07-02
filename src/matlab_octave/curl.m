function C = curl(grid, k)
% PURPOSE
% Returns the mimetic 2-D curl operator for a uniform grid.
%
% DESCRIPTION
% Public entry point — accepts only the grid-struct form. Validates the
% grid and delegates to curlOp_impl. The returned matrix has three row
% blocks: x-component (n*(m+1) rows), y-component ((n+1)*m rows), and
% scalar z-curl (n*m rows).
%
% Parameters:
%   C    : Sparse matrix — 2-D mimetic curl
%   grid : Grid struct produced by makeGrid or validateGrid (must be dim=2)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% C = curl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 2 || ~isstruct(grid)
        error('curl:InvalidSignature', ...
              'curl(grid, k) is the only supported signature');
    end

    ensureMatlabOctaveSubdirs();
    C = curlOp_impl(grid, k);
end
