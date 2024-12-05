% MOLE is distributed under a GNU General Public License; please refer to the LICENSE file for more details.

function [Nx, Ny] = nodal2DCurv(k, X, Y)
    % Get the determinant of the jacobian and the metrics
    [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y);
    
    % Dimensions of nodal grid
    [n, m] = size(X);
    
    len = n*m;
    
    % Convert metrics to diagonal matrices
    J = spdiags(1./J, 0, len, len);
    Xe = spdiags(Xe, 0, len, len);
    Xn = spdiags(Xn, 0, len, len);
    Ye = spdiags(Ye, 0, len, len);
    Yn = spdiags(Yn, 0, len, len);
    
    % Construct 2D uniform nodal operator
    N = nodal2D(k, m, 1, n, 1); % N is tall and skinny
    Ne = N(1:len, :);
    Nn = N(len+1:end, :);
    
    % Apply transformation
    Nx = J*(Yn*Ne-Ye*Nn);
    Ny = J*(-Xn*Ne+Xe*Nn);
    
    % [J*Yn -J*Ye; J*-Xn J*Xe]*[Ne; Nn]
end
