function N = neumann3DCurv(G, m, n, o, b)
% Returns a 3D curvilinear Neumann BC operator

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
    
    Bo = sparse(o+2, o+1);
    Bo(1, 1) = -b;
    Bo(end, end) = b;
    
    Im = sparse(m+2, m);
    In = sparse(n+2, n);
    Io = sparse(o+2, o);
    
    Im(2:(m+2)-1, :) = speye(m, m);
    In(2:(n+2)-1, :) = speye(n, n);
    Io(2:(o+2)-1, :) = speye(o, o);
    
    Bm = kron(kron(Io, In), Bm);
    Bn = kron(kron(Io, Bn), Im);
    Bo = kron(kron(Bo, In), Im);
    
    N = [Bm Bn Bo]*G;
    
    N(1, :) = [N(m+4, m+4:end) zeros(1, m+3)];
    
    N(2:m+1, :) = circshift(N(m+4:m+4+m-1, :), -m-2, 2);
    
    N(m+2, :) = [0 N(m+1, 1:end-1)];
    
    i = m+3;
    for j = 1 : n
        N(i, :) = [N(i+1, 2:end) 0];
        N(i+m+1, :) = [0 N(i+m, 1:end-1)];
        i = i+m+2;
    end
    
    N(i, :) = [zeros(1, m+1) N(i-m-1, 1:end-m-1)];
    
    N(i+1:i+m, :) = circshift(N(i-m-1:i-2, :), m+2, 2);
    
    N(i+m+1, :) = [0 N(i+m, 1:end-1)];
    
    i = i+m+2;
    for j = 1 : o
        N(i, :) = [N(i+1, 2:end) 0];
        N(i+m+1, :) = [0 N(i+m, 1:end-1)];
        N(i+(n+1)*(m+2), :) = [N(i+(n+1)*(m+2)+1, 2:end) 0];
        N(i+(n+1)*(m+2)+m+1, :) = [0 N(i+(n+1)*(m+2)+m, 1:end-1)];
        i = i+(m+2)*(n+2);
    end
    
    N(end, :) = [zeros(1, m+3) N(end-m-3, 1:end-m-3)];
    
    N(end-m-1, :) = [zeros(1, m+1) N(end-2*(m+1), 1:end-m-1)];
    
    i = (m+2)*(n+2)*(o+1)+1;
    N(i, :) = [N(i+m+3, m+4:end) zeros(1, m+3)];
    
    i = i+m+1;
    N(i, :) = [N(i+m+1, m+2:end) zeros(1, m+1)];
    
    i = i+1;
    for j = 1 : n
        N(i, :) = [N(i+1, 2:end) 0];
        N(i+m+1, :) = [0 N(i+m, 1:end-1)];
        i = i+m+2;
    end
    
    i = (m+2)*(n+2)*(o+1)+2;
    N(i:i+m-1, :) = circshift(N(i+m+2:i+m+2+m-1, :), -m-2, 2);
    
    i = (m+2)*(n+2)*(o+2)-m;
    N(i:i+m-1, :) = circshift(N(i-m-2:i-3, :), m+2, 2);
end
