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

function BC = mixedBC2D(k, m, dx, n, dy, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top)
% Constructs a 2D mimetic mixed boundary conditions operator
%
% Parameters:
%    k             : Order of accuracy
%    m             : Number of cells in x-direction
%    dx            : Step size in x-direction
%    n             : Number of cells in y-direction
%    dy            : Step size in y-direction
%    left          : Type of boundary condition at the left boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_left   : Coefficients for the left boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    right         : Type of boundary condition at the right boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_right  : Coefficients for the right boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    bottom        : Type of boundary condition at the bottom boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_bottom : Coefficients for the bottom boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    top           : Type of boundary condition at the top boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_top    : Coefficients for the top boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)

    % 1-D boundary operators
    Bm = mixedBC(k, m, dx, left, coeffs_left, right, coeffs_right);
    Bn = mixedBC(k, n, dy, bottom, coeffs_bottom, top, coeffs_top);
    
    Im = speye(m+2);
    
    In = speye(n+2);
    In(1, 1) = 0;
    In(end, end) = 0;
    
    BC1 = kron(In, Bm);
    BC2 = kron(Bn, Im);
    
    BC = BC1 + BC2;
end
