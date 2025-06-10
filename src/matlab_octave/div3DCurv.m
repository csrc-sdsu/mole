function D = div3DCurv(k, X, Y, Z)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
% Returns a 3D curvilinear mimetic divergence

    % Get the determinant of the jacobian and the metrics
    [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z);
    
    % Dimensions of nodal grid
    [n, m, o] = size(X);
    
    % Make them volumes so they can be interpolated
    J = permute(reshape(J, m, n, o), [2, 1, 3]);
    A = permute(reshape(Yn.*Zc-Zn.*Yc, m, n, o), [2, 1, 3]);
    B = permute(reshape(Zn.*Xc-Xn.*Zc, m, n, o), [2, 1, 3]);
    C = permute(reshape(Xn.*Yc-Yn.*Xc, m, n, o), [2, 1, 3]);
    D = permute(reshape(Ze.*Yc-Ye.*Zc, m, n, o), [2, 1, 3]);
    E = permute(reshape(Xe.*Zc-Ze.*Xc, m, n, o), [2, 1, 3]);
    F = permute(reshape(Ye.*Xc-Xe.*Yc, m, n, o), [2, 1, 3]);
    G = permute(reshape(Ye.*Zn-Ze.*Yn, m, n, o), [2, 1, 3]);
    H = permute(reshape(Ze.*Xn-Xe.*Zn, m, n, o), [2, 1, 3]);
    I = permute(reshape(Xe.*Yn-Ye.*Xn, m, n, o), [2, 1, 3]);
    
    % Logical grids
    [Xl, Yl, Zl] = meshgrid(1:m, 1:n, 1:o);
    % Staggered logical grid
    [Xs, Ys, Zs] = meshgrid([1 1.5 : 1 : m-0.5 m], [1 1.5 : 1 : n-0.5 n], [1 1.5 : 1 : o-0.5 o]);
    
    % Interpolate the metrics on the logical grid for positions (Xs, Ys, Zs)
    J = interp3(Xl, Yl, Zl, J, Xs, Ys, Zs);
    A = interp3(Xl, Yl, Zl, A, Xs, Ys, Zs);
    B = interp3(Xl, Yl, Zl, B, Xs, Ys, Zs);
    C = interp3(Xl, Yl, Zl, C, Xs, Ys, Zs);
    D = interp3(Xl, Yl, Zl, D, Xs, Ys, Zs);
    E = interp3(Xl, Yl, Zl, E, Xs, Ys, Zs);
    F = interp3(Xl, Yl, Zl, F, Xs, Ys, Zs);
    G = interp3(Xl, Yl, Zl, G, Xs, Ys, Zs);
    H = interp3(Xl, Yl, Zl, H, Xs, Ys, Zs);
    I = interp3(Xl, Yl, Zl, I, Xs, Ys, Zs);
    
    % Convert metrics to diagonal matrices so they can be multiplied by the 
    % logical operators
    J = spdiags(1./reshape(permute(J, [2, 1, 3]), [], 1), 0, numel(J), numel(J));
    A = spdiags(reshape(permute(A, [2, 1, 3]), [], 1), 0, numel(A), numel(A));
    B = spdiags(reshape(permute(B, [2, 1, 3]), [], 1), 0, numel(B), numel(B));
    C = spdiags(reshape(permute(C, [2, 1, 3]), [], 1), 0, numel(C), numel(C));
    D = spdiags(reshape(permute(D, [2, 1, 3]), [], 1), 0, numel(D), numel(D));
    E = spdiags(reshape(permute(E, [2, 1, 3]), [], 1), 0, numel(E), numel(E));
    F = spdiags(reshape(permute(F, [2, 1, 3]), [], 1), 0, numel(F), numel(F));
    G = spdiags(reshape(permute(G, [2, 1, 3]), [], 1), 0, numel(G), numel(G));
    H = spdiags(reshape(permute(H, [2, 1, 3]), [], 1), 0, numel(H), numel(H));
    I = spdiags(reshape(permute(I, [2, 1, 3]), [], 1), 0, numel(I), numel(I));
    
    % Construct 3D uniform mimetic divergence operator (d/de + d/dn + d/dc)
    Div = div3D(k, m-1, 1, n-1, 1, o-1, 1);
    De = Div(:, 1:m*(n-1)*(o-1));
    Dn = Div(:, m*(n-1)*(o-1)+1:m*(n-1)*(o-1)+(m-1)*n*(o-1));
    Dc = Div(:, m*(n-1)*(o-1)+(m-1)*n*(o-1)+1:end);
    
    % Apply transformation
    Dx = J*(A*De+D*DI3(m-1, n-1, o-1, 'Dn')+G*DI3(m-1, n-1, o-1, 'Dc'));
    Dy = J*(B*DI3(m-1, n-1, o-1, 'De')+E*Dn+H*DI3(m-1, n-1, o-1, 'Dcc'));
    Dz = J*(C*DI3(m-1, n-1, o-1, 'Dee')+F*DI3(m-1, n-1, o-1, 'Dnn')+I*Dc);
    
    % Final 3D curvilinear mimetic divergence operator (d/dx + d/dy + d/dz)
    D = [Dx Dy Dz];
end
