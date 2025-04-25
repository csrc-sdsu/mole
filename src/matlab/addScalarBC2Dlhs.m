function [Abcl,Abcr,Abcb,Abct] = addScalarBC2Dlhs(k, m, dx, n, dy, dc, nc)
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
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
%

    Abcl = 0; Abcr = 0; Abcb = 0; Abct = 0; % periodic case

    % A and b changes depend on whether bc is periodic or not in each axis
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);

    % 2D boundary operator
    if ~isempty(qrl)    
        [Abcl0,Abcr0] = addScalarBC1Dlhs(k, m, dx, dc(1:2,1), nc(1:2,1));
        if isempty(qbt)
            In = speye(n);
        else
            In = speye(n+2);
            In(1, 1) = 0;
            In(end, end) = 0; 
        end
        % left and right edges
        Abcl = kron(In, Abcl0);
        Abcr = kron(In, Abcr0);
    end

    if ~isempty(qbt)    
        [Abcb0,Abct0] = addScalarBC1Dlhs(k, n, dy, dc(3:4,1), nc(3:4,1));
        if isempty(qrl) 
            Im = speye(m);
        else
            Im = speye(m+2);
        end
        % bottom and top edges
        Abcb = kron(Abcb0, Im);
        Abct = kron(Abct0, Im);
    end    
end
