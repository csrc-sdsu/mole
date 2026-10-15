function G = grad3DCurv(k, X, Y, Z, dc, nc)
% PURPOSE
% Returns a 3D curvilinear mimetic gradient operator. If optional
% arguments are specified, it outputs to the extended
% faces (normal faces plus boundaries)
%
% DESCRIPTION
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid centers if
%                    optional arguments are specified, else nodes
%                Y : y-coordinates (physical) of meshgrid centers if
%                    optional arguments are specified, else nodes
%                Z : Z-coordinates (physical) of meshgrid centers if
%                    optional arguments are specified, else nodes
%    (optional) dc : a0 (6x1 vector for left, right, bottom, top, front, and
%                    back boundaries, resp.)
%    (optional) nc : b0 (6x1 vector for left, right, bottom, top, front, and
%                    back boundaries, resp.)
% 
% SYNTAX
% G = grad3DCurv(k, X, Y, Z)
% G = grad3DCurv(k, X, Y, Z, dc, nc)
% 
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 4 && nargin ~= 6
        error("grad3DCurv:InvalidNumArgs", ...
              "grad3DCurv expects 4 or 6 arguments")
    elseif nargin == 4
        G = grad3DCurvLegacy(k, X, Y, Z);
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
        Ge = gradPeriodic(k,m,dx);
        ICFx = interpolCentersToFacesD1DPeriodic(k,m);
        IFCx = interpolFacesToCentersG1DPeriodic(k,m);
        Im = speye(m);
    else
        m = m - 2;
        dx = 1 / m;
        Ge = gradNonPeriodic(k,m,dx);
        ICFx = interpolCentersToFacesD1D(k,m);
        IFCx = interpolFacesToCentersG1D(k,m);
        Im = speye(m+2);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2, 1))
        dy = 1 / n;
        Gn = gradPeriodic(k,n,dy);
        ICFy = interpolCentersToFacesD1DPeriodic(k,n);
        IFCy = interpolFacesToCentersG1DPeriodic(k,n);
        In = speye(n);
    else
        n = n - 2;
        dy = 1 / n;
        Gn = gradNonPeriodic(k,n,dy);
        ICFy = interpolCentersToFacesD1D(k,n);
        IFCy = interpolFacesToCentersG1D(k,n);
        In = speye(n+2);
    end
    if isempty(find(dc(5:6).^2 + nc(5:6).^2, 1))
        dz = 1 / o;
        Gk = gradPeriodic(k, o, dz);
        ICFz = interpolCentersToFacesD1DPeriodic(k,o);
        IFCz = interpolFacesToCentersG1DPeriodic(k,o);
        Io = speye(o);
    else
        o = o - 2;
        dz = 1 / o;
        Gk = gradNonPeriodic(k,o,dz);
        ICFz = interpolCentersToFacesD1D(k,o);
        IFCz = interpolFacesToCentersG1D(k,o);
        Io = speye(o+2);
    end

    % Make Ge, Gn, and Gk act on and output to the centers
    % This allows them to be added together
    Ge = kron(kron(Io, In), IFCx) * kron(kron(Io, In), Ge);
    Gn = kron(kron(Io, IFCy), Im) * kron(kron(Io, Gn), Im);
    Gk = kron(kron(IFCz, In), Im) * kron(kron(Gk, In), Im);

    % Apply metrics
    [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3D(k, X, Y, Z, dc, nc);

    Gx = ((Yn .* Zk - Zn .* Yk) ./ J) .* Ge ...
       + ((Ze .* Yk - Ye .* Zk) ./ J) .* Gn ...
       + ((Ye .* Zn - Ze .* Yn) ./ J) .* Gk;
    Gy = ((Zn .* Xk - Xn .* Zk) ./ J) .* Ge ...
       + ((Xe .* Zk - Ze .* Xk) ./ J) .* Gn ...
       + ((Ze .* Xn - Xe .* Zn) ./ J) .* Gk;
    Gz = ((Xn .* Yk - Yn .* Xk) ./ J) .* Ge ...
       + ((Ye .* Xk - Xe .* Yk) ./ J) .* Gn ...
       + ((Xe .* Yn - Ye .* Xn) ./ J) .* Gk;

    % Now have them output to the extended faces
    Gx = kron(kron(Io, In), ICFx) * Gx;
    Gy = kron(kron(Io, ICFy), Im) * Gy;
    Gz = kron(kron(ICFz, In), Im) * Gz;

    G = [Gx; Gy; Gz];

end
