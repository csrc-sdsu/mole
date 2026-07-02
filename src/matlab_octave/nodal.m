function N = nodal(varargin)
% PURPOSE
% Mimetic nodal derivative operator — 1-D, 2-D, and 3-D.
%
% DESCRIPTION
% Public entry point for the grid-struct API. Validates the grid and
% dispatches to nodalOp_impl, which handles uniform and curvilinear grids.
%
% The legacy 3-argument form nodal(k, m, dx) where m is the node count
% is retained for backwards compatibility with internal callers (nodal2D)
% and will be removed in Plan 3 when nodal2D.m is deleted.
%
% Parameters:
%   N    : Sparse matrix — mimetic nodal derivative operator
%   grid : Grid struct produced by makeGrid or validateGrid
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% N = nodal(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if numel(varargin) == 2 && isstruct(varargin{1})
        grid = varargin{1};
        k    = varargin{2};
        ensureMatlabOctaveSubdirs();
        N = nodalOp_impl(grid, k);
        return;
    end

    if numel(varargin) == 3 && ~isstruct(varargin{1})
        % Legacy internal form: nodal(k, m_nodes, dx)
        % Called by nodal2D which receives node counts from jacobian2D.
        % Route through a synthetic 1D grid (m_cells = m_nodes - 1).
        k  = varargin{1};
        m_nodes = varargin{2};
        dx = varargin{3};
        grid = makeGrid('m', m_nodes - 1, 'dx', dx);
        ensureMatlabOctaveSubdirs();
        N = nodalOp_impl(grid, k);
        return;
    end

    error('nodal:InvalidSignature', ...
          'nodal(grid, k) is the only supported public signature');
end
