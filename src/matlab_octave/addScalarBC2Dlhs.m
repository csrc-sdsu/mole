function [Abcl,Abcr,Abcb,Abct] = addScalarBC2Dlhs(k, m, dx, n, dy, dc, nc)
% PURPOSE
% This functions uses geometry and boundary type conditions to create
% modifications of matrix A associated to each of the boundary edges.
%
% DESCRIPTION
% Parameters:
% output
%      Abcl : Matrix coefficients associated to boundary conditions for left edge
%      Abcr : Matrix coefficients associated to boundary conditions for right edge
%      Abcb : Matrix coefficients associated to boundary conditions for bottom edge
%      Abct : Matrix coefficients associated to boundary conditions for top edge
%
% input
%         k : Order of accuracy
%         m : Number of the horizontal cells
%        dx : Step size
%         n : Number of the vertical cells
%        dy : Horizontal cell size
%        dc : a0 (4x1 vector for left, right, bottom, top boundaries, resp.)
%        nc : b0 (4x1 vector for left, right, bottom, top boundaries resp.)
%
% SYNTAX
% [Abcl,Abcr,Abcb,Abct] = addScalarBC2Dlhs(k, m, dx, n, dy, dc, nc)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    ensureMatlabOctaveSubdirs();
    [Abcl,Abcr,Abcb,Abct] = addScalarBC2Dlhs_impl(k, m, dx, n, dy, dc, nc);
end
