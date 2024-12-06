% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University (SDSU) and Contributors 
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

function N = nodal3D(k, m, dx, n, dy, o, dz)
% Returns a three-dimensional operator that approximates the first-order 
% derivatives on a uniform nodal grid
%
% Parameters:
%                k : Order of accuracy
%                m : Number of nodes along x-axis
%               dx : Step size along x-axis
%                n : Number of nodes along y-axis
%               dy : Step size along y-axis
%                o : Number of nodes along z-axis
%               dz : Step size along z-axis
    
    Nx = nodal(k, m, dx);
    Ny = nodal(k, n, dy);
    Nz = nodal(k, o, dz);
    
    Im = speye(m, m);
    In = speye(n, n);
    Io = speye(o, o);
    
    Sx = kron(kron(Io, In), Nx);
    Sy = kron(kron(Io, Ny), Im);
    Sz = kron(kron(Nz, In), Im);
    
    N = [Sx; Sy; Sz];
end