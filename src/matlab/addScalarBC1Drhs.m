function b = addScalarBC1Drhs(b, v, vec)
% This function uses the non-periodic boundary condition type of each vertex 
% and the rhs b values associated to left, and right vertices to modify the rhs vector b.
%
% Parameters:
% output
%         b : Right hand side with boundary conditions added
%
% input
%         b : Right hand side without boundary conditions added
%         v : value (2x1 vector for left and right vertices, resp.)
%       vec : vector with indices of rhs associated to bc
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    % rhs for non-periodic boundary conditions
    b(vec) = v; 
end
