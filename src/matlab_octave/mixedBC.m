function BC = mixedBC(k, m, dx, left, coeffs_left, right, coeffs_right)
% Constructs a 1D mimetic mixed boundary conditions operator
%
% Parameters:
%    k            : Order of accuracy
%    m            : Number of cells
%    dx           : Step size
%    left         : Type of boundary condition at the left boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_left  : Coefficients for the left boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
%    right        : Type of boundary condition at the right boundary ('Dirichlet', 'Neumann', 'Robin')
%    coeffs_right : Coefficients for the right boundary condition (a, b for Robin, otherwise coeff. for Dirichlet or Neumann)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    A = sparse(m+2, m+2);
    B = sparse(m+2, m+1);

    switch left
        case 'Dirichlet'
            A(1, 1) = coeffs_left;
        case 'Neumann'
            B(1, 1) = -coeffs_left;
        case 'Robin'
            A(1, 1) = coeffs_left(1);
            B(1, 1) = -coeffs_left(2);
        otherwise
            error('Unknown boundary condition type');
    end
    
    switch right
        case 'Dirichlet'
            A(end, end) = coeffs_right;
        case 'Neumann'
            B(end, end) = coeffs_right;
        case 'Robin'
            A(end, end) = coeffs_right(1);
            B(end, end) = coeffs_right(2);
        otherwise
            error('Unknown boundary condition type');
    end
    
    G = grad(k, m, dx);

    BC = A + B*G;
end
