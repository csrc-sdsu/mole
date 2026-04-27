function G = grad3DCurv(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc)
% PURPOSE
% Returns a 3D curvilinear mimetic gradient operator
%
% DESCRIPTION
% Returns:
%                G : 3D curvilinear mimetic gradient operator. If optional
%                    arguments are specified, it outputs to the extended
%                    faces (normal faces plus boundaries)
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
%    (optional)  o : Number of cells in kappa direction
%    (optional) dz : Step size in kappa direction
%    (optional) dc : a0 (6x1 vector for left, right, bottom, top
%                    boundaries, resp.)
%    (optional) nc : b0 (6x1 vector for left, right, bottom, top
%                    boundaries, resp.)
%
% SYNTAX
% G = grad3DCurv(k, X, Y, Z)
% G = grad3DCurv(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 4 && nargin ~= 12
        error("grad3DCurv:InvalidNumArgs", ...
              "grad3DCurv expects 4 or 12 arguments")
    elseif nargin == 4
        G = grad3DCurvLegacy(k, X, Y, Z);
        return;
    end

    assert(all(size(dc) == [6 1]), "dc is a 6x1 vector")
    assert(all(size(nc) == [6 1]), "nc is a 6x1 vector")

    % Periodic Handling
    if isempty(find(dc(1:2).^2 + nc(1:2).^2, 1))
        Ge = gradPeriodic(k,m,dx);
        ICFx = interpolCentersToFacesD1DPeriodic(k,m);
        IFCx = interpolFacesToCentersG1DPeriodic(k,m);
        Im = speye(m);
    else
        Ge = gradNonPeriodic(k,m,dx);
        ICFx = interpolCentersToFacesD1D(k,m);
        IFCx = interpolFacesToCentersG1D(k,m);
        Im = speye(m+2);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2, 1))
        Gn = gradPeriodic(k,n,dy);
        ICFy = interpolCentersToFacesD1DPeriodic(k,n);
        IFCy = interpolFacesToCentersG1DPeriodic(k,n);
        In = speye(n);
    else
        Gn = gradNonPeriodic(k,n,dy);
        ICFy = interpolCentersToFacesD1D(k,n);
        IFCy = interpolFacesToCentersG1D(k,n);
        In = speye(n+2);
    end
    if isempty(find(dc(5:6).^2 + nc(5:6).^2, 1))
        Gk = gradPeriodic(k, o, dz);
        ICFz = interpolCentersToFacesD1DPeriodic(k,o);
        IFCz = interpolFacesToCentersG1DPeriodic(k,o);
        Io = speye(o);
    else
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
    [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3D(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc);

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
