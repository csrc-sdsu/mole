function I = interpolCentersToFacesD3D(k, m, n, o, dc, nc)
% 3D interpolation from centers to faces
% logical centers are [1 1.5 ... m-0.5 m]x[1 1.5 ... n-0.5 n]x[1 1.5 ... o-0.5 o]
% m, n, o, are the number of cells in the logical x-, y-, z- axes
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 4 && nargin ~= 6
        error("interpolCentersToFacesD3D:InvalidNumArgs",...
              "interpolCentersToFacesD3D expects 4 or 6 arguments");
    elseif nargin == 4
        % Just set some non periodic coefficients
        dc = [1 1 1 1 1 1];
        nc = [0 0 0 0 0 0];
    else
        assert(all(size(dc) == [6 1]), "dc is a 6x1 vector")
        assert(all(size(nc) == [6 1]), "nc is a 6x1 vector")
    end

    if isempty(find(dc(1:2).^2 + nc(1:2).^2, 1))
        Ix = interpolCentersToFacesD1DPeriodic(k,m);
        Im = speye(m);
    else
        Ix = interpolCentersToFacesD1D(k,m);
        Im = sparse(m+2,m); Im(2:end-1,:) = speye(m);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2, 1))
        Iy = interpolCentersToFacesD1DPeriodic(k,n);
        In = speye(n);
    else
        Iy = interpolCentersToFacesD1D(k,n);
        In = sparse(n+2,n); In(2:end-1,:) = speye(n);
    end
    if isempty(find(dc(5:6).^2 + nc(5:6).^2, 1))
        Iz = interpolCentersToFacesD1DPeriodic(k,o);
        Io = speye(o);
    else
        Iz = interpolCentersToFacesD1D(k,o);
        Io = sparse(o+2,o); Io(2:end-1,:) = speye(o);
    end

    Sx = kron(kron(Io', In'), Ix);
    Sy = kron(kron(Io', Iy), Im');
    Sz = kron(kron(Iz, In'), Im');

    I = sparse(size(Sx,1)+size(Sy,1)+size(Sz,1),...
               size(Sx,2)+size(Sy,2)+size(Sz,2));
    
    I(1:size(Sx,1), 1:size(Sx,2)) = Sx; 
    I(size(Sx,1)+1:size(Sx,1)+size(Sy,1), size(Sx,2)+1:size(Sx,2)+size(Sy,2)) = Sy;
    I(size(Sx,1)+size(Sy,1)+1:end, size(Sx,2)+size(Sy,2)+1:end) = Sz;
end