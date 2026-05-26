function [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addScalarBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc)
% PURPOSE
% This functions uses geometry and boundary type conditions to create
% modifications of matrix A associated to each of the boundary faces.
%
% DESCRIPTION
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
%
% SYNTAX
% [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addScalarBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------    
%

    ensureMatlabOctaveSubdirs();
    [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addScalarBC3Dlhs_impl(k, m, dx, n, dy, o, dz, dc, nc);
end
