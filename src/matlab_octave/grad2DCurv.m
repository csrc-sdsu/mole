function G = grad2DCurv(k, X, Y, m, dx, n, dy, dc, nc)
% Returns:
%                G : 2D curvilinear mimetic gradient operator. If optional
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
%    (optional) dc : a0 (4x1 vector for left, right, bottom, top
%                    boundaries, resp.)
%    (optional) nc : b0 (4x1 vector for left, right, bottom, top
%                    boundaries, resp.)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    if nargin ~=3 && nargin ~= 9
        error("grad2DCurv:InvalidNumArgs", ...
              "grad2DCurv expects 3 or 9 arguments")
    elseif nargin == 3
        G = grad2DCurvLegacy(k,X,Y);
        return;
    end

    assert(all(size(dc) == [4 1]), "dc is a 4x1 vector")
    assert(all(size(nc) == [4 1]), "nc is a 4x1 vector")

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

    % Make Ge and Gn act on and output to the centers
    % This allows them to be added together
    Ge = kron(In,IFCx) * kron(In,Ge);
    Gn = kron(IFCy,Im) * kron(Gn,Im);

    % Apply Metrics
    [J,Xe,Xn,Ye,Yn] = jacobian2D(k,X,Y,m,dx,n,dy,dc,nc);

    Gx = (Yn ./ J) .* Ge - (Ye ./ J) .* Gn;
    Gy = (Xe ./ J) .* Gn - (Xn ./ J) .* Ge;

    % Now have them output to the extended faces
    Gx = kron(In,ICFx) * Gx;
    Gy = kron(ICFy,Im) * Gy;

    G = [Gx; Gy];

end
