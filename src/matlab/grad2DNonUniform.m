function G = grad2DNonUniform(k, xticks, yticks)
% Returns a two-dimensional non-uniform mimetic gradient operator
%
% Parameters:
%                k : Order of accuracy
%                xticks : Centers' ticks (x-axis)
%                yticks : Centers' ticks (y-axis)
%                         (including the boundaries!)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Gx = gradNonUniform(k, xticks);
    Gy = gradNonUniform(k, yticks);
    
    m = size(Gx, 1) - 1;
    n = size(Gy, 1) - 1;
    
    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
    
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    
    Sx = kron(In', Gx);
    Sy = kron(Gy, Im');
    
    G = [Sx; Sy];
end
