function G = grad3DCurv(k, X, Y, Z)
% Returns a 3D curvilinear mimetic gradient
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

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
    
    % Interpolate the metrics on the logical grid for positions u, v and w
    Xl_ = (Xl(1:end-1, :, :)+Xl(2:end, :, :))/2;
    Xl_ = (Xl_(:, :, 1:end-1)+Xl_(:, :, 2:end))/2;
    Yl_ = (Yl(1:end-1, :, :)+Yl(2:end, :, :))/2;
    Yl_ = (Yl_(:, :, 1:end-1)+Yl_(:, :, 2:end))/2;
    Zl_ = (Zl(1:end-1, :, :)+Zl(2:end, :, :))/2;
    Zl_ = (Zl_(:, :, 1:end-1)+Zl_(:, :, 2:end))/2;
    Ju = interp3(Xl, Yl, Zl, J, Xl_, Yl_, Zl_);
    A = interp3(Xl, Yl, Zl, A, Xl_, Yl_, Zl_);
    D = interp3(Xl, Yl, Zl, D, Xl_, Yl_, Zl_);
    G = interp3(Xl, Yl, Zl, G, Xl_, Yl_, Zl_);
    
    Xl_ = (Xl(:, 1:end-1, :)+Xl(:, 2:end, :))/2;
    Xl_ = (Xl_(:, :, 1:end-1)+Xl_(:, :, 2:end))/2;
    Yl_ = (Yl(:, 1:end-1, :)+Yl(:, 2:end, :))/2;
    Yl_ = (Yl_(:, :, 1:end-1)+Yl_(:, :, 2:end))/2;
    Zl_ = (Zl(:, 1:end-1, :)+Zl(:, 2:end, :))/2;
    Zl_ = (Zl_(:, :, 1:end-1)+Zl_(:, :, 2:end))/2;
    Jv = interp3(Xl, Yl, Zl, J, Xl_, Yl_, Zl_);
    B = interp3(Xl, Yl, Zl, B, Xl_, Yl_, Zl_);
    E = interp3(Xl, Yl, Zl, E, Xl_, Yl_, Zl_);
    H = interp3(Xl, Yl, Zl, H, Xl_, Yl_, Zl_);
    
    Xl_ = (Xl(1:end-1, :, :)+Xl(2:end, :, :))/2;
    Xl_ = (Xl_(:, 1:end-1, :)+Xl_(:, 2:end, :))/2;
    Yl_ = (Yl(1:end-1, :, :)+Yl(2:end, :, :))/2;
    Yl_ = (Yl_(:, 1:end-1, :)+Yl_(:, 2:end, :))/2;
    Zl_ = (Zl(1:end-1, :, :)+Zl(2:end, :, :))/2;
    Zl_ = (Zl_(:, 1:end-1, :)+Zl_(:, 2:end, :))/2;
    Jw = interp3(Xl, Yl, Zl, J, Xl_, Yl_, Zl_);
    C = interp3(Xl, Yl, Zl, C, Xl_, Yl_, Zl_);
    F = interp3(Xl, Yl, Zl, F, Xl_, Yl_, Zl_);
    I = interp3(Xl, Yl, Zl, I, Xl_, Yl_, Zl_);
    
    % Convert metrics to diagonal matrices so they can be multiplied by the 
    % logical operators
    Ju = spdiags(1./reshape(permute(Ju, [2, 1, 3]), [], 1), 0, numel(Ju), numel(Ju));
    Jv = spdiags(1./reshape(permute(Jv, [2, 1, 3]), [], 1), 0, numel(Jv), numel(Jv));
    Jw = spdiags(1./reshape(permute(Jw, [2, 1, 3]), [], 1), 0, numel(Jw), numel(Jw));
    A = spdiags(reshape(permute(A, [2, 1, 3]), [], 1), 0, numel(A), numel(A));
    B = spdiags(reshape(permute(B, [2, 1, 3]), [], 1), 0, numel(B), numel(B));
    C = spdiags(reshape(permute(C, [2, 1, 3]), [], 1), 0, numel(C), numel(C));
    D = spdiags(reshape(permute(D, [2, 1, 3]), [], 1), 0, numel(D), numel(D));
    E = spdiags(reshape(permute(E, [2, 1, 3]), [], 1), 0, numel(E), numel(E));
    F = spdiags(reshape(permute(F, [2, 1, 3]), [], 1), 0, numel(F), numel(F));
    G = spdiags(reshape(permute(G, [2, 1, 3]), [], 1), 0, numel(G), numel(G));
    H = spdiags(reshape(permute(H, [2, 1, 3]), [], 1), 0, numel(H), numel(H));
    I = spdiags(reshape(permute(I, [2, 1, 3]), [], 1), 0, numel(I), numel(I));
    
    % Construct 3D uniform mimetic gradient operator (d/de, d/dn, d/dc)
    Grad = grad3D(k, m-1, 1, n-1, 1, o-1, 1);
    Ge = Grad(1:m*(n-1)*(o-1), :);
    Gn = Grad(m*(n-1)*(o-1)+1:m*(n-1)*(o-1)+(m-1)*n*(o-1), :);
    Gc = Grad(m*(n-1)*(o-1)+(m-1)*n*(o-1)+1:end, :);
    
    % Apply transformation
    Gx = Ju*(A*Ge+D*GI13(Gn, m-1, n-1, o-1, 'Gn')+G*GI13(Gc, m-1, n-1, o-1, 'Gc'));
    Gy = Jv*(B*GI13(Ge, m-1, n-1, o-1, 'Ge')+E*Gn+H*GI13(Gc, m-1, n-1, o-1, 'Gcy'));
    Gz = Jw*(C*GI13(Ge, m-1, n-1, o-1, 'Gee')+F*GI13(Gn, m-1, n-1, o-1, 'Gnn')+I*Gc);
    
    % Final 3D curvilinear mimetic gradient operator (d/dx, d/dy, d/dz)
    G = [Gx; Gy; Gz];
end
