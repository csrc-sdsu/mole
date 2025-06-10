function G = grad2DCurv(k, X, Y)
% Returns a 2D curvilinear mimetic gradient
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
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
    
    % Interpolate the metrics on the logical grid for positions u and v
    Ju = interp2(Xl, Yl, J, (Xl(1:end-1, :)+Xl(2:end, :))/2,...
                                            (Yl(1:end-1, :)+Yl(2:end, :))/2);
    Jv = interp2(Xl, Yl, J, (Xl(:, 1:end-1)+Xl(:, 2:end))/2,...
                                            (Yl(:, 1:end-1)+Yl(:, 2:end))/2);
    Xev = interp2(Xl, Yl, Xe, (Xl(:, 1:end-1)+Xl(:, 2:end))/2,...
                                            (Yl(:, 1:end-1)+Yl(:, 2:end))/2);
    Xnv = interp2(Xl, Yl, Xn, (Xl(:, 1:end-1)+Xl(:, 2:end))/2,...
                                            (Yl(:, 1:end-1)+Yl(:, 2:end))/2);
    Yeu = interp2(Xl, Yl, Ye, (Xl(1:end-1, :)+Xl(2:end, :))/2,...
                                            (Yl(1:end-1, :)+Yl(2:end, :))/2);
    Ynu = interp2(Xl, Yl, Yn, (Xl(1:end-1, :)+Xl(2:end, :))/2,...
                                            (Yl(1:end-1, :)+Yl(2:end, :))/2);
    
    % Convert metrics to diagonal matrices so they can be multiplied by the 
    % logical operators
    Ju = spdiags(1./reshape(Ju', [], 1), 0, numel(Ju), numel(Ju));
    Jv = spdiags(1./reshape(Jv', [], 1), 0, numel(Jv), numel(Jv));
    Xev = spdiags(reshape(Xev', [], 1), 0, numel(Xev), numel(Xev));
    Xnv = spdiags(reshape(Xnv', [], 1), 0, numel(Xnv), numel(Xnv));
    Yeu = spdiags(reshape(Yeu', [], 1), 0, numel(Yeu), numel(Yeu));
    Ynu = spdiags(reshape(Ynu', [], 1), 0, numel(Ynu), numel(Ynu));
    
    % Construct 2D uniform mimetic gradient operator (d/de, d/dn)
    G = grad2D(k, m-1, 1, n-1, 1);
    Ge = G(1:m*(n-1), :);
    Gn = G(m*(n-1)+1:end, :);
    
    % Apply transformation
    Gx = Ju*(Ynu*Ge-Yeu*GI2(Gn, m-1, n-1, 'Gn'));
    Gy = Jv*(-Xnv*GI2(Ge, m-1, n-1, 'Ge')+Xev*Gn);
    
    % Final 2D curvilinear mimetic gradient operator (d/dx, d/dy)
    G = [Gx; Gy];
end
