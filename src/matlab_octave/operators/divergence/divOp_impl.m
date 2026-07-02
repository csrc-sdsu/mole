function [D, err] = divOp_impl(grid, k)
% PURPOSE
% Grid-first mimetic divergence operator for 1-D, 2-D, and 3-D uniform grids.
%
% DESCRIPTION
% This operator consumes a validated grid struct and dispatches to the
% appropriate dimensional assembly while preserving periodic-axis behavior
% through grid.bc.isPeriodic.
%
% SYNTAX
% D = divOp_impl(grid, k)
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    grid = validateGrid(grid);
    err = grid.error;
    if err.hasError
        D = [];
        return;
    end

    assert(k >= 2, 'k >= 2');
    assert(mod(k, 2) == 0, 'k % 2 = 0');

    switch grid.dim
    case 1
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        if grid.bc.isPeriodic
            D = divPeriodic(k, grid.m, grid.dx);
        else
            D = divNonPeriodic(k, grid.m, grid.dx);
        end

    case 2
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.type, 'curvilinear')
            D = divCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
            Dx = divPeriodic(k, grid.m, grid.dx);
            Im = speye(grid.m, grid.m);
        else
            Dx = divNonPeriodic(k, grid.m, grid.dx);
            Im = sparse(grid.m+2, grid.m);
            Im(2:(grid.m+2)-1, :) = speye(grid.m, grid.m);
        end

        if grid.bc.isPeriodic(2)
            Dy = divPeriodic(k, grid.n, grid.dy);
            In = speye(grid.n, grid.n);
        else
            Dy = divNonPeriodic(k, grid.n, grid.dy);
            In = sparse(grid.n+2, grid.n);
            In(2:(grid.n+2)-1, :) = speye(grid.n, grid.n);
        end

        Sx = kron(In, Dx);
        Sy = kron(Dy, Im);
        D = [Sx Sy];

    case 3
        assert(grid.m >= 2*k, ['m >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.n >= 2*k, ['n >= ' num2str(2*k) ' for k = ' num2str(k)]);
        assert(grid.o >= 2*k, ['o >= ' num2str(2*k) ' for k = ' num2str(k)]);

        if strcmpi(grid.type, 'curvilinear')
            D = divCurv_impl(grid, k);
            return;
        end

        if grid.bc.isPeriodic(1)
            Dx = divPeriodic(k, grid.m, grid.dx);
            Im = speye(grid.m, grid.m);
        else
            Dx = divNonPeriodic(k, grid.m, grid.dx);
            Im = sparse(grid.m+2, grid.m);
            Im(2:(grid.m+2)-1, :) = speye(grid.m, grid.m);
        end

        if grid.bc.isPeriodic(2)
            Dy = divPeriodic(k, grid.n, grid.dy);
            In = speye(grid.n, grid.n);
        else
            Dy = divNonPeriodic(k, grid.n, grid.dy);
            In = sparse(grid.n+2, grid.n);
            In(2:(grid.n+2)-1, :) = speye(grid.n, grid.n);
        end

        if grid.bc.isPeriodic(3)
            Dz = divPeriodic(k, grid.o, grid.dz);
            Io = speye(grid.o, grid.o);
        else
            Dz = divNonPeriodic(k, grid.o, grid.dz);
            Io = sparse(grid.o+2, grid.o);
            Io(2:(grid.o+2)-1, :) = speye(grid.o, grid.o);
        end

        Sx = kron(kron(Io, In), Dx);
        Sy = kron(kron(Io, Dy), Im);
        Sz = kron(kron(Dz, In), Im);
        D = [Sx Sy Sz];

    otherwise
        error('divOp:InvalidDim', 'grid.dim must be 1, 2, or 3');
    end
end