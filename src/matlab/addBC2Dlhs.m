function [Abcl,Abcr,Abcb,Abct] = addBC2Dlhs(k, m, dx, n, dy, dc, nc)
% This functions uses geometry and boundary type conditions to create
% modifications of matrix A associated to each of the boundary edges.
%
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

    % 2D boundary operator
    [Abcl0,Abcr0] = addBC1Dlhs(k, m, dx, dc(1:2,1), nc(1:2,1));
    [Abcb0,Abct0] = addBC1Dlhs(k, n, dy, dc(3:4,1), nc(3:4,1));
    
    Im = speye(m+2);
    
    In = speye(n+2);
    In(1, 1) = 0;
    In(end, end) = 0;
    
    % left and right edges
    Abcl = kron(In, Abcl0);
    Abcr = kron(In, Abcr0);
    % bottom and top edges
    Abcb = kron(Abcb0, Im);
    Abct = kron(Abct0, Im);
end
