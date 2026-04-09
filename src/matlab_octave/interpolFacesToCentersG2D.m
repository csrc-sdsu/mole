function I = interpolFacesToCentersG2D(k, m, n, dc, nc)
% 2D interpolation from faces to centers
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]
% m, n, are the number of cells in the logical x- and y- axes
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 3 && nargin ~= 5
        error("interpolFacesToCentersG2D:InvalidNumArgs",...
              "interpolFacesToCentersG2D expects 3 or 5 arguments")
    elseif nargin == 3
        dc = [1; 1; 1; 1];
        nc = [0; 0; 0; 0];
    else
        assert(all(size(dc) == [4 1]), "dc is a 4x1 vector")
        assert(all(size(nc) == [4 1]), "nc is a 4x1 vector")
    end

    if isempty(find(dc(1:2).^2 + nc(1:2).^2, 1))
        Ix = interpolFacesToCentersG1DPeriodic(k,m);
        Im = speye(m);
    else
        Ix = interpolFacesToCentersG1D(k,m);
        Im = sparse(m+2,m); Im(2:end-1,:) = speye(m);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2, 1))
        Iy = interpolFacesToCentersG1DPeriodic(k,n);
        In = speye(n);
    else
        Iy = interpolFacesToCentersG1D(k,n);
        In = sparse(n+2,n); In(2:end-1,:) = speye(n);
    end

    Sx = kron(In, Ix);
    Sy = kron(Iy, Im);

    I = sparse(size(Sx,1)+size(Sy,1), size(Sx,2)+size(Sy,2));
    
    I(1:size(Sx,1), 1:size(Sx,2)) = Sx; 
    I(size(Sx,1)+1:end, size(Sx,2)+1:end) = Sy;
end