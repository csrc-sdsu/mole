function C = curlOp_impl(grid, k)
% PURPOSE
% Grid-first mimetic 2-D curl operator.
%
% DESCRIPTION
% Assembles the three-component discrete curl for a 2-D uniform grid.
% Row blocks: x-component (n*(m+1) rows), y-component ((n+1)*m rows),
% scalar z-curl (n*m rows).
%
% Parameters:
%   C    : Sparse matrix — 2-D mimetic curl operator
%   grid : Validated grid struct (must be dim=2)
%   k    : Order of accuracy (even integer >= 2)
%
% SYNTAX
% C = curlOp_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    grid = validateGrid(grid);

    assert(grid.dim == 2, ...
           'curlOp_impl:InvalidDim', 'curl is only implemented for 2-D grids');
    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k must be even');

    C = localCurl2D(k, grid.m, grid.dx, grid.n, grid.dy);
end

function C = localCurl2D(k, m, dx, n, dy)
% Two-dimensional mimetic curl operator.
% The 1st component is computed at horizontal faces (tangential vertical derivative)
% The 2nd component is computed at vertical faces (tangential horizontal derivative)
% The (scalar) curl or third component is computed at the cell centers (normal to the plane)

    C = sparse(n*(m+1)+(n+1)*m+n*m, (n+1)*m+n*(m+1)+(n+1)*(m+1));

    Dx = full(divNonPeriodic(k, m, dx));
    Dx = sparse(Dx(2:end-1,:));
    Dy = full(divNonPeriodic(k, n, dy));
    Dy = sparse(Dy(2:end-1,:));

    % first component
    C(1:(m+1)*n,(n+1)*m+n*(m+1)+1:end) = kron(Dy,speye(m+1,m+1));
    % second component
    C((m+1)*n+1:n*(m+1)+(n+1)*m,(n+1)*m+n*(m+1)+1:end) = - kron(speye(n+1,n+1),Dx);
    % third component
    C(m*(n+1)+(m+1)*n+1:end,1:m*(n+1)) = - kron(Dy,speye(m,m));
    C(m*(n+1)+(m+1)*n+1:end,m*(n+1)+1:m*(n+1)+n*(m+1)) = kron(speye(n,n),Dx);
end
