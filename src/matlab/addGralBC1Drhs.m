function b = addGralBC1Drhs(b, v, vec)
% This function uses the non-periodic boundary condition type of each vertex 
% and the rhs b values associated to left, and right vertices to modify the rhs vector b.
%
% Parameters:
% output
%         b : Right hand side with boundary conditions added
%
% input
%         b : Right hand side without boundary conditions added
%         v : value (2x1 vector for left and right vertices, resp.)
%       vec : vector with indices of rhs associated to bc

    % rhs for non-periodic boundary conditions
    b(vec) = v; 
end
