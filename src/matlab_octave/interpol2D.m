function I = interpol2D(m, n, c1, c2)
% Returns a two-dimensional interpolator of 2nd-order
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%               c1 : Left interpolation coeff.
%               c2 : Bottom interpolation coeff.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Ix = interpol(m, c1);
    Iy = interpol(n, c2);
    
    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
    
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    
    Sx = kron(In', Ix);
    Sy = kron(Iy, Im');
    
    I = [Sx; Sy];
end
