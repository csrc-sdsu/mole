% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University (SDSU) and Contributors 
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------

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