function P = weightsP(k, m, dx)
% PURPOSE
% Returns the m+1 weights of P
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%
% SYNTAX
% P = weightsP(k, m, dx)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    G = grad(k, m, dx);
    
    b = [-1; zeros(m, 1); 1]; % RHS
    
    P = G'\b;
end
