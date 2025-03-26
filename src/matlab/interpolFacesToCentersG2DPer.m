% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University Research Foundation (SDSURF). 
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------

function I = interpolFacesToCentersG2DPer(k, m, n)
% 2D interpolation from faces to centers
% when the boundary condition is periodic
% centers logical coordinates [1,1.5:m-0.5,m]x[1,1.5:n-0.5,n]
% m, n, are the number of cells in the logical x- and y- axes

    Ix = interpolFacesToCentersG1DPer(k, m);
    Iy = interpolFacesToCentersG1DPer(k, n);

    Im = speye(m, m);
    In = speye(n, n);

    Sx = kron(In, Ix);
    Sy = kron(Iy, Im);

    I = sparse(2*n*m, 2*n*m);
    
    I(1:n*m, 1:n*m) = Sx; 
    I(n*m+1:end, n*m+1:end) = Sy;  
end