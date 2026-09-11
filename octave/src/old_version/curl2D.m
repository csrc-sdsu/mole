function C = curl2D(k, m, dx, n, dy)
% PURPOSE
% Returns a two-dimensional mimetic curl operator
%
% DESCRIPTION
% Parameters:
% output
%        C : 2D curl operator with 3 components.
%            The 1st component is computed at horizontal faces 
%            (tangential vertical derivative)
%            The 2nd component is computed at vertical faces 
%            (tangential horizontal derivative)
%            The third component or (scalar) curl is computed 
%            at the cell centers (normal to the plane)
%
% input
%         k : Order of accuracy
%         m : Number of cells along x-axis
%        dx : Step size along x-axis
%         n : Number of cells along y-axis
%        dy : Step size along y-axis
%
% SYNTAX
% C = curl2D(k, m, dx, n, dy)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
% 

    C = sparse(n*(m+1)+(n+1)*m+n*m, (n+1)*m+n*(m+1)+(n+1)*(m+1));

    Dx = div(k, m, dx);
    Dx = Dx(2:end-1,:);
    Dy = div(k, n, dy);
    Dy = Dy(2:end-1,:);

    % first component
    C(1:(m+1)*n,(n+1)*m+n*(m+1)+1:end) = kron(Dy,speye(m+1,m+1));
    % second component
    C((m+1)*n+1:n*(m+1)+(n+1)*m,(n+1)*m+n*(m+1)+1:end) = - kron(speye(n+1,n+1),Dx);
    % third component
    C(m*(n+1)+(m+1)*n+1:end,1:m*(n+1)) = - kron(Dy,speye(m,m));
    C(m*(n+1)+(m+1)*n+1:end,m*(n+1)+1:m*(n+1)+n*(m+1)) = kron(speye(n,n),Dx);
end
