function b = addBC1Drhs(b, dc, nc, v, vec)
% This function uses the boundary condition type of each vertex and the rhs b 
% values associated to left, and right vertices to modify the rhs vector b.
%
% Parameters:
% output
%         b : Right hand side with boundary conditions added
%
% input
%         b : Right hand side without boundary conditions added
%        dc : Dirichlet coefficient (2x1 vector for left and right vertices, resp.)
%        nc : Neumann coefficient (2x1 vector for left and right vertices, resp.)
%         v : value (2x1 vector for left and right vertices, resp.)
%       vec : vector with indices of rhs associated to bc

    % periodic boundary condition case
    q = find(dc.*dc + nc.*nc,1);
    if ~isempty(q)
        % rhs for non-periodic boundary conditions
        b(vec) = v; 
    end
end
