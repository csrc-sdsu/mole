function N = neumann2DCurv(G, m, n, b)
% Returns a 2D curvilinear Neumann BC operator

    % G is the curvilinear gradient and b is the Neumann coeff.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

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
