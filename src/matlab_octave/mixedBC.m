function BC = mixedBC(k, m, dx, left, coeffs_left, right, coeffs_right)
% PURPOSE
% Constructs a 1D mimetic mixed boundary conditions operator
%
% DESCRIPTION
% Parameters:
%    k            : Order of accuracy
%    m            : Number of cells
%    dx           : Step size
%    left         : Type of boundary condition at the left boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_left  : Coefficients for the left boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    right        : Type of boundary condition at the right boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_right : Coefficients for the right boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    grid         : Struct carrying at least grid.m and grid.dx.
%
% SYNTAX
% BC = mixedBC(grid, k, left, coeffs_left, right, coeffs_right)
% BC = mixedBC(k, m, dx, left, coeffs_left, right, coeffs_right)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin == 6 && isstruct(k)
        grid = k;
        k = m;
        m = grid.m;
        dx = grid.dx;
    end

    deprecatedBoundaryWrapperWarning('mixedBC', 'addScalarBC1D');

    ensureMatlabOctaveSubdirs();
    BC = mixedBC_impl(k, m, dx, left, coeffs_left, right, coeffs_right);
end
