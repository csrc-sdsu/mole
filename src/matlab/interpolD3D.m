function I = interpolD3D(m, n, o, c1, c2, c3)
% Returns a three-dimensional interpolator of 2nd-order
%                m : Number of cells along x-axis
%                n : Number of cells along y-axis
%                o : Number of cells along z-axis
%               c1 : Left interpolation coeff.
%               c2 : Bottom interpolation coeff.
%               c3 : Front interpolation coeff.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    Im = sparse(m + 2, m);
    Im(2:(m + 2) - 1, :) = speye(m, m);
    
    Ix = interpolD(m, c1);
    
    In = sparse(n + 2, n);
    In(2:(n + 2) - 1, :) = speye(n, n);
    
    Iy = interpolD(n, c2);
    
    Io = sparse(o + 2, o);
    Io(2:(o + 2) - 1, :) = speye(o, o);
    
    Iz = interpolD(o, c3);
    
    Sx = kron(kron(Io, In), Ix);
    Sy = kron(kron(Io, Iy), Im);
    Sz = kron(kron(Iz, In), Im);
    
    I = [Sx Sy Sz];
end
