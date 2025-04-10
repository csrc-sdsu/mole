function I = interpolFacesToCentersG3DPeriodic(k, m, n, o)
% 3D interpolation from faces to centers
% when the boundary condition is periodic
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]x[1,1.5:o-0.5,o]
% m, n, o, are the number of cells in the logical x-, y-, z- axes
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    cells = o*n*m;

    Ix = interpolFacesToCentersG1DPeriodic(k, m);
    Iy = interpolFacesToCentersG1DPeriodic(k, n);
    Iz = interpolFacesToCentersG1DPeriodic(k, o);

    Im = speye(m, m);
    In = speye(n, n);
    Io = speye(o, o);

    Sx = kron(kron(Io, In), Ix);
    Sy = kron(kron(Io, Iy), Im);
    Sz = kron(kron(Iz, In), Im);

    I = sparse(3*cells, 3*cells);
    
    I(1:cells, 1:cells) = Sx; 
    I(cells+1:2*cells, cells+1:2*cells) = Sy;  
    I(2*cells+1:end, 2*cells+1:end) = Sz;
end