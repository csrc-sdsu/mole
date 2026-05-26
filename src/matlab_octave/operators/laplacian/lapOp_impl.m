function L = lapOp_impl(grid, k)
% PURPOSE
% Grid-first mimetic Laplacian operator for 1-D, 2-D, and 3-D grids.
%
% DESCRIPTION
% This operator composes the grid-first divergence and gradient operators.
%
% SYNTAX
% L = lapOp_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    D = divOp_impl(grid, k);
    G = gradOp_impl(grid, k);
    L = D * G;
end