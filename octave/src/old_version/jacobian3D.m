function [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3D(k, X, Y, Z, dc, nc)
% PURPOSE
% Returns the 3D jacobian metrics of a mesh
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid centers if optional
%                    arguments are specified, else nodes
%                Y : y-coordinates (physical) of meshgrid centers if optional
%                    arguments are specified, else nodes
%                Z : z-coordinates (physical) of meshgrid centers if optional
%                    arguments are specified, else nodes
%    (optional) dc : a0 (6x1 vector for left, right, bottom, top, front, and
%                    back boundaries, resp.)
%    (optional) nc : b0 (6x1 vector for left, right, bottom, top, front, and
%                    back boundaries, resp.)
% 
% SYNTAX
% [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3D(k, X, Y, Z)
% [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3D(k, X, Y, Z, dc, nc)
% 
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    if nargin ~= 4 && nargin ~= 6
        error("jacobian3D:InvalidNumArgs", ...
              "jacobian3D expects 4 or 6 arguments")
    elseif nargin == 4
        [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3DLegacy(k, X, Y, Z);
        return;
    end

    assert(all(size(dc) == [6 1]), "dc is a 6x1 vector")
    assert(all(size(nc) == [6 1]), "nc is a 6x1 vector")

    assert(size(X, 2) ~= 1, "X must be in matrix form")
    assert(size(Y, 2) ~= 1, "Y must be in matrix form")
    assert(size(Z, 2) ~= 1, "Z must be in matrix form")

    assert(all(size(X) == size(Y)) && all(size(X) == size(Z)), "X, Y, and Z must all be the same size")

    [n, m, o] = size(X);

    % Periodic Handling
    if isempty(find(dc(1:2).^2 + nc(1:2).^2, 1))
        dx = 1 / m;
        Ge = gradPeriodic(k, m, dx);
        IFCx = interpolFacesToCentersG1DPeriodic(k, m);
        Im = speye(m);
    else
        m = m - 2;
        dx = 1 / m;
        Ge = gradNonPeriodic(k, m, dx);
        IFCx = interpolFacesToCentersG1D(k, m);
        Im = speye(m + 2);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2, 1))
        dy = 1 / n;
        Gn = gradPeriodic(k, n, dy);
        IFCy = interpolFacesToCentersG1DPeriodic(k, n);
        In = speye(n);
    else
        n = n - 2;
        dy = 1 / n;
        Gn = gradNonPeriodic(k, n, dy);
        IFCy = interpolFacesToCentersG1D(k, n);
        In = speye(n + 2);
    end
    if isempty(find(dc(5:6).^2 + nc(5:6).^2, 1))
        dz = 1 / o;
        Gk = gradPeriodic(k, o, dz);
        IFCz = interpolFacesToCentersG1DPeriodic(k, o);
        Io = speye(o);
    else
        o = o - 2;
        dz = 1 / o;
        Gk = gradNonPeriodic(k, o, dz);
        IFCz = interpolFacesToCentersG1D(k, o);
        Io = speye(o + 2);
    end

    xc = reshape(permute(X, [2 1 3]), [], 1);
    yc = reshape(permute(Y, [2 1 3]), [], 1);
    zc = reshape(permute(Z, [2 1 3]), [], 1);
    numC = numel(xc);

    % Get metrics on centers
    % We don't augment the identity matrices
    % so that we don't lose information
    % around the boundaries
    Ge = kron(kron(Io, In), IFCx) * kron(kron(Io, In), Ge);
    Gn = kron(kron(Io, IFCy), Im) * kron(kron(Io, Gn), Im);
    Gk = kron(kron(IFCz, In), Im) * kron(kron(Gk, In), Im);
    G = [Ge; Gn; Gk];

    metrics = G * [xc yc zc];

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