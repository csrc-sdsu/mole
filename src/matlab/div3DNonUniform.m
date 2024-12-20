% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University Research Foundation (SDSURF).
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------

function D = div3DNonUniform(k, xticks, yticks, zticks)
% Returns a three-dimensional non-uniform mimetic divergence operator
%
% Parameters:
%                k : Order of accuracy
%                xticks : Edges' ticks (x-axis)
%                yticks : Edges' ticks (y-axis)
%                zticks : Edges' ticks (z-axis)

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
