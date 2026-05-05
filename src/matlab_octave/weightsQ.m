function Q = weightsQ(k, m, dx)
% PURPOSE
% Returns the m+2 weights of Q
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%
% SYNTAX
% Q = weightsQ(k, m, dx)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    D = div(k, m, dx);
    
    b = [-1; zeros(m-1, 1); 1]; % RHS
    
    Q = [1; D(2:end-1, :)'\b; 1];
end
