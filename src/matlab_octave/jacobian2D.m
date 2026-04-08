function [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y, m, dx, n, dy, dc, nc)
% Returns:
%                J : Determinant of the Jacobian (XeYn - XnYe) on the
%                    centers if optional arguments are specified, else nodes
%               Xe : dx/de metric on the centers if optional arguments are
%                    specified, else nodes
%               Xn : dx/dn metric on the centers if optional arguments are
%                    specified, else nodes
%               Ye : dy/de metric on the centers if optional arguments are
%                    specified, else nodes
%               Yn : dy/dn metric on the centers if optional arguments are
%                    specified, else nodes
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid centers if
%                    optional arguments are specified, else nodes
%                Y : y-coordinates (physical) of meshgrid centers if
%                    optional arguments are specified, else nodes
%    (optional)  m : Number of cells in xi direction
%    (optional) dx : Step size in xi direction
%    (optional)  n : Number of cells in eta direction
%    (optional) dy : Step size in eta direction
%    (optional) dc : a0 (4x1 vector for left, right, bottom, top
%                    boundaries, resp.)
%    (optional) nc : b0 (4x1 vector for left, right, bottom, top
%                    boundaries, resp.)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    if nargin ~= 3 && nargin ~= 9
        error("jacobian2D:InvalidNumArgs", ...
              "jacobian2D expects 3 or 9 arguments")
    elseif nargin == 3
        [J,Xe,Xn,Ye,Yn] = jacobian2DLegacy(k,X,Y);
        return;
    end

    assert(all(size(dc) == [4 1]), "dc is a 4x1 vector")
    assert(all(size(nc) == [4 1]), "nc is a 4x1 vector")

    % Periodic Handling
    if isempty(find(dc(1:2).^2 + nc(1:2).^2,1))
        Ge = gradPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1DPeriodic(k,m);
        Im = speye(m);
    else
        Ge = gradNonPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1D(k,m);
        Im = speye(m+2);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2,1))
        Gn = gradPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1DPeriodic(k,n);
        In = speye(n);
    else
        Gn = gradNonPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1D(k,n);
        In = speye(n+2);
    end

    numC = numel(X);

    % Get metrics on centers
    % We don't augment the identity matrices
    % so that we don't lose information
    % around the boundaries
    Ge = kron(In,IFCx) * kron(In,Ge);
    Gn = kron(IFCy,Im) * kron(Gn,Im);
    G = [Ge; Gn];

    X = reshape(X',[],1);
    Y = reshape(Y',[],1);
    metrics = G * [X Y];

    Xe = metrics(1:numC,1);
    Xn = metrics(1+numC:end,1);
    Ye = metrics(1:numC,2);
    Yn = metrics(1+numC:end,2);

    J = Xe .* Yn - Xn .* Ye;

end