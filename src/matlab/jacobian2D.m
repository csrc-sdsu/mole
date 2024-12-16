% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University Research Foundation (SDSURF). 
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

function [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y)
% Returns:
%                J : Determinant of the Jacobian (XeYn - XnYe)
%               Xe : dx/de metric
%               Xn : dx/dn metric
%               Ye : dy/de metric
%               Yn : dy/dn metric
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid
%                Y : y-coordinates (physical) of meshgrid
    
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