function [passed, total, testFunctions] = test_grad2D(runTests)
% PURPOSE
% Test two-dimensional gradient construction and axis ordering.
%
% SYNTAX
% test_grad2D()
% [passed, total] = test_grad2D()
% [~, total, testFunctions] = test_grad2D(false)
%
% DESCRIPTION
% Runs independent cases in GNU Octave using the gradient test helpers.
% Checks sparse assembly, axis mapping, mixed periodicity, and errors
% specific to the two-dimensional interface.
% Passing false lists case handles without executing them.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    % Reuse helpers from the sibling one-dimensional gradient test folder.
    testDir = fileparts(mfilename('fullpath'));
    addpath(fullfile(fileparts(testDir), 'gradient'));
    if nargin < 1
        runTests = true;
    elseif ~islogical(runTests) || ~isscalar(runTests)
        error('MOLETests:InvalidInput', 'runTests must be a logical scalar.');
    end
    % Register case handles for direct execution and CI discovery.
    testFunctions = {@testAxisAssembly, @testLoggerForms, ...
        @testInvalidGrid, @testAxisCellCounts, @testUnsupportedTopology, ...
        @testInvalidDimension, @testInvalidPeriodicCount};
    total = numel(testFunctions);
    % Discovery returns the case list without constructing operators.
    if ~runTests
        passed = 0;
        return;
    end
    % Configure source paths, then collect the per-case results.
    gradient_test_setup();
    [passed, total] = run_gradient_test_cases(testFunctions);
    % A CLI call without outputs must fail when any case fails.
    if nargout == 0 && passed ~= total
        error('MOLETests:Failed', '%d of %d gradient test cases failed.', total-passed, total);
    end
end

function testAxisAssembly()
    % Cover every supported order and all x/y periodicity combinations.
    for k = [2,4,6,8]
        for px = [false,true]
            for py = [false,true]
                % Unequal axis sizes and spacings expose swapped-axis errors.
                grid = grid_fixture(2*k,2*k+3,px,py);
                G = grad2D(k,grid);
                % Nonperiodic axes include two boundary values in the input.
                cx = grid.m+2*(~px);
                cy = grid.n+2*(~py);
                % Count x- and y-face outputs; periodic seams are not repeated.
                rows = (grid.m+~px)*grid.n+grid.m*(grid.n+~py);
                assert(issparse(G));
                assert(isequal(size(G),[rows,cx*cy]));
                % Form the reference by applying the existing 1D operators.
                [x,y] = axis_fixtures(grid);
                Gx = grad(k,x); Gy = grad(k,y);
                % Use a deterministic field that varies along both axes.
                U = reshape(sin(1:size(G,2)),size(Gx,2),size(Gy,2));
                % Differentiate each column in x, omitting y-boundary padding.
                if py
                    xValues = Gx*U;
                else
                    xValues = Gx*U(:,2:end-1);
                end
                % Differentiate each row in y, omitting x-boundary padding.
                if px
                    yValues = U*Gy.';
                else
                    yValues = U(2:end-1,:)*Gy.';
                end
                % Stack x before y, matching the column-major field layout.
                expected = [xValues(:);yValues(:)];
                % Allow roundoff scaled by the operator and field magnitudes.
                tolerance = 128*eps*max(1,norm(G,inf)*norm(U(:),inf));
                assert(norm(G*U(:)-expected,inf) <= tolerance);
            end
        end
    end
end

function testLoggerForms()
    % Check matching operators, quiet output, and zero recorded errors.
    grid = grid_fixture(9,11,false,true);
    errors = MOLE_errors();
    defaultOutput = evalc('G = grad2D(4,grid);');
    explicitOutput = evalc('reference = grad2D(4,grid,errors);');
    assert(isequal(G,reference));
    assert(isempty(defaultOutput) && isempty(explicitOutput));
    assert(errors.getNumErrors() == 0);
end

function testInvalidGrid()
    % Reject a grid whose validation flag is false.
    grid = grid_fixture(9,11,false,false);
    grid.valid = false;
    errors = MOLE_errors();
    expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_OP_GRID_HAS_ERRORS');
end

function testAxisCellCounts()
    % For k = 4, each axis needs 8 cells; fail each axis in turn.
    counts = [7,11;11,7];
    for index = 1:size(counts,1)
        grid = grid_fixture(counts(index,1),counts(index,2),false,false);
        errors = MOLE_errors();
        expect_gradient_error(@() grad2D(4,grid,errors), ...
                              errors,'MOLE_ERR_OP_INSUFFICIENT_CELLS');
    end
end

function testUnsupportedTopology()
    % Reject topology outside the supported uniform Cartesian case.
    grid = grid_fixture(9,11,false,false);
    grid.topology = 'curvilinear';
    errors = MOLE_errors();
    expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_OP_UNSUPPORTED_TOPOLOGY');
end

function testInvalidDimension()
    % Reject a dimension flag inconsistent with the 2D interface.
    grid = grid_fixture(9,11,false,false);
    grid.dim = 1;
    errors = MOLE_errors();
    expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_INVALID_GRID_DIM');
end


function testInvalidPeriodicCount()
    % Two axes require two flags; test both one flag and three flags.
    for flags = {false, false(3,1)}
        grid = grid_fixture(9,11,false,false);
        grid.bc.isPeriodic = flags{1};
        errors = MOLE_errors();
        expect_gradient_error(@() grad2D(4,grid,errors),errors,'MOLE_ERR_INVALID_ISPERIODIC_DIM');
    end
end

function grid = grid_fixture(m,n,px,py)
    % Supply synthetic grid metadata without generating coordinate arrays.
    grid = struct('dim',2,'topology','uniform','valid',true, ...
                  'm',m,'n',n,'dx',.125,'dy',.23, ...
                  'bc',struct('isPeriodic',[px;py]));
end

function [x,y] = axis_fixtures(grid)
    % Map each axis into the 1D grad interface used by the reference.
    x = struct('dim',1,'topology',grid.topology,'valid',grid.valid, ...
               'm',grid.m,'dx',grid.dx,'bc',struct('isPeriodic',grid.bc.isPeriodic(1)));
    y = x;
    y.m = grid.n; y.dx = grid.dy;
    y.bc.isPeriodic = grid.bc.isPeriodic(2);
end
