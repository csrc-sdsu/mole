classdef testOperatorMigration < matlab.unittest.TestCase
% PURPOSE
% Regression tests for Plan 2 — operator curvilinear dispatch and
% legacy-signature removal.
%
% DESCRIPTION
% Verifies that grad, div, lap, nodal accept curvilinear grids whose
% coordinate arrays were populated by validateGrid; that curl(grid, k)
% is a valid public entry point; and that grad, div, lap reject
% flat-argument signatures after the signature strip in Task 6.
%
% SYNTAX
% Run via: runtests('testOperatorMigration')
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    methods(Test)

        function testGradCurvilinear2DIdentityEqualsUniform(testCase)
            addpath('../../src/matlab_octave');
            % An identity curvilinear map must produce the same operator
            % as a uniform grid with the same spacing.
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);   % (m+1)×(n+1) ndgrid
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            grid_uniform = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            G_curv    = grad(grid_curv, k);
            G_uniform = grad(grid_uniform, k);
            testCase.verifyLessThan(norm(G_curv - G_uniform, 'fro'), 1e-10);
        end

        function testGradCurvilinear2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            % Compare grid-first curvilinear grad against the old flat-arg call.
            % grad2DCurv expects meshgrid (n+1)×(m+1) — use X' to convert.
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            G_new = grad(grid_curv, k);
            G_old = grad2DCurv(k, X', Y');
            testCase.verifyLessThan(norm(G_new - G_old, 'fro'), 1e-10);
        end

        function testDivCurvilinear2DIdentityEqualsUniform(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            grid_uniform = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            D_curv    = div(grid_curv, k);
            D_uniform = div(grid_uniform, k);
            testCase.verifyLessThan(norm(D_curv - D_uniform, 'fro'), 1e-10);
        end

        function testDivCurvilinear2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            D_new = div(grid_curv, k);
            D_old = div2DCurv(k, X', Y');
            testCase.verifyLessThan(norm(D_new - D_old, 'fro'), 1e-10);
        end

        function testLapCurvilinear2DIsCompositeOfDivGrad(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            L = lap(grid_curv, k);
            D = div(grid_curv, k);
            G = grad(grid_curv, k);
            testCase.verifyLessThan(norm(L - D*G, 'fro'), 1e-12);
        end

        function testNodalCurvilinear2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            % nodal2DCurv returns [Nx, Ny]; nodalOp_impl stacks them as [Nx; Ny].
            m = 8; n = 6; k = 2;
            dx = 1/m; dy = 1/n;
            [X, Y] = ndgrid((0:m)*dx, (0:n)*dy);
            grid_curv = struct('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                               'type', 'curvilinear', 'nodes', struct('X', X, 'Y', Y));
            grid_curv = validateGrid(grid_curv);
            [Nx_old, Ny_old] = nodal2DCurv(k, X', Y');
            N_new = nodal(grid_curv, k);
            N_old = [Nx_old; Ny_old];
            testCase.verifyLessThan(norm(N_new - N_old, 'fro'), 1e-10);
        end

        function testCurlGrid2DMatchesLegacy(testCase)
            addpath('../../src/matlab_octave');
            m = 10; n = 8; k = 2;
            dx = 1/m; dy = 1/n;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            C_new = curl(grid, k);
            C_old = curl2D(k, m, dx, n, dy);
            testCase.verifyLessThan(norm(C_new - C_old, 'fro'), 1e-12);
        end

        function testGradRejectsLegacyFlatArgs(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() grad(2, 10, 0.1), 'grad:InvalidSignature');
        end

        function testDivRejectsLegacyFlatArgs(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() div(2, 10, 0.1), 'div:InvalidSignature');
        end

        function testLapRejectsLegacyFlatArgs(testCase)
            addpath('../../src/matlab_octave');
            testCase.verifyError(@() lap(2, 10, 0.1), 'lap:InvalidSignature');
        end

    end  % methods(Test)
end  % classdef
