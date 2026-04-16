function [J, Xe, Xn, Ye, Yn] = jacobian2DLegacy(k, X, Y)
% Returns:
%                J : Determinant of the Jacobian (XeYn - XnYe) on the nodes
%               Xe : dx/de metric on the nodes
%               Xn : dx/dn metric on the nodes
%               Ye : dy/de metric on the nodes
%               Yn : dy/dn metric on the nodes
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid nodes
%                Y : y-coordinates (physical) of meshgrid nodes
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    [n, m] = size(X);
    
    X = reshape(X', [], 1);
    Y = reshape(Y', [], 1);
    
    N = nodal2D(k, m, 1, n, 1);
    
    X = N*X;
    Y = N*Y;
    
    mn = m*n;
    
    Xe = X(1:mn);
    Xn = X(mn+1:end);
    Ye = Y(1:mn);
    Yn = Y(mn+1:end);
    
    J = Xe.*Yn-Xn.*Ye;
end