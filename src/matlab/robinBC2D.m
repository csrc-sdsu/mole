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

function BC = robinBC2D(k, m, dx, n, dy, a, b)
% Returns a two-dimensional mimetic boundary operator that 
% imposes a boundary condition of Robin's type
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis
%                a : Dirichlet Coefficient
%                b : Neumann Coefficient

    % 1-D boundary operator
    Bm = robinBC(k, m, dx, a, b);
    Bn = robinBC(k, n, dy, a, b);
    
    Im = speye(m+2);
    
    In = speye(n+2);
    In(1, 1) = 0;
    In(end, end) = 0;
    
    BC1 = kron(In, Bm);
    BC2 = kron(Bn, Im);
    
    BC = BC1 + BC2;
end
