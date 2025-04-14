function [A, b] = addScalarBC3D(A, b, k, m, dx, n, dy, o, dz, dc, nc, v)
% This function assumes that the unknown u, which represents the discrete
% solution the continuous second-order 3D PDE operator 
%                                   L U = f, 
% with continuous boundary condition 
%                              a0 U + b0 dU/dn = g,
% are given at the 3D cell centers and boundary face centers. Furthermore,
% all discrete calculations are performed at the 3D cell centers and boundary 
% face centers.
%
% The function receives as input quantities associated to the discrete
% analog of the continuous problem given by the squared linear system 
%                                 A u = b 
% where A is the discrete analog of L and b is the discrete analog of g,
% both constructed by the user without boundary conditions.
% The function output is the modified square linear system 
%                                 A u = b
% where both A and b include boundary condition information.
%
% The boundary condition is always one of the following forms:
%
% For Dirichlet set: a0 not equal zero and b0 = 0.
% For Neumann set  : a0 = 0 and b0 not equal zero.
% For Robin set    : both a0 and b0 not equal zero.
% For Periodic set : both a0 = 0 and b0 = 0.
%
% For periodic bc, it is assumed that not only u but also du/dn are the same 
% in both extremes of the domain since a second-order PDE is assumed.
%
% Periodic boundary conditions can be applied along some axes and
% non-periodic to some others.
% 
% For consistence with the way boundary operators are calculated to avoid 
% overwriting of the values v, the left and right boundary conditions are
% assumed to be column vectors of n*o components, the bottom and top
% boundary conditions are assumed to be column vectors of (m+2)*o
% components, and the front and back faces are assumed to be vectors of
% (m+2)*(n+2) components. 
%
% The order of these components is as follows:
% For left and right faces, the ordering is the one by columns of the
% matrix where y increase along rows, and z increase along columns.
% For bottom and top faces, the ordering is the one by columns of the
% matrix where x increase along rows, and z increase along columns.
% For front and back faces, the ordering is the one by columns of the
% matrix where x increase along rows, and y increase along columns.
% 
% The code assumes the following assertions:
% assert(k >= 2, 'k >= 2');
% assert(mod(k, 2) == 0, 'k % 2 = 0');
% assert(m >= 2*k+1, ['m >= ' num2str(2*k+1) ' for k = ' num2str(k)]);
%
% Parameters:
% output
%         A : Linear operator with boundary conditions added
%         b : Right hand side with boundary conditions added
%
% input
%         A : Linear operator without boundary conditions added
%         b : Right hand side without boundary conditions added
%         k : Order of accuracy
%         m : Number of horizontal cells
%        dx : Step size of horizontal
%         n : Number of vertical cells
%        dy : Step size of vertical cells
%         o : Number of depth cells
%        dz : Step size of depth cells
%        dc : a0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%        nc : b0 (6x1 vector for left, right, bottom, top, front, back boundary types, resp.)
%         v : g (6x1 vector of arrays for left, right, bottom, top, front, back boundaries, resp.)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------    
%

    % verify bc sizes and square linear system
    cellsz = cellfun(@size,v,'uni',false);
    assert(all(size(dc) == [6 1]), 'dc is a 6x1 vector');
    assert(all(size(nc) == [6 1]), 'nc is a 6x1 vector');
    assert(all(size(v) == [6 1]), 'v is a 6x1 vector');
    assert(all(size(A,1) == size(A,2)), 'A is a square matrix');
    assert(all(size(A,2) == numel(b)), 'b size = A columns');

    % A and b changes depend on whether bc is periodic or not in each axis
    qrl = find(dc(1:2).*dc(1:2) + nc(1:2).*nc(1:2),1);
    qbt = find(dc(3:4).*dc(3:4) + nc(3:4).*nc(3:4),1);
    qzf = find(dc(5:6).*dc(5:6) + nc(5:6).*nc(5:6),1);

    if ~isempty(qrl)    
        assert(all(cellsz{1} == [o*n 1]), 'v{1} is a (o*n)x1 vector'); % left
        assert(all(cellsz{2} == [o*n 1]), 'v{2} is a (o*n)x1 vector'); % right
    end

    if ~isempty(qbt)    
        if ~isempty(qrl)    
            assert(all(cellsz{3} == [o*(m+2) 1]), 'v{3} is a (o*(m+2))x1 vector'); % bottom
            assert(all(cellsz{4} == [o*(m+2) 1]), 'v{4} is a (o*(m+2))x1 vector'); % top
        else
            assert(all(cellsz{3} == [o*m 1]), 'v{3} is a (o*m)x1 vector'); % bottom
            assert(all(cellsz{4} == [o*m 1]), 'v{4} is a (o*m)x1 vector'); % top
        end
    end

    if ~isempty(qzf)    
        if ~isempty(qrl)    
            if ~isempty(qbt)
                assert(all(cellsz{5} == [(n+2)*(m+2) 1]), 'v{5} is a ((n+2)*(m+2))x1 vector'); % front
                assert(all(cellsz{6} == [(n+2)*(m+2) 1]), 'v{6} is a ((n+2)*(m+2))x1 vector'); % back
            else
                assert(all(cellsz{5} == [n*(m+2) 1]), 'v{5} is a (n*(m+2))x1 vector'); % front
                assert(all(cellsz{6} == [n*(m+2) 1]), 'v{6} is a (n*(m+2))x1 vector'); % back
            end
        else
            if ~isempty(qbt)
                assert(all(cellsz{5} == [(n+2)*m 1]), 'v{5} is a ((n+2)*m)x1 vector'); % front
                assert(all(cellsz{6} == [(n+2)*m 1]), 'v{6} is a ((n+2)*m)x1 vector'); % back
            else
                assert(all(cellsz{5} == [n*m 1]), 'v{5} is a (n*m)x1 vector'); % front
                assert(all(cellsz{6} == [n*m 1]), 'v{6} is a (n*m)x1 vector'); % back
            end
        end
    end

    rl = 0; rr = 0; rb = 0; rt = 0; rf = 0; rz = 0; % periodic case

    % get modifications of A for left, right, bottom, top, front, back faces, resp.
    [Abcl,Abcr,Abcb,Abct,Abcf,Abcz] = addScalarBC3Dlhs(k, m, dx, n, dy, o, dz, dc, nc);

    % get rhs entries affected by bcs for left, right, bottom, top, front, back faces, resp.
    if ~isempty(qrl)    
        [rl,~,~] = find(Abcl);
        [rr,~,~] = find(Abcr);
        rl = unique(rl);
        rr = unique(rr);
        % remove rows of A associated to boundary
        Abc1 = Abcl + Abcr;
        [rowsbc1,~,~] = find(Abc1);
        [rows1,cols1,s1] = find(A(rowsbc1,:));
        A = A - sparse(rows1, cols1, s1, size(A,1), size(A,2));
        % update matrix A with boundary information
        A = A + Abc1;    
        % remove b entries associated to bcs
        b(rowsbc1) = 0;    
    end

    if ~isempty(qbt)
        [rb,~,~] = find(Abcb);
        [rt,~,~] = find(Abct);
        rb = unique(rb);
        rt = unique(rt);
        % remove rows of A associated to boundary
        Abc2 = Abct + Abcb;
        [rowsbc2,~,~] = find(Abc2);
        [rows2,cols2,s2] = find(A(rowsbc2,:));
        A = A - sparse(rows2, cols2, s2, size(A,1), size(A,2));
        % update matrix A with boundary information
        A = A + Abc2;
        % remove b entries associated to bcs
        b(rowsbc2) = 0;    
    end

    if ~isempty(qzf)    
        [rz,~,~] = find(Abcz);
        [rf,~,~] = find(Abcf);
        rf = unique(rf);
        rz = unique(rz);
        % remove rows of A associated to boundary
        Abc3 = Abcf + Abcz;
        [rowsbc3,~,~] = find(Abc3);
        [rows3,cols3,s3] = find(A(rowsbc3,:));
        A = A - sparse(rows3, cols3, s3, size(A,1), size(A,2));
        % update matrix A with boundary information
        A = A + Abc3;    
        % remove b entries associated to bcs
        b(rowsbc3) = 0;    
    end

    % update b with boundary information
    if ~(isempty(qrl) && isempty(qbt) && isempty(qzf))  
        b = addScalarBC3Drhs(b, dc, nc, v, rl, rr, rb, rt, rf, rz);
    end
end
