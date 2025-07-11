function I = interpolFacesToCentersG2DPeriodic(k, m, n)
% 2D interpolation from faces to centers
% when the boundary condition is periodic
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]
% m, n, are the number of cells in the logical x- and y- axes
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    Ix = interpolFacesToCentersG1DPeriodic(k, m);
    Iy = interpolFacesToCentersG1DPeriodic(k, n);

    Im = speye(m, m);
    In = speye(n, n);

    Sx = kron(In, Ix);
    Sy = kron(Iy, Im);

    I = sparse(2*n*m, 2*n*m);
    
    I(1:n*m, 1:n*m) = Sx; 
    I(n*m+1:end, n*m+1:end) = Sy;  
end