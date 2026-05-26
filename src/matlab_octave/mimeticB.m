function B = mimeticB(k, m)
% PURPOSE
% Returns a m+2 by m+1 one-dimensional mimetic boundary operator
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%             grid : Struct carrying at least grid.m and optional grid.dx.
%
% SYNTAX
% B = mimeticB(grid, k)
% B = mimeticB(k, m)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    dx = 1;
    if nargin == 2 && isstruct(k)
        grid = k;
        k = m;
        m = grid.m;
        if isfield(grid, 'dx')
            dx = grid.dx;
        end
    end

    Q = sparse(diag(weightsQ(k, m, dx)));
    D = div(k, m, dx);
    G = grad(k, m, dx);
    P = sparse(diag(weightsP(k, m, dx)));
    
    B = Q*D + G'*P;
end
