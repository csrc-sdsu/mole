function [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc)
% This functions uses geometry and boundary type conditions to create
% modifications of matrix A associated to each of the boundary faces.
%
% Parameters:
% output
%      Abcl : Matrix coefficients associated to boundary conditions for left face
%      Abcr : Matrix coefficients associated to boundary conditions for right face
%      Abcb : Matrix coefficients associated to boundary conditions for bottom face
%      Abct : Matrix coefficients associated to boundary conditions for top face
%      Abcf : Matrix coefficients associated to boundary conditions for front face
%      Abcz : Matrix coefficients associated to boundary conditions for back face
%
% input
%         k : Order of accuracy
%         m : Number of the horizontal cells
%        dx : Step size
%         n : Number of the vertical cells
%        dy : Horizonttal cell size
%         o : Number of the depth cells
%        dz : Depth cell size
%        dc : a0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%        nc : b0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % 3D boundary operator
    [Abcl0,Abcr0] = addBC1Dlhs(k, m, dx, dc(1:2,1), nc(1:2,1));
    [Abcb0,Abct0] = addBC1Dlhs(k, n, dy, dc(3:4,1), nc(3:4,1));
    [Abcf0,Abcz0] = addBC1Dlhs(k, o, dz, dc(5:6,1), nc(5:6,1));
    
    Im = speye(m+2);
    
    In = speye(n+2);
    
    Io = speye(o+2);
    Io(1, 1) = 0;
    Io(end, end) = 0;
    
    In2 = In;
    In2(1, 1) = 0;
    In2(end, end) = 0;
    
    % left and right faces
    Abcl = kron(kron(Io, In2), Abcl0);
    Abcr = kron(kron(Io, In2), Abcr0);
    % bottom and top faces
    Abcb = kron(kron(Io, Abcb0), Im);
    Abct = kron(kron(Io, Abct0), Im);
    % front and back faces
    Abcf = kron(kron(Abcf0, In), Im);
    Abcz = kron(kron(Abcz0, In), Im);
end
