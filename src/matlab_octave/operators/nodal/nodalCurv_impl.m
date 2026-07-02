function N = nodalCurv_impl(grid, k)
% PURPOSE
% Curvilinear mimetic nodal derivative operator for 2-D and 3-D grids.
%
% DESCRIPTION
% Reads physical node coordinates from grid.nodes.X/Y (3D: also .Z).
% Transposes/permutes from ndgrid layout to meshgrid layout expected by
% jacobian2D/jacobian3D, then builds stacked [Nx; Ny] (2D) or [Nx; Ny; Nz] (3D).
%
% Parameters:
%   N    : Stacked sparse matrix of curvilinear nodal operators
%   grid : Validated grid struct with grid.type='curvilinear' and
%          grid.nodes.X/Y (2D) or grid.nodes.X/Y/Z (3D)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% N = nodalCurv_impl(grid, k)
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
        [Nx, Ny] = localNodal2DCurv(k, X, Y);
        N = [Nx; Ny];

    case 3
        % grid.nodes.X is (m+1)×(n+1)×(o+1) ndgrid; jacobian3D expects (n+1)×(m+1)×(o+1)
        X = permute(grid.nodes.X, [2, 1, 3]);
        Y = permute(grid.nodes.Y, [2, 1, 3]);
        Z = permute(grid.nodes.Z, [2, 1, 3]);
        [Nx, Ny, Nz] = localNodal3DCurv(k, X, Y, Z);
        N = [Nx; Ny; Nz];

    otherwise
        error('nodalCurv_impl:InvalidDim', ...
              'Curvilinear nodal is only implemented for dim=2 and dim=3');
    end
end

function [Nx, Ny] = localNodal2DCurv(k, X, Y)
    [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y);

    [n, m] = size(X);
    len = n * m;

    J  = spdiags(1./J,  0, len, len);
    Xe = spdiags(Xe, 0, len, len);
    Xn = spdiags(Xn, 0, len, len);
    Ye = spdiags(Ye, 0, len, len);
    Yn = spdiags(Yn, 0, len, len);

    % Build 2D uniform nodal operator for m×n nodal grid (unit spacing)
    N1x = localNodal1D(k, m, 1);
    N1y = localNodal1D(k, n, 1);
    Ne = kron(speye(n, n), N1x);
    Nn = kron(N1y, speye(m, m));
    Nmat = [Ne; Nn];

    Ne = Nmat(1:len, :);
    Nn = Nmat(len+1:end, :);

    Nx = J * (Yn*Ne - Ye*Nn);
    Ny = J * (-Xn*Ne + Xe*Nn);
end

function [Nx, Ny, Nz] = localNodal3DCurv(k, X, Y, Z)
    [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z);

    [n, m, o] = size(X);
    len = n * m * o;

    J  = spdiags(1./J,           0, len, len);
    mA = spdiags(Yn.*Zc-Zn.*Yc, 0, len, len);
    mB = spdiags(Zn.*Xc-Xn.*Zc, 0, len, len);
    mC = spdiags(Xn.*Yc-Yn.*Xc, 0, len, len);
    mD = spdiags(Ze.*Yc-Ye.*Zc, 0, len, len);
    mE = spdiags(Xe.*Zc-Ze.*Xc, 0, len, len);
    mF = spdiags(Ye.*Xc-Xe.*Yc, 0, len, len);
    mG = spdiags(Ye.*Zn-Ze.*Yn, 0, len, len);
    mH = spdiags(Ze.*Xn-Xe.*Zn, 0, len, len);
    mI = spdiags(Xe.*Yn-Ye.*Xn, 0, len, len);

    % Build 3D uniform nodal operator for m×n×o nodal grid (unit spacing)
    N1x = localNodal1D(k, m, 1);
    N1y = localNodal1D(k, n, 1);
    N1z = localNodal1D(k, o, 1);
    Im = speye(m, m);
    In = speye(n, n);
    Io = speye(o, o);
    Ne = kron(kron(Io, In), N1x);
    Nn = kron(kron(Io, N1y), Im);
    Nc = kron(kron(N1z, In), Im);
    Nmat = [Ne; Nn; Nc];

    Ne = Nmat(1:len, :);
    Nn = Nmat(len+1:2*len, :);
    Nc = Nmat(2*len+1:end, :);

    Nx = J * (mA*Ne + mD*Nn + mG*Nc);
    Ny = J * (mB*Ne + mE*Nn + mH*Nc);
    Nz = J * (mC*Ne + mF*Nn + mI*Nc);
end

function N = localNodal1D(k, mNodes, dx)
    n_rows = mNodes;
    n_cols = mNodes;
    N = sparse(n_rows, n_cols);

    neighbors = zeros(1, k+1);
    neighbors(1) = -k/2;
    len = k+1;
    for i = 2:len
        neighbors(i) = neighbors(i-1) + 1;
    end
    A = vander(neighbors)';
    b = zeros(len, 1);
    b(len-1) = 1;
    coeffs = A \ b;

    j = 1;
    for i = k/2+1 : n_rows-k/2
        N(i, j:j+len-1) = coeffs;
        j = j + 1;
    end

    p = k/2;
    q = k+1;
    Abdy = sparse(p, q);
    for i = 1:p
        nb = zeros(1, q);
        nb(1) = 1 - i;
        for jj = 2:q
            nb(jj) = nb(jj-1) + 1;
        end
        V = vander(nb)';
        b2 = zeros(q, 1);
        b2(q-1) = 1;
        Abdy(i, 1:q) = (V \ b2)';
    end
    N(1:p, 1:q) = Abdy;

    Pp = fliplr(speye(p));
    Pq = fliplr(speye(q));
    N(n_rows-p+1:n_rows, n_cols-q+1:n_cols) = -Pp * Abdy * Pq;

    N = (1/dx) * N;
end
