function L = lap(varargin)
% PURPOSE
% Mimetic Laplacian operator — 1-D, 2-D, and 3-D, uniform and curvilinear.
%
% DESCRIPTION
% Public entry point for the grid-struct API. Composes div*grad via
% lapOp_impl, which inherits curvilinear support from the individual
% operator impls.
%
% Parameters:
%   L    : Sparse matrix — mimetic Laplacian operator
%   grid : Grid struct produced by makeGrid or validateGrid
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% L = lap(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if numel(varargin) ~= 2 || ~isstruct(varargin{1})
        error('lap:InvalidSignature', ...
              'lap(grid, k) is the only supported signature');
    end

    grid = varargin{1};
    k    = varargin{2};
    ensureMatlabOctaveSubdirs();
    L = lapOp_impl(grid, k);
end
