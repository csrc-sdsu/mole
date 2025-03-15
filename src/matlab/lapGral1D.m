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

function L = lapGral1D(k, m, dx, dc, nc)
% Returns a one-dimensional mimetic Laplacian operator depending on whether
% or not the operator will contain a periodic boundary condition type
%                              a0 U + b0 dU/dn = g,
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells
%               dx : Step size
%               dc : a0 (2x1 vector for left and right vertices, resp.)
%               nc : b0 (2x1 vector for left and right vertices, resp.)

    D = divGral1D(k, m, dx, dc, nc);
    G = gradGral1D(k, m, dx, dc, nc);
    
    L = D*G;
end
