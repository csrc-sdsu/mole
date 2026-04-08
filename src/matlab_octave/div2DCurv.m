function D = div2DCurv(k, X, Y, m, dx, n, dy, dc, nc)
% Returns:
%                D : 2D curvilinear mimetic divergence operator. If optional
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
        error("div2DCurv:InvalidNumArgs", ...
              "div2DCurv expects 3 or 9 arguments")
    elseif nargin == 3
        D = div2DCurvLegacy(k,X,Y);
        return;
    end

    assert(all(size(dc) == [4 1]), "dc is a 4x1 vector")
    assert(all(size(nc) == [4 1]), "nc is a 4x1 vector")

    % Periodic Handling
    if isempty(find(dc(1:2).^2 + nc(1:2).^2,1))
        De = divPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1DPeriodic(k,m);
        ICFx = interpolCentersToFacesD1DPeriodic(k,m);
        Im = speye(m);
    else
        De = divNonPeriodic(k,m,dx);
        IFCx = interpolFacesToCentersG1D(k,m);
        ICFx = interpolCentersToFacesD1D(k,m);
        Im = speye(m+2);
    end
    if isempty(find(dc(3:4).^2 + nc(3:4).^2,1))
        Dn = divPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1DPeriodic(k,n);
        ICFy = interpolCentersToFacesD1DPeriodic(k,n);
        In = speye(n);
    else
        Dn = divNonPeriodic(k,n,dy);
        IFCy = interpolFacesToCentersG1D(k,n);
        ICFy = interpolCentersToFacesD1D(k,n);
        In = speye(n+2);
    end

    % Make De and Dn act on and output to the centers
    % This allows them to be added together
    De = kron(In,De) * kron(In,ICFx);
    Dn = kron(Dn,Im) * kron(ICFy,Im);

    % Apply metrics
    [J,Xe,Xn,Ye,Yn] = jacobian2D(k,X,Y,m,dx,n,dy,dc,nc);

    Dx = (Yn ./ J) .* De - (Ye ./ J) .* Dn;
    Dy = (Xe ./ J) .* Dn - (Xn ./ J) .* De;

    % Now have them act on the extended faces
    Dx = Dx * kron(In,IFCx);
    Dy = Dy * kron(IFCy,Im);

    D = [Dx Dy];

    % Ensure no output on boundary -- Probably a cleaner way to do this
    bdry = find(sum(spones(div2D(2,m,1,n,1,dc,nc)), 2) == 0);
    D(bdry,:) = sparse(size(bdry,1),size(D,2));

end
