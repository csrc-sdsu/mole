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

function BC = robinBC(k, m, dx, a, b)
% Returns a m+2 by m+2 one-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient

    A = sparse(m+2, m+2);
    A(1, 1) = a;
    A(end, end) = a;
    
    B = sparse(m+2, m+1);
    B(1, 1) = -b;
    B(end, end) = b;
    
    G = grad(k, m, dx);
    
    BC = A + B*G;
end
