function I = interpolCentersToFacesD3D(k, m, n, o)
% 3D interpolation from centers to faces
% logical centers are [1 1.5 ... m-0.5 m]x[1 1.5 ... n-0.5 n]x[1 1.5 ... o-0.5 o]
% m, n, o, are the number of cells in the logical x-, y-, z- axes
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    cells = (o+2)*(n+2)*(m+2);

    Ix = interpolCentersToFacesD1D(k, m);
    Iy = interpolCentersToFacesD1D(k, n);
    Iz = interpolCentersToFacesD1D(k, o);

    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
    Io = sparse(o + 2, o);

    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    Io(2:(o+2)-1, :) = speye(o, o);

    Sx = kron(kron(Io', In'), Ix);
    Sy = kron(kron(Io', Iy), Im');
    Sz = kron(kron(Iz, In'), Im');

    I = sparse(o*n*(m+1)+o*(n+1)*m+(o+1)*n*m, 3*cells);
    
    I(1:o*n*(m+1), 1:cells) = Sx; 
    I(o*n*(m+1)+1:o*n*(m+1)+o*(n+1)*m, cells+1:2*cells) = Sy;
    I(o*n*(m+1)+o*(n+1)*m+1:end, 2*cells+1:end) = Sz;
end