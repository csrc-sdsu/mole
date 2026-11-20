function [passed, total] = test_grad2D()
% PURPOSE
% Test two-dimensional gradient construction and axis ordering.
%
% SYNTAX
% test_grad2D()
% [passed, total] = test_grad2D()
%
% DESCRIPTION
% Runs independent cases in MATLAB or GNU Octave using the gradient test
% helpers. Checks sparse assembly, axis mapping, mixed periodicity, and
% errors specific to the two-dimensional interface.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    testDir = fileparts(mfilename('fullpath'));
    addpath(fileparts(testDir));
    gradient_test_setup();
    testFunctions = {@testAxisAssembly, @testLoggerForms, ...
        @testInvalidGrid, @testAxisCellCounts, @testUnsupportedTopology, ...
        @testInvalidDimension, @testInvalidPeriodicType, ...
        @testInvalidPeriodicCount};
    [passed, total] = run_gradient_test_cases(testFunctions);
    if nargout == 0 && passed ~= total
        error('MOLETests:Failed', '%d of %d gradient test cases failed.', total-passed, total);
    end
end

function testAxisAssembly()
    for k = [2,4,6,8]
        for px = [false,true]
            for py = [false,true]
                grid = grid_fixture(2*k,2*k+3,px,py);
                G = grad2D(k,grid);
                cx = grid.m+2*(~px);
                cy = grid.n+2*(~py);
                rows = (grid.m+~px)*grid.n+grid.m*(grid.n+~py);
                assert(issparse(G));
                assert(isequal(size(G),[rows,cx*cy]));
                [x,y] = axis_fixtures(grid);
                Gx = grad(k,x); Gy = grad(k,y);
                U = reshape(sin(1:size(G,2)),size(Gx,2),size(Gy,2));
                if py
                    xValues = Gx*U;
                else
                    xValues = Gx*U(:,2:end-1);
                end
                if px
                    yValues = U*Gy.';
                else
                    yValues = U(2:end-1,:)*Gy.';
                end
                expected = [xValues(:);yValues(:)];
                tolerance = 128*eps*max(1,norm(G,inf)*norm(U(:),inf));
                assert(norm(G*U(:)-expected,inf) <= tolerance);
            end
        end
    end
end

function testLoggerForms()
    grid = grid_fixture(9,11,false,true);
    errors = MOLE_errors();
    defaultOutput = evalc('G = grad2D(4,grid);');
    explicitOutput = evalc('reference = grad2D(4,grid,errors);');
    assert(isequal(G,reference));
    assert(isempty(defaultOutput) && isempty(explicitOutput));
    assert(errors.getNumErrors() == 0);
end

function testInvalidGrid()
    grid = grid_fixture(9,11,false,false);
    grid.valid = false;
    errors = MOLE_errors();
    expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_OP_GRID_HAS_ERRORS');
end

function testAxisCellCounts()
    counts = [7,11;11,7];
    for index = 1:size(counts,1)
        grid = grid_fixture(counts(index,1),counts(index,2),false,false);
        errors = MOLE_errors();
        expect_gradient_error(@() grad2D(4,grid,errors), ...
                              errors,'MOLE_ERR_OP_INSUFFICIENT_CELLS');
    end
end

function testUnsupportedTopology()
    grid = grid_fixture(9,11,false,false);
    grid.topology = 'curvilinear';
    errors = MOLE_errors();
    expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY');
end

function testInvalidDimension()
    grid = grid_fixture(9,11,false,false);
    grid.dim = 1;
    errors = MOLE_errors();
    expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_INVALID_GRID_DIM');
end

function testInvalidPeriodicType()
    grid = grid_fixture(9,11,false,false);
    grid.bc.isPeriodic = [0;1];
    errors = MOLE_errors();
    expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_ISPERIODIC_TYPE');
end

function testInvalidPeriodicCount()
    for flags = {false, false(3,1)}
        grid = grid_fixture(9,11,false,false);
        grid.bc.isPeriodic = flags{1};
        errors = MOLE_errors();
        expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_INVALID_ISPERIODIC_DIM');
    end
end

function grid = grid_fixture(m,n,px,py)
    grid = struct('dim',2,'topology','uniform','valid',true, ...
                  'm',m,'n',n,'dx',.125,'dy',.23, ...
                  'bc',struct('isPeriodic',[px;py]));
end

function [x,y] = axis_fixtures(grid)
    x = struct('dim',1,'topology',grid.topology,'valid',grid.valid, ...
               'm',grid.m,'dx',grid.dx,'bc',struct('isPeriodic',grid.bc.isPeriodic(1)));
    y = x;
    y.m = grid.n; y.dx = grid.dy;
    y.bc.isPeriodic = grid.bc.isPeriodic(2);
end
