function N = nodal(k, m, dx)
% Returns a m+1 by m+1 one-dimensional operator that approximates the 
% first-order derivatives on a uniform nodal grid
%
% Parameters:
%                k : Order of accuracy
%                m : Number of nodes
%               dx : Step size
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    m = m-1;
    n_rows = m+1;
    n_cols = n_rows;

    N = sparse(n_rows, n_cols);

    neighbors = zeros(1, k+1); % Bandwidth = k+1
    neighbors(1) = -k/2;
    len = k+1;
    j = 1;

    for i = 2 : len
        neighbors(i) = neighbors(i-1)+1;
    end

    % Create a k by k Vandermonde matrix based on the neighbors:
    A = vander(neighbors)';

    % First-order derivative
    b = zeros(len, 1);
    b(len-1) = 1;

    % Solve the linear system to get the coefficients
    coeffs = A\b;

    for i = k/2+1 : n_rows-k/2
        N(i, j:j+len-1) = coeffs;
        j = j+1;
    end

    p = k/2;
    q = k+1;
    A = sparse(p, q);
    for i = 1 : p % For each row of A
        neighbors = zeros(1, q); % k+1 points are used for the boundaries
        neighbors(1) = 1-i; % Shifting the stencil to the right
        neighbors(2) = neighbors(1)+1;

        for j = 3 : q
            neighbors(j) = neighbors(j-1)+1;
        end

        V = vander(neighbors)';
        b = zeros(q, 1);
        b(q-1) = 1;
        coeffs = V\b;
        A(i, 1:q) = coeffs;
    end

    % Insert A into N (upper-left corner of N)
    N(1:p, 1:q) = A;

    % Permutation matrices
    Pp = fliplr(speye(p));
    Pq = fliplr(speye(q));
    % Construct A' (lower-right corner of N)
    A = -Pp*A*Pq;

    % Insert A' into N
    N(n_rows-p+1:n_rows, n_cols-q+1:n_cols) = A;

    % Scale N
    N = 1/dx*N;
end
