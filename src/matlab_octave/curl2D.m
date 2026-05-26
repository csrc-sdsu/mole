% SPDX-License-Identifier: GPL-3.0-only
% 
% Copyright 2008-2024 San Diego State University Research Foundation (SDSURF).
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% LICENSE file or on the web GNU General Public License 
% <https://www.gnu.org/licenses/> for more details.
%
% ------------------------------------------------------------------------
function C = curl2D(k, m, dx, n, dy)
% Returns a two-dimensional mimetic curl operator
% The 1st component is computed at horizontal faces (tangential vertical derivative)
% The 2nd component is computed at vertical faces (tangential horizontal derivative)
% The (scalar) curl or third component is computed at the cell centers (normal to the plane)
%
% Parameters:
%                k : Order of accuracy
%                m : Number of cells along x-axis
%               dx : Step size along x-axis
%                n : Number of cells along y-axis
%               dy : Step size along y-axis

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
