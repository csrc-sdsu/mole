function [Nx, Ny, Nz] = nodal3DCurv(k, X, Y, Z)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % Get the determinant of the jacobian and the metrics
    [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z);
    
    % Dimensions of nodal grid
    [n, m, o] = size(X);
    
    len = n*m*o;
    
    % Convert metrics to diagonal matrices
    J = spdiags(1./J, 0, numel(len), numel(len));
    A = spdiags(Yn.*Zc-Zn.*Yc, 0, len, len);
    B = spdiags(Zn.*Xc-Xn.*Zc, 0, len, len);
    C = spdiags(Xn.*Yc-Yn.*Xc, 0, len, len);
    D = spdiags(Ze.*Yc-Ye.*Zc, 0, len, len);
    E = spdiags(Xe.*Zc-Ze.*Xc, 0, len, len);
    F = spdiags(Ye.*Xc-Xe.*Yc, 0, len, len);
    G = spdiags(Ye.*Zn-Ze.*Yn, 0, len, len);
    H = spdiags(Ze.*Xn-Xe.*Zn, 0, len, len);
    I = spdiags(Xe.*Yn-Ye.*Xn, 0, len, len);
    
    % Construct 3D uniform nodal operator
    N = nodal3D(k, m, 1, n, 1, o, 1); % N is tall and skinny
    Ne = N(1:len, :);
    Nn = N(len+1:2*len, :);
    Nc = N(2*len+1:end, :);
    
    % Apply transformation
    Nx = J*(A*Ne+D*Nn+G*Nc);
    Ny = J*(B*Ne+E*Nn+H*Nc);
    Nz = J*(C*Ne+F*Nn+I*Nc);
    
    %  [J*A J*D J*G;
    %   J*B J*E J*H;
    %   J*C J*F J*I]*[Ne; Nn; Nc]
end
