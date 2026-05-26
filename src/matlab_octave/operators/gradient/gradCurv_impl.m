function G = gradCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic gradient operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% grid.nodes arrays are (m+1)×(n+1) in ndgrid layout; jacobian2D/3D
% expects meshgrid layout, so a transpose / permute is applied before
% delegating to the 2D/3D curvilinear logic.
%
% Parameters:
%   G    : Sparse matrix — curvilinear gradient operator
%   grid : Validated grid struct with grid.type='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% G = gradCurv_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    switch grid.dim
    case 2
        % grid.nodes.X is (m+1)×(n+1) ndgrid; jacobian2D expects (n+1)×(m+1) meshgrid
        X = grid.nodes.X';
        Y = grid.nodes.Y';
        G = localGrad2DCurv(k, X, Y);

    case 3
        % grid.nodes.X is (m+1)×(n+1)×(o+1) ndgrid; jacobian3D expects (n+1)×(m+1)×(o+1)
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        G = localGrad3DCurv(k, X, Y, Z);

    otherwise
        error('gradCurv_impl:InvalidDim', ...
              'Curvilinear gradient is only implemented for dim=2 and dim=3');
    end
end

function G = localGrad2DCurv(k, X, Y)
    [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y);

    [n, m] = size(X);

    J  = reshape(J,  m, n)';
    Xe = reshape(Xe, m, n)';
    Xn = reshape(Xn, m, n)';
    Ye = reshape(Ye, m, n)';
    Yn = reshape(Yn, m, n)';

    [Xl, Yl] = meshgrid(1:m, 1:n);

    uXl = (Xl(1:end-1,:) + Xl(2:end,:)) / 2;
    uYl = (Yl(1:end-1,:) + Yl(2:end,:)) / 2;
    vXl = (Xl(:,1:end-1) + Xl(:,2:end)) / 2;
    vYl = (Yl(:,1:end-1) + Yl(:,2:end)) / 2;

    Ju  = interp2(Xl, Yl, J,  uXl, uYl);
    Jv  = interp2(Xl, Yl, J,  vXl, vYl);
    Xev = interp2(Xl, Yl, Xe, vXl, vYl);
    Xnv = interp2(Xl, Yl, Xn, vXl, vYl);
    Yeu = interp2(Xl, Yl, Ye, uXl, uYl);
    Ynu = interp2(Xl, Yl, Yn, uXl, uYl);

    Ju  = spdiags(1./reshape(Ju',  [], 1), 0, numel(Ju),  numel(Ju));
    Jv  = spdiags(1./reshape(Jv',  [], 1), 0, numel(Jv),  numel(Jv));
    Xev = spdiags(reshape(Xev', [], 1), 0, numel(Xev), numel(Xev));
    Xnv = spdiags(reshape(Xnv', [], 1), 0, numel(Xnv), numel(Xnv));
    Yeu = spdiags(reshape(Yeu', [], 1), 0, numel(Yeu), numel(Yeu));
    Ynu = spdiags(reshape(Ynu', [], 1), 0, numel(Ynu), numel(Ynu));

    Gunif = gradNonPeriodic2D(k, m-1, 1, n-1, 1);
    Ge = Gunif(1:m*(n-1), :);
    Gn = Gunif(m*(n-1)+1:end, :);

    Gx = Ju * (Ynu*Ge - Yeu*GI2(Gn, m-1, n-1, 'Gn'));
    Gy = Jv * (-Xnv*GI2(Ge, m-1, n-1, 'Ge') + Xev*Gn);
    G = [Gx; Gy];
end

function G = localGrad3DCurv(k, X, Y, Z)
    [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z);

    [n, m, o] = size(X);

    J   = permute(reshape(J,            m, n, o), [2, 1, 3]);
    mA  = permute(reshape(Yn.*Zc-Zn.*Yc, m, n, o), [2, 1, 3]);
    mB  = permute(reshape(Zn.*Xc-Xn.*Zc, m, n, o), [2, 1, 3]);
    mC  = permute(reshape(Xn.*Yc-Yn.*Xc, m, n, o), [2, 1, 3]);
    mD  = permute(reshape(Ze.*Yc-Ye.*Zc, m, n, o), [2, 1, 3]);
    mE  = permute(reshape(Xe.*Zc-Ze.*Xc, m, n, o), [2, 1, 3]);
    mF  = permute(reshape(Ye.*Xc-Xe.*Yc, m, n, o), [2, 1, 3]);
    mG  = permute(reshape(Ye.*Zn-Ze.*Yn, m, n, o), [2, 1, 3]);
    mH  = permute(reshape(Ze.*Xn-Xe.*Zn, m, n, o), [2, 1, 3]);
    mI  = permute(reshape(Xe.*Yn-Ye.*Xn, m, n, o), [2, 1, 3]);

    [Xl, Yl, Zl] = meshgrid(1:m, 1:n, 1:o);

    % u-face positions: average over x and z
    uXl = (Xl(1:end-1,:,:)+Xl(2:end,:,:))/2;  uXl = (uXl(:,:,1:end-1)+uXl(:,:,2:end))/2;
    uYl = (Yl(1:end-1,:,:)+Yl(2:end,:,:))/2;  uYl = (uYl(:,:,1:end-1)+uYl(:,:,2:end))/2;
    uZl = (Zl(1:end-1,:,:)+Zl(2:end,:,:))/2;  uZl = (uZl(:,:,1:end-1)+uZl(:,:,2:end))/2;
    % v-face positions: average over y and z
    vXl = (Xl(:,1:end-1,:)+Xl(:,2:end,:))/2;  vXl = (vXl(:,:,1:end-1)+vXl(:,:,2:end))/2;
    vYl = (Yl(:,1:end-1,:)+Yl(:,2:end,:))/2;  vYl = (vYl(:,:,1:end-1)+vYl(:,:,2:end))/2;
    vZl = (Zl(:,1:end-1,:)+Zl(:,2:end,:))/2;  vZl = (vZl(:,:,1:end-1)+vZl(:,:,2:end))/2;
    % w-face positions: average over x and y
    wXl = (Xl(1:end-1,:,:)+Xl(2:end,:,:))/2;  wXl = (wXl(:,1:end-1,:)+wXl(:,2:end,:))/2;
    wYl = (Yl(1:end-1,:,:)+Yl(2:end,:,:))/2;  wYl = (wYl(:,1:end-1,:)+wYl(:,2:end,:))/2;
    wZl = (Zl(1:end-1,:,:)+Zl(2:end,:,:))/2;  wZl = (wZl(:,1:end-1,:)+wZl(:,2:end,:))/2;

    Ju = interp3(Xl, Yl, Zl, J,  uXl, uYl, uZl);
    Au = interp3(Xl, Yl, Zl, mA, uXl, uYl, uZl);
    Du = interp3(Xl, Yl, Zl, mD, uXl, uYl, uZl);
    Gu = interp3(Xl, Yl, Zl, mG, uXl, uYl, uZl);

    Jv = interp3(Xl, Yl, Zl, J,  vXl, vYl, vZl);
    Bv = interp3(Xl, Yl, Zl, mB, vXl, vYl, vZl);
    Ev = interp3(Xl, Yl, Zl, mE, vXl, vYl, vZl);
    Hv = interp3(Xl, Yl, Zl, mH, vXl, vYl, vZl);

    Jw = interp3(Xl, Yl, Zl, J,  wXl, wYl, wZl);
    Cw = interp3(Xl, Yl, Zl, mC, wXl, wYl, wZl);
    Fw = interp3(Xl, Yl, Zl, mF, wXl, wYl, wZl);
    Iw = interp3(Xl, Yl, Zl, mI, wXl, wYl, wZl);

    Ju = spdiags(1./reshape(permute(Ju,[2,1,3]),[],1), 0, numel(Ju), numel(Ju));
    Jv = spdiags(1./reshape(permute(Jv,[2,1,3]),[],1), 0, numel(Jv), numel(Jv));
    Jw = spdiags(1./reshape(permute(Jw,[2,1,3]),[],1), 0, numel(Jw), numel(Jw));
    Au = spdiags(reshape(permute(Au,[2,1,3]),[],1), 0, numel(Au), numel(Au));
    Bv = spdiags(reshape(permute(Bv,[2,1,3]),[],1), 0, numel(Bv), numel(Bv));
    Cw = spdiags(reshape(permute(Cw,[2,1,3]),[],1), 0, numel(Cw), numel(Cw));
    Du = spdiags(reshape(permute(Du,[2,1,3]),[],1), 0, numel(Du), numel(Du));
    Ev = spdiags(reshape(permute(Ev,[2,1,3]),[],1), 0, numel(Ev), numel(Ev));
    Fw = spdiags(reshape(permute(Fw,[2,1,3]),[],1), 0, numel(Fw), numel(Fw));
    Gu = spdiags(reshape(permute(Gu,[2,1,3]),[],1), 0, numel(Gu), numel(Gu));
    Hv = spdiags(reshape(permute(Hv,[2,1,3]),[],1), 0, numel(Hv), numel(Hv));
    Iw = spdiags(reshape(permute(Iw,[2,1,3]),[],1), 0, numel(Iw), numel(Iw));

    Grad = gradNonPeriodic3D(k, m-1, 1, n-1, 1, o-1, 1);
    Ge = Grad(1:m*(n-1)*(o-1), :);
    Gn = Grad(m*(n-1)*(o-1)+1 : m*(n-1)*(o-1)+(m-1)*n*(o-1), :);
    Gc = Grad(m*(n-1)*(o-1)+(m-1)*n*(o-1)+1 : end, :);

    Gx = Ju*(Au*Ge + Du*GI13(Gn, m-1, n-1, o-1, 'Gn')  + Gu*GI13(Gc, m-1, n-1, o-1, 'Gc'));
    Gy = Jv*(Bv*GI13(Ge, m-1, n-1, o-1, 'Ge') + Ev*Gn  + Hv*GI13(Gc, m-1, n-1, o-1, 'Gcy'));
    Gz = Jw*(Cw*GI13(Ge, m-1, n-1, o-1, 'Gee') + Fw*GI13(Gn, m-1, n-1, o-1, 'Gnn') + Iw*Gc);
    G = [Gx; Gy; Gz];
end
