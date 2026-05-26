function [Al, Ar] = addScalarBC1Dlhs(k, m, dx, dc, nc)
% PURPOSE
% This functions uses geometry and boundary type conditions to create
% modifications of matrix A associated to each of the boundary faces.
%
% DESCRIPTION
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
% SYNTAX
% [Al, Ar] = addScalarBC1Dlhs(k, m, dx, dc, nc)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    ensureMatlabOctaveSubdirs();
    [Al, Ar] = addScalarBC1Dlhs_impl(k, m, dx, dc, nc);
end
