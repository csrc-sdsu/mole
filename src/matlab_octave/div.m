function [D, err] = div(varargin)
% PURPOSE
% Mimetic divergence operator — 1-D, 2-D, and 3-D, uniform and curvilinear.
%
% DESCRIPTION
% Public entry point for the grid-struct API. Validates the grid and
% dispatches to divOp_impl, which handles uniform, periodic, and
% curvilinear grids across all dimensions.
%
% Parameters:
%   D    : Sparse matrix — mimetic divergence operator
%   grid : Grid struct produced by makeGrid or validateGrid
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% D = div(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if numel(varargin) ~= 2 || ~isstruct(varargin{1})
        error('div:InvalidSignature', ...
              'div(grid, k) is the only supported signature');
    end

    grid = varargin{1};
    k    = varargin{2};
    ensureMatlabOctaveSubdirs();
    [D, err] = divOp_impl(grid, k);
end
