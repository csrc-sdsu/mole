function D = divCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic divergence operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% Transposes/permutes from ndgrid layout to meshgrid layout expected by
% jacobian2D/jacobian3D, then computes the curvilinear divergence.
%
% Parameters:
%   D    : Sparse matrix — curvilinear divergence operator
%   grid : Validated grid struct with grid.topology='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% D = divCurv_impl(grid, k)
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
        D = localDiv2DCurv(k, X, Y);

    case 3
        % grid.nodes.X is (m+1)×(n+1)×(o+1) ndgrid; jacobian3D expects (n+1)×(m+1)×(o+1)
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        D = localDiv3DCurv(k, X, Y, Z);

    otherwise
        error('divCurv_impl:InvalidDim', ...
              'Curvilinear divergence is only implemented for dim=2 and dim=3');
    end
end

function D = localDiv2DCurv(k, X, Y)
    [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y);

    [n, m] = size(X);

    J  = reshape(J,  m, n)';
    Xe = reshape(Xe, m, n)';
    Xn = reshape(Xn, m, n)';
    Ye = reshape(Ye, m, n)';
    Yn = reshape(Yn, m, n)';

    [Xl, Yl] = meshgrid(1:m, 1:n);
    [Xs, Ys] = meshgrid([1 1.5:1:m-0.5 m], [1 1.5:1:n-0.5 n]);

    J  = interp2(Xl, Yl, J,  Xs, Ys);
    Xe = interp2(Xl, Yl, Xe, Xs, Ys);
    Xn = interp2(Xl, Yl, Xn, Xs, Ys);
    Ye = interp2(Xl, Yl, Ye, Xs, Ys);
    Yn = interp2(Xl, Yl, Yn, Xs, Ys);

    J  = spdiags(1./reshape(J',  [], 1), 0, numel(J),  numel(J));
    Xe = spdiags(reshape(Xe', [], 1), 0, numel(Xe), numel(Xe));
    Xn = spdiags(reshape(Xn', [], 1), 0, numel(Xn), numel(Xn));
    Ye = spdiags(reshape(Ye', [], 1), 0, numel(Ye), numel(Ye));
    Yn = spdiags(reshape(Yn', [], 1), 0, numel(Yn), numel(Yn));

    Dunif = divNonPeriodic2D(k, m-1, 1, n-1, 1);
    De = Dunif(:, 1:m*(n-1));
    Dn = Dunif(:, m*(n-1)+1:end);

    Dx = J * (Yn*De - Ye*DI2(m-1, n-1, 'Dn'));
    Dy = J * (-Xn*DI2(m-1, n-1, 'De') + Xe*Dn);
    D = [Dx Dy];
end

function D = localDiv3DCurv(k, X, Y, Z)
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
    [Xs, Ys, Zs] = meshgrid([1 1.5:1:m-0.5 m], [1 1.5:1:n-0.5 n], [1 1.5:1:o-0.5 o]);

    J   = interp3(Xl, Yl, Zl, J,   Xs, Ys, Zs);
    mA  = interp3(Xl, Yl, Zl, mA,  Xs, Ys, Zs);
    mB  = interp3(Xl, Yl, Zl, mB,  Xs, Ys, Zs);
    mC  = interp3(Xl, Yl, Zl, mC,  Xs, Ys, Zs);
    mD  = interp3(Xl, Yl, Zl, mD,  Xs, Ys, Zs);
    mE  = interp3(Xl, Yl, Zl, mE,  Xs, Ys, Zs);
    mF  = interp3(Xl, Yl, Zl, mF,  Xs, Ys, Zs);
    mG  = interp3(Xl, Yl, Zl, mG,  Xs, Ys, Zs);
    mH  = interp3(Xl, Yl, Zl, mH,  Xs, Ys, Zs);
    mI  = interp3(Xl, Yl, Zl, mI,  Xs, Ys, Zs);

    J   = spdiags(1./reshape(permute(J,  [2,1,3]),[],1), 0, numel(J),  numel(J));
    mA  = spdiags(reshape(permute(mA, [2,1,3]),[],1), 0, numel(mA), numel(mA));
    mB  = spdiags(reshape(permute(mB, [2,1,3]),[],1), 0, numel(mB), numel(mB));
    mC  = spdiags(reshape(permute(mC, [2,1,3]),[],1), 0, numel(mC), numel(mC));
    mD  = spdiags(reshape(permute(mD, [2,1,3]),[],1), 0, numel(mD), numel(mD));
    mE  = spdiags(reshape(permute(mE, [2,1,3]),[],1), 0, numel(mE), numel(mE));
    mF  = spdiags(reshape(permute(mF, [2,1,3]),[],1), 0, numel(mF), numel(mF));
    mG  = spdiags(reshape(permute(mG, [2,1,3]),[],1), 0, numel(mG), numel(mG));
    mH  = spdiags(reshape(permute(mH, [2,1,3]),[],1), 0, numel(mH), numel(mH));
    mI  = spdiags(reshape(permute(mI, [2,1,3]),[],1), 0, numel(mI), numel(mI));

    Dunif = divNonPeriodic3D(k, m-1, 1, n-1, 1, o-1, 1);
    De = Dunif(:, 1:m*(n-1)*(o-1));
    Dn = Dunif(:, m*(n-1)*(o-1)+1 : m*(n-1)*(o-1)+(m-1)*n*(o-1));
    Dc = Dunif(:, m*(n-1)*(o-1)+(m-1)*n*(o-1)+1 : end);

    Dx = J*(mA*De + mD*DI3(m-1, n-1, o-1, 'Dn')  + mG*DI3(m-1, n-1, o-1, 'Dc'));
    Dy = J*(mB*DI3(m-1, n-1, o-1, 'De') + mE*Dn  + mH*DI3(m-1, n-1, o-1, 'Dcc'));
    Dz = J*(mC*DI3(m-1, n-1, o-1, 'Dee') + mF*DI3(m-1, n-1, o-1, 'Dnn') + mI*Dc);
    D = [Dx Dy Dz];
end
