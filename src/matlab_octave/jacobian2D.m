function [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y)
% PURPOSE
%
% DESCRIPTION
% Returns:
%                J : Determinant of the Jacobian (XeYn - XnYe)
%               Xe : dx/de metric
%               Xn : dx/dn metric
%               Ye : dy/de metric
%               Yn : dy/dn metric
%
% Parameters:
%                k : Order of accuracy
%                X : x-coordinates (physical) of meshgrid
%                Y : y-coordinates (physical) of meshgrid
%             grid : Struct carrying grid.X and grid.Y.
%
% SYNTAX
% [J, Xe, Xn, Ye, Yn] = jacobian2D(grid, k)
% [J, Xe, Xn, Ye, Yn] = jacobian2D(k, X, Y)
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
        X = grid.X;
        Y = grid.Y;
    end

    [n, m] = size(X);
    
    X = reshape(X', [], 1);
    Y = reshape(Y', [], 1);
    
    N = localNodalUniform2D(k, m, n);

    X = N*X;
    Y = N*Y;

    mn = m*n;

    Xe = X(1:mn);
    Xn = X(mn+1:end);
    Ye = Y(1:mn);
    Yn = Y(mn+1:end);

    J = Xe.*Yn-Xn.*Ye;
end

function N = localNodalUniform2D(k, m, n)
% Stacked [Nx; Ny] uniform 2-D nodal derivative operator on unit spacing.

    Nx = localNodal1D(k, m, 1);
    Ny = localNodal1D(k, n, 1);
    Im = speye(m, m);
    In = speye(n, n);
    N = [kron(In, Nx); kron(Ny, Im)];
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