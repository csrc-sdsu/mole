function [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3D(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc)
% PURPOSE
% 3D Jacobian metrics for curvilinear operators
%
% DESCRIPTION
% Returns:
%                J : Determinant of the Jacobian on the centers if optional
%                    arguments are specified, else nodes
%               Xe : dx/de metric on the centers if optional arguments are 
%                    specified, else nodes
%               Xn : dx/dn metric on the centers if optional arguments are 
%                    specified, else nodes
%               Xk : dx/dk metric on the centers if optional arguments are 
%                    specified, else nodes
%               Ye : dy/de metric on the centers if optional arguments are 
%                    specified, else nodes
%               Yn : dy/dn metric on the centers if optional arguments are 
%                    specified, else nodes
%               Yk : dy/dk metric on the centers if optional arguments are 
%                    specified, else nodes
%               Ze : dz/de metric on the centers if optional arguments are 
%                    specified, else nodes
%               Zn : dz/dn metric on the centers if optional arguments are 
%                    specified, else nodes
%               Zk : dz/dk metric on the centers if optional arguments are 
%                    specified, else nodes
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid centers if optional
%                    arguments are specified, else nodes
%                Y : y-coordinates (physical) of meshgrid centers if optional
%                    arguments are specified, else nodes
%                Z : z-coordinates (physical) of meshgrid centers if optional
%                    arguments are specified, else nodes
%    (optional)  m : Number of cells in xi direction
%    (optional) dx : Step size in xi direction
%    (optional)  n : Number of cells in eta direction
%    (optional) dy : Step size in eta direction
%    (optional)  o : Number of cells in kappa direction
%    (optional) dz : Step size in kappa direction
%    (optional) dc : a0 (6x1 vector for left, right, bottom, top
%                    boundaries, resp.)
%    (optional) nc : b0 (6x1 vector for left, right, bottom, top
%                    boundaries, resp.)
%
% SYNTAX
% [J, Xe, Xn, Xv, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z)
% [J, Xe, Xn, Xv, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    if nargin ~= 4 && nargin ~= 12
        error("jacobian3D:InvalidNumArgs", ...
              "jacobian3D expects 4 or 9 arguments")
    elseif nargin == 4
        [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3DLegacy(k, X, Y, Z);
        return;
    end

    assert(all(size(dc) == [6 1]), "dc is a 6x1 vector")
    assert(all(size(nc) == [6 1]), "nc is a 6x1 vector")

    % Periodic Handling
    if isempty(find(dc(1:2).^2 + nc(1:2).^2, 1))
        Ge = gradPeriodic(k, m, dx);
        IFCx = interpolFacesToCentersG1DPeriodic(k, m);
        Im = speye(m);
    else
        Ge = gradNonPeriodic(k, m, dx);
        IFCx = interpolFacesToCentersG1D(k, m);
        Im = speye(m + 2);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2, 1))
        Gn = gradPeriodic(k, n, dy);
        IFCy = interpolFacesToCentersG1DPeriodic(k, n);
        In = speye(n);
    else
        Gn = gradNonPeriodic(k, n, dy);
        IFCy = interpolFacesToCentersG1D(k, n);
        In = speye(n + 2);
    end
    if isempty(find(dc(5:6).^2 + nc(5:6).^2, 1))
        Gk = gradPeriodic(k, o, dz);
        IFCz = interpolFacesToCentersG1DPeriodic(k, o);
        Io = speye(o);
    else
        Gk = gradNonPeriodic(k, o, dz);
        IFCz = interpolFacesToCentersG1D(k, o);
        Io = speye(o + 2);
    end

    numC = numel(X);

    % Get metrics on centers
    % We don't augment the identity matrices
    % so that we don't lose information
    % around the boundaries
    Ge = kron(kron(Io, In), IFCx) * kron(kron(Io, In), Ge);
    Gn = kron(kron(Io, IFCy), Im) * kron(kron(Io, Gn), Im);
    Gk = kron(kron(IFCz, In), Im) * kron(kron(Gk, In), Im);
    G = [Ge; Gn; Gk];

    X = reshape(X', [], 1);
    Y = reshape(Y', [], 1);
    Z = reshape(Z', [], 1);
    metrics = G * [X Y Z];

    Xe = metrics(1:numC, 1);
    Xn = metrics(1+numC:2*numC, 1);
    Xk = metrics(1+2*numC:end, 1);
    Ye = metrics(1:numC, 2);
    Yn = metrics(1+numC:2*numC, 2);
    Yk = metrics(1+2*numC:end, 2);
    Ze = metrics(1:numC, 3);
    Zn = metrics(1+numC:2*numC, 3);
    Zk = metrics(1+2*numC:end, 3);

    J = Xe .* (Yn .* Zk - Yk .* Zn) - Xn .* (Ye .* Zk - Yk .* Ze) + Xk .* (Ye .* Zn - Yn .* Ze);

end