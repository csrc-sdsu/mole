function [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y, dc, nc)
% PURPOSE
% Returns the Jacobian metrics (Xe, Xn, Ye, Yn, and J = XeYn - XnYe) of a
% mesh
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid centers if
%                    optional arguments are specified, else nodes
%                Y : y-coordinates (physical) of meshgrid centers if
%                    optional arguments are specified, else nodes
%    (optional) dc : a0 (4x1 vector for left, right, bottom, top
%                    boundaries, resp.)
%    (optional) nc : b0 (4x1 vector for left, right, bottom, top
%                    boundaries, resp.)
% 
% SYNTAX
% [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y)
% [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y, dc, nc)
% 
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    if nargin ~= 3 && nargin ~= 5
        error("jacobian2D:InvalidNumArgs", ...
              "jacobian2D expects 3 or 5 arguments")
    elseif nargin == 3
        [J,Xe,Xn,Ye,Yn] = jacobian2DLegacy(k,X,Y);
        return;
    end

    assert(all(size(dc) == [4 1]), "dc is a 4x1 vector")
    assert(all(size(nc) == [4 1]), "nc is a 4x1 vector")

    assert(size(X, 2) ~= 1, "X must be in matrix form")
    assert(size(Y, 2) ~= 1, "Y must be in matrix form")

    assert(all(size(X) == size(Y)), "X and Y must be the same size")

    [n, m] = size(X);

    % Periodic Handling
    if isempty(find(dc(1:2).^2 + nc(1:2).^2,1))
        dx = 1 / m;
        Ge = gradPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1DPeriodic(k,m);
        Im = speye(m);
    else
        m = m - 2;
        dx = 1 / m;
        Ge = gradNonPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1D(k,m);
        Im = speye(m+2);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2,1))
        dy = 1 / n;
        Gn = gradPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1DPeriodic(k,n);
        In = speye(n);
    else
        n = n - 2;
        dy = 1 / n;
        Gn = gradNonPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1D(k,n);
        In = speye(n+2);
    end

    xc = reshape(X', [], 1);
    yc = reshape(Y', [], 1);
    numC = numel(xc);

    % Get metrics on centers
    % We don't augment the identity matrices
    % so that we don't lose information
    % around the boundaries
    Ge = kron(In,IFCx) * kron(In,Ge);
    Gn = kron(IFCy,Im) * kron(Gn,Im);
    G = [Ge; Gn];

    metrics = G * [xc yc];

    Xe = metrics(1:numC,1);
    Xn = metrics(1+numC:end,1);
    Ye = metrics(1:numC,2);
    Yn = metrics(1+numC:end,2);

    J = Xe .* Yn - Xn .* Ye;

end