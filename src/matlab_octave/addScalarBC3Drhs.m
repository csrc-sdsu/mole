function b = addScalarBC3Drhs(b, dc, nc, v, rl, rr, rb, rt, rf, rz)
% PURPOSE
% This function uses the boundary condition type of each face and the rhs b 
% indices and values associated to left, right, bottom, top, front, back 
% faces to modify the rhs vector b.
%
% DESCRIPTION
% Parameters:
% output
%         b : Right hand side with boundary conditions added
%
% input
%         b : Right hand side without boundary conditions added
%        dc : a0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%        nc : b0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%         v : g (6x1 vector of arrays for left, right, bottom, top, front, back boundaries, resp.)
%        rl : indices of rhs left indices    
%        rr : indices of rhs right indices    
%        rb : indices of rhs bottom indices    
%        rt : indices of rhs top indices    
%        rf : indices of rhs front indices    
%        rz : indices of rhs back indices  
%
% SYNTAX
% b = addScalarBC3Drhs(b, dc, nc, v, rl, rr, rb, rt, rf, rz)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------    
%

    ensureMatlabOctaveSubdirs();
    b = addScalarBC3Drhs_impl(b, dc, nc, v, rl, rr, rb, rt, rf, rz);
end
