function I = interpolCentersToFacesD2D(k, m, n)
% PURPOSE
% 2D interpolation from centers to faces. 
% logical centers are [1 1.5 2.5 ... m-1.5 m-0.5 m]x[1 1.5 2.5 ... n-1.5 n-0.5 n]
%
% DESCRIPTION
% Parameters:
%                   m: Number of cells in the logic x-axis
%                   n: Number of cells in the logic y-axis
%
% SYNTAX
% I = interpolCentersToFacesD2D(k, m, n)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Ix = interpolCentersToFacesD1D(k, m);
    Iy = interpolCentersToFacesD1D(k, n);

    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);

    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);

    Sx = kron(In', Ix);
    Sy = kron(Iy, Im');

    I = sparse(n*(m+1)+(n+1)*m, 2*(n+2)*(m+2));
    
    I(1:n*(m+1), 1:(n+2)*(m+2)) = Sx; 
    I(n*(m+1)+1:end, (n+2)*(m+2)+1:end) = Sy;  
end