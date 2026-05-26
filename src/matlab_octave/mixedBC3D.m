function BC = mixedBC3D(k, m, dx, n, dy, o, dz, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top, front, coeffs_front, back, coeffs_back)
% PURPOSE
% Constructs a 3D mimetic mixed boundary conditions operator
%
% DESCRIPTION
% Parameters:
%    k               : Order of accuracy
%    m               : Number of cells in x-direction
%    dx              : Step size in x-direction
%    n               : Number of cells in y-direction
%    dy              : Step size in y-direction
%    o               : Number of cells in z-direction
%    dz              : Step size in z-direction
%    left            : Type of boundary condition at the left boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_left     : Coefficients for the left boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    right           : Type of boundary condition at the right boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_right    : Coefficients for the right boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    bottom          : Type of boundary condition at the bottom boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_bottom   : Coefficients for the bottom boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    top             : Type of boundary condition at the top boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_top      : Coefficients for the top boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    front           : Type of boundary condition at the front boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_front    : Coefficients for the front boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    back            : Type of boundary condition at the back boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_back     : Coefficients for the back boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    grid            : Struct carrying at least grid.m, grid.n, grid.o,
%                      grid.dx, grid.dy, and grid.dz.
%
% SYNTAX
% BC = mixedBC3D(grid, k, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top, front, coeffs_front, back, coeffs_back)
% BC = mixedBC3D(k, m, dx, n, dy, o, dz, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top, front, coeffs_front, back, coeffs_back)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin == 14 && isstruct(k)
        grid = k;
        k = m;
        m = grid.m;
        dx = grid.dx;
        n = grid.n;
        dy = grid.dy;
        o = grid.o;
        dz = grid.dz;
    end

    deprecatedBoundaryWrapperWarning('mixedBC3D', 'addScalarBC3D');

    ensureMatlabOctaveSubdirs();
    BC = mixedBC3D_impl(k, m, dx, n, dy, o, dz, left, coeffs_left, right, coeffs_right, bottom, coeffs_bottom, top, coeffs_top, front, coeffs_front, back, coeffs_back);
end
