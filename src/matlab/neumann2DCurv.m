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

function N = neumann2DCurv(G, m, n, b)
% Returns a 2D curvilinear Neumann BC operator

    % G is the curvilinear gradient and b is the Neumann coeff.

    Bm = sparse(m+2, m+1);
    Bm(1, 1) = -b;
    Bm(end, end) = b;
   
    Bn = sparse(n+2, n+1);
    Bn(1, 1) = -b;
    Bn(end, end) = b;
   
    Im = sparse(m + 2, m);
    In = sparse(n + 2, n);
   
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
   
    Bm = kron(In, Bm);
    Bn = kron(Bn, Im);
    
    N = [Bm Bn]*G;
    
    N(1, :) = [N(2, 2:end) 0];
    N(m+2, :) = [0 N(m+1, 1:end-1)];
    N(end-m-1, :) = [N(end-m, 2:end) 0];
    N(end, :) = [0 N(end-1, 1:end-1)];
end
