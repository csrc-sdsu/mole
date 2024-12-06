% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University (SDSU) and Contributors 
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

function G = grad2DNonUniform(k, xticks, yticks)
% Returns a two-dimensional non-uniform mimetic gradient operator
%
% Parameters:
%                k : Order of accuracy
%                xticks : Centers' ticks (x-axis)
%                yticks : Centers' ticks (y-axis)
%                         (including the boundaries!)

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
