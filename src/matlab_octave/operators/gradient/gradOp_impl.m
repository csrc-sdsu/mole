function G = gradOp_impl(grid, k)
% PURPOSE
% Grid-first mimetic gradient operator for 1-D, 2-D, and 3-D uniform grids.
%
% DESCRIPTION
% This operator consumes a validated grid struct and dispatches to the
% appropriate dimensional assembly while preserving periodic-axis behavior
% through grid.bc.isPeriodic.
%
% SYNTAX
% G = gradOp_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    grid = validateGrid(grid);

    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');

    switch grid.dim
    case 1
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        if grid.bc.isPeriodic
            G = gradPeriodic(k, grid.m, grid.dx);
        else
            G = gradNonPeriodic(k, grid.m, grid.dx);
        end

    case 2
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.topology, 'curvilinear')
            G = gradCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
            Gx = gradPeriodic(k, grid.m, grid.dx);
            Im = speye(grid.m, grid.m);
        else
            Gx = gradNonPeriodic(k, grid.m, grid.dx);
            Im = sparse(grid.m+2, grid.m);
            Im(2:(grid.m+2)-1, :) = speye(grid.m, grid.m);
        end

        if grid.bc.isPeriodic(2)
            Gy = gradPeriodic(k, grid.n, grid.dy);
            In = speye(grid.n, grid.n);
        else
            Gy = gradNonPeriodic(k, grid.n, grid.dy);
            In = sparse(grid.n+2, grid.n);
            In(2:(grid.n+2)-1, :) = speye(grid.n, grid.n);
        end

        Sx = kron(In', Gx);
        Sy = kron(Gy, Im');
        G = [Sx; Sy];

    case 3
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.o >= 2*k, ['o >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.topology, 'curvilinear')
            G = gradCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
            Gx = gradPeriodic(k, grid.m, grid.dx);
            Im = speye(grid.m, grid.m);
        else
            Gx = gradNonPeriodic(k, grid.m, grid.dx);
            Im = sparse(grid.m+2, grid.m);
            Im(2:(grid.m+2)-1, :) = speye(grid.m, grid.m);
        end

        if grid.bc.isPeriodic(2)
            Gy = gradPeriodic(k, grid.n, grid.dy);
            In = speye(grid.n, grid.n);
        else
            Gy = gradNonPeriodic(k, grid.n, grid.dy);
            In = sparse(grid.n+2, grid.n);
            In(2:(grid.n+2)-1, :) = speye(grid.n, grid.n);
        end

        if grid.bc.isPeriodic(3)
            Gz = gradPeriodic(k, grid.o, grid.dz);
            Io = speye(grid.o, grid.o);
        else
            Gz = gradNonPeriodic(k, grid.o, grid.dz);
            Io = sparse(grid.o+2, grid.o);
            Io(2:(grid.o+2)-1, :) = speye(grid.o, grid.o);
        end

        Sx = kron(kron(Io', In'), Gx);
        Sy = kron(kron(Io', Gy), Im');
        Sz = kron(kron(Gz, In'), Im');
        G = [Sx; Sy; Sz];

    otherwise
        error('gradOp:InvalidDim', 'grid.dim must be 1, 2, or 3');
    end
end