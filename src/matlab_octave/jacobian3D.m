function [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z)
% Returns:
%                J : Determinant of the Jacobian
%               Xe : dx/de metric
%               Xn : dx/dn metric
%               Xc : dx/dc metric
%               Ye : dy/de metric
%               Yn : dy/dn metric
%               Yc : dy/dc metric
%               Ze : dz/de metric
%               Zn : dz/dn metric
%               Zc : dz/dc metric
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid
%                Y : y-coordinates (physical) of meshgrid
%                Z : z-coordinates (physical) of meshgrid
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    [n, m, o] = size(X);
    
    X = reshape(permute(X, [2, 1, 3]), [], 1);
    Y = reshape(permute(Y, [2, 1, 3]), [], 1);
    Z = reshape(permute(Z, [2, 1, 3]), [], 1);
    
    N = nodal3D(k, m, 1, n, 1, o, 1);
    
    X = N*X;
    Y = N*Y;
    Z = N*Z;
    
    mno = m*n*o;
    
    Xe = X(1:mno);
    Xn = X(mno+1:2*mno);
    Xc = X(2*mno+1:end);
    Ye = Y(1:mno);
    Yn = Y(mno+1:2*mno);
    Yc = Y(2*mno+1:end);
    Ze = Z(1:mno);
    Zn = Z(mno+1:2*mno);
    Zc = Z(2*mno+1:end);
    
    J = Xe.*(Yn.*Zc-Yc.*Zn)-Ye.*(Xn.*Zc-Xc.*Zn)+Ze.*(Xn.*Yc-Xc.*Yn);
end