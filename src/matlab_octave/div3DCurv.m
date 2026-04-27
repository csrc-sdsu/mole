function D = div3DCurv(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc)
% PURPOSE
% Returns a 3D curvilinear mimetic divergence operator
%
% DESCRIPTION
% Returns:
%                D : 3D curvilinear mimetic divergence operator. If optional
%                    arguments are specified, it acts on the extended faces
%                    (normal faces plus boundaries)
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
% D = div3DCurv(k, X, Y, Z)
% D = div3DCurv(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~= 4 && nargin ~= 12
        error("div2DCurv:InvalidNumArgs", ...
              "div2DCurv expects 4 or 12 arguments")
    elseif nargin == 4
        D = div3DCurvLegacy(k, X, Y, Z);
        return;
    end

    assert(all(size(dc) == [6 1]), "dc is a 6x1 vector")
    assert(all(size(nc) == [6 1]), "nc is a 6x1 vector")

    % Periodic Handling
    if isempty(find(dc(1:2).^2 + nc(1:2).^2,1))
        De = divPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1DPeriodic(k,m);
        ICFx = interpolCentersToFacesD1DPeriodic(k,m);
        Im = speye(m);
        Bx = sparse(m, m);
    else
        De = divNonPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1D(k,m);
        ICFx = interpolCentersToFacesD1D(k,m);
        Im = speye(m+2);
        Bx = sparse(m + 2, m + 1);
        Bx(1, 1) = 1;
        Bx(end, end) = 1;
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2,1))
        Dn = divPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1DPeriodic(k,n);
        ICFy = interpolCentersToFacesD1DPeriodic(k,n);
        In = speye(n);
        By = sparse(n, n);
    else
        Dn = divNonPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1D(k,n);
        ICFy = interpolCentersToFacesD1D(k,n);
        In = speye(n+2);
        By = sparse(n + 2, n + 1);
        By(1, 1) = 1;
        By(end, end) = 1;
    end
    if isempty(find(dc(5:6).^2 + nc(5:6).^2, 1))
        Dk = divPeriodic(k, o, dz);
        IFCz = interpolFacesToCentersG1DPeriodic(k, o);
        ICFz = interpolCentersToFacesD1DPeriodic(k, o);
        Io = speye(o);
        Bz = sparse(o, o);
    else
        Dk = divNonPeriodic(k, o, dz);
        IFCz = interpolFacesToCentersG1D(k, o);
        ICFz = interpolCentersToFacesD1D(k, o);
        Io = speye(o + 2);
        Bz = sparse(o + 2, o + 1);
        Bz(1, 1) = 1;
        Bz(end, end) = 1;
    end

    % Make De, Dn, and Dk act on and output to the centers
    % This allows them to be added together
    De = kron(kron(Io, In), De) * kron(kron(Io, In), ICFx);
    Dn = kron(kron(Io, Dn), Im) * kron(kron(Io, ICFy), Im);
    Dk = kron(kron(Dk, In), Im) * kron(kron(ICFz, In), Im);

    % Apply metrics
    [J, Xe, Xn, Xk, Ye, Yn, Yk, Ze, Zn, Zk] = jacobian3D(k, X, Y, Z, m, dx, n, dy, o, dz, dc, nc);

    Dx = ((Yn .* Zk - Zn .* Yk) ./ J) .* De ...
       + ((Ze .* Yk - Ye .* Zk) ./ J) .* Dn ...
       + ((Ye .* Zn - Ze .* Yn) ./ J) .* Dk;
    Dy = ((Zn .* Xk - Xn .* Zk) ./ J) .* De ...
       + ((Xe .* Zk - Ze .* Xk) ./ J) .* Dn ...
       + ((Ze .* Xn - Xe .* Zn) ./ J) .* Dk;
    Dz = ((Xn .* Yk - Yn .* Xk) ./ J) .* De ...
       + ((Ye .* Xk - Xe .* Yk) ./ J) .* Dn ...
       + ((Xe .* Yn - Ye .* Xn) ./ J) .* Dk;

    % Now have them act on the extended faces
    Dx = Dx * kron(kron(Io, In), IFCx);
    Dy = Dy * kron(kron(Io, IFCy), Im);
    Dz = Dz * kron(kron(IFCz, In), Im);

    D = [Dx Dy Dz];

    % Ensure no output on boundary
    B = [kron(kron(Io, In), Bx) kron(kron(Io, By), Im) kron(kron(Bz, In), Im)];
    bdry = find(sum(B, 2) ~= 0);
    D(bdry, :) = sparse(size(bdry, 1), size(D, 2));

end
