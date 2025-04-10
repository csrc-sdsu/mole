function [Al, Ar] = addScalarBC1Dlhs(k, m, dx, dc, nc)
% This functions uses geometry and boundary type conditions to create
% modifications of matrix A associated to each of the boundary faces.
%
% Parameters:
% output
%        Al : modification of matrix A due to left boundary condition
%        Ar : modification of matrix A due to right boundary condition
%
% input
%         k : Order of accuracy
%         m : Number of cells
%        dx : Step size
%        dc : Dirichlet coefficient (2x1 vector for left and right vertices, resp.)
%        nc : Neumann coefficient (2x1 vector for left and right vertices, resp.)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    % Dirichlet coefficient
    Al = sparse(m+2, m+2);
    Ar = sparse(m+2, m+2);
    if dc(1,1) ~= 0; Al(1,1) = dc(1,1); end
    if dc(2,1) ~= 0; Ar(end,end) = dc(2,1); end

    % Neumann coefficient
    Bl = sparse(m+2, m+1);
    Br = sparse(m+2, m+1);
    Gl = grad(k, m, dx); 
    Gr = grad(k, m, dx); 
    if nc(1,1) ~= 0; Bl(1,1) = -nc(1,1); end
    if nc(2,1) ~= 0; Br(end,end) = nc(2,1); end  
    
    % Robin coefficients
    Al = Al + Bl*Gl;
    Ar = Ar + Br*Gr;
end
