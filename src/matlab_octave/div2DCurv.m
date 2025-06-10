function D = div2DCurv(k, X, Y)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

% Returns a 2D curvilinear mimetic divergence

    % Get the determinant of the jacobian and the metrics
    [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y);
    
    % Dimensions of nodal grid
    [n, m] = size(X);
    
    % Make them surfaces so they can be interpolated
    J = reshape(J, m, n)';
    Xe = reshape(Xe, m, n)';
    Xn = reshape(Xn, m, n)';
    Ye = reshape(Ye, m, n)';
    Yn = reshape(Yn, m, n)';
    
    % Logical grids
    [Xl, Yl] = meshgrid(1:m, 1:n);
    % Staggered logical grid
    [Xs, Ys] = meshgrid([1 1.5 : 1 : m-0.5 m], [1 1.5 : 1 : n-0.5 n]);
    
    % Interpolate the metrics on the logical grid for positions (Xs, Ys)
    J = interp2(Xl, Yl, J, Xs, Ys);
    Xe = interp2(Xl, Yl, Xe, Xs, Ys);
    Xn = interp2(Xl, Yl, Xn, Xs, Ys);
    Ye = interp2(Xl, Yl, Ye, Xs, Ys);
    Yn = interp2(Xl, Yl, Yn, Xs, Ys);
    
    % Convert metrics to diagonal matrices so they can be multiplied by the 
    % logical operators
    J = spdiags(1./reshape(J', [], 1), 0, numel(J), numel(J));
    Xe = spdiags(reshape(Xe', [], 1), 0, numel(Xe), numel(Xe));
    Xn = spdiags(reshape(Xn', [], 1), 0, numel(Xn), numel(Xn));
    Ye = spdiags(reshape(Ye', [], 1), 0, numel(Ye), numel(Ye));
    Yn = spdiags(reshape(Yn', [], 1), 0, numel(Yn), numel(Yn));
    
    % Construct 2D uniform mimetic divergence operator (d/de, d/dn)
    D = div2D(k, m-1, 1, n-1, 1);
    De = D(:, 1:m*(n-1));
    Dn = D(:, m*(n-1)+1:end);
    
    % Apply transformation
    Dx = J*(Yn*De-Ye*DI2(m-1, n-1, 'Dn'));
    Dy = J*(-Xn*DI2(m-1, n-1, 'De')+Xe*Dn);
    
    % Final 2D curvilinear mimetic divergence operator (d/dx, d/dy)
    D = [Dx Dy];
end
