function D = div3DNonUniform(k, xticks, yticks, zticks)
% Returns a three-dimensional non-uniform mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                xticks : Edges' ticks (x-axis)
%                yticks : Edges' ticks (y-axis)
%                zticks : Edges' ticks (z-axis)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Dx = divNonUniform(k, xticks);
    Dy = divNonUniform(k, yticks);
    Dz = divNonUniform(k, zticks);
    
    m = size(Dx, 1) - 2;
    n = size(Dy, 1) - 2;
    o = size(Dz, 1) - 2;
    
    Im = sparse(m + 2, m);
    Im(2:(m + 2) - 1, :) = speye(m, m);
    
    In = sparse(n + 2, n);
    In(2:(n + 2) - 1, :) = speye(n, n);
    
    Io = sparse(o + 2, o);
    Io(2:(o + 2) - 1, :) = speye(o, o);
    
    Sx = kron(kron(Io, In), Dx);
    Sy = kron(kron(Io, Dy), Im);
    Sz = kron(kron(Dz, In), Im);
    
    D = [Sx Sy Sz];
end
