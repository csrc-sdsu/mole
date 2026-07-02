function [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z)
% PURPOSE
%
% DESCRIPTION
% Returns:
%                J : Determinant of the Jacobian
%               Xe : dx/de metric
%               Xn : dx/dn metric
%               Xc : dx/dc metric
%               Ye : dy/de metric
%               Yn : dy/dn metric
%               Yc : dy/dc metric
%               Ze : dz/de metric
%               Zn : dz/dn metric
%               Zc : dz/dc metric
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid
%                Y : y-coordinates (physical) of meshgrid
%                Z : z-coordinates (physical) of meshgrid
%             grid : Struct carrying grid.X, grid.Y, and grid.Z.
%
% SYNTAX
% [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(grid, k)
% [J, Xe, Xn, Xc, Ye, Yn, Yc, Ze, Zn, Zc] = jacobian3D(k, X, Y, Z)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    
    if nargin == 2 && isstruct(k)
        grid = k;
        k = X;

        assert(isfield(grid, 'X'), 'grid.X is required');
        assert(isfield(grid, 'Y'), 'grid.Y is required');
        assert(isfield(grid, 'Z'), 'grid.Z is required');
        X = grid.X;
        Y = grid.Y;
        Z = grid.Z;
    end

    [n, m, o] = size(X);
    
    X = reshape(permute(X, [2, 1, 3]), [], 1);
    Y = reshape(permute(Y, [2, 1, 3]), [], 1);
    Z = reshape(permute(Z, [2, 1, 3]), [], 1);
    
    N = localNodalUniform3D(k, m, n, o);

    X = N*X;
    Y = N*Y;
    Z = N*Z;

    mno = m*n*o;

    Xe = X(1:mno);
    Xn = X(mno+1:2*mno);
    Xc = X(2*mno+1:end);
    Ye = Y(1:mno);
    Yn = Y(mno+1:2*mno);
    Yc = Y(2*mno+1:end);
    Ze = Z(1:mno);
    Zn = Z(mno+1:2*mno);
    Zc = Z(2*mno+1:end);

    J = Xe.*(Yn.*Zc-Yc.*Zn)-Ye.*(Xn.*Zc-Xc.*Zn)+Ze.*(Xn.*Yc-Xc.*Yn);
end

function N = localNodalUniform3D(k, m, n, o)
% Stacked [Nx; Ny; Nz] uniform 3-D nodal derivative operator on unit spacing.

    Nx = localNodal1D(k, m, 1);
    Ny = localNodal1D(k, n, 1);
    Nz = localNodal1D(k, o, 1);
    Im = speye(m, m);
    In = speye(n, n);
    Io = speye(o, o);
    Sx = kron(kron(Io, In), Nx);
    Sy = kron(kron(Io, Ny), Im);
    Sz = kron(kron(Nz, In), Im);
    N = [Sx; Sy; Sz];
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