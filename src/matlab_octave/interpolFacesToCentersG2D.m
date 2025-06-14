function I = interpolFacesToCentersG2D(k, m, n)
% 2D interpolation from faces to centers
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]
% m, n, are the number of cells in the logical x- and y- axes
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Ix = interpolFacesToCentersG1D(k, m);
    Iy = interpolFacesToCentersG1D(k, n);

    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);

    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);

    Sx = kron(In, Ix);
    Sy = kron(Iy, Im);

    I = sparse(2*(n+2)*(m+2), n*(m+1)+(n+1)*m);
    
    I(1:(n+2)*(m+2), 1:n*(m+1)) = Sx; 
    I((n+2)*(m+2)+1:end, n*(m+1)+1:end) = Sy;  
end