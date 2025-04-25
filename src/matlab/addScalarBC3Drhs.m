function b = addScalarBC3Drhs(b, dc, nc, v, rl, rr, rb, rt, rf, rz)
% This function uses the boundary condition type of each face and the rhs b 
% indices and values associated to left, right, bottom, top, front, back 
% faces to modify the rhs vector b.
%
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
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------    
%

    % rhs for non-periodic boundary conditions (assumes data given in cell array)
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    if ~isempty(qrl)
        b(rl,1) = v{1}; % left boundary
        b(rr,1) = v{2}; % right boundary
    end

    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    if ~isempty(qbt)
        b(rb,1) = v{3}; % bottom boundary
        b(rt,1) = v{4}; % top boundary
    end

    qzf = find(dc(5:6).*dc(5:6) + nc(5:6).*nc(5:6),1);
    if ~isempty(qzf)
        b(rf,1) = v{5}; % back boundary
        b(rz,1) = v{6}; % front boundary
    end
end
