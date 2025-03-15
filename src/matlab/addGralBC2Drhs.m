function b = addGralBC2Drhs(b, dc, nc, v, rl, rr, rb, rt)
% function b = addBC2Drhs(b, m, n, dc, nc, v, vec)
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
%        dc : a0 (4x1 vector for left, right, bottom, top boundary types, resp.)
%        nc : b0 (4x1 vector for left, right, bottom, top boundary types, resp.)
%         v : g (4x1 vector of arrays for left, right, bottom, top boundaries, resp.)
%        rl : indices of rhs left indices    
%        rr : indices of rhs right indices    
%        rb : indices of rhs bottom indices    
%        rt : indices of rhs top indices    
%        vec: vector with indices of rhs associated to bc
    
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
end
