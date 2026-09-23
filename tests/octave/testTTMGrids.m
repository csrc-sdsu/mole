classdef testTTMGrids < matlab.unittest.TestCase
% Tests that ttm produces unfolded grids.
%
% Before the TFI initial guess was added, ttm started with the interior at
% zeros(m,n) -- every interior node at the origin -- so the first sweeps
% computed alpha, beta and gamma from a maximally degenerate grid.  The
% iteration then had to untangle a fold it had created itself, and on every
% grid shipped with MOLE it failed to: swan, chevron and horseshoe all came
% out with mixed-sign Jacobians at 500 iterations.
%
% A folded grid is locally left-handed.  jacobian2D returns the signed
% determinant and grad2DCurv divides by it, so a run on one produces finite,
% plausible output with the metric tensor inverted in a patch.  Nothing
% raises.
%
% NOTE ON ORIENTATION.  ttm returns X with xi-nodes as rows, which is the
% opposite of what jacobian2D reads, so these tests transpose.  Without the
% transpose a correct grid reports ALL NEGATIVE rather than ALL POSITIVE.

    methods(Static)
        function [npos, nneg] = jacobianSigns(X, Y)
            origState = warning('off', 'jacobian2D:leftHandedGrid');
            restore1 = onCleanup(@() warning(origState));
            origState2 = warning('off', 'jacobian2D:tangledGrid');
            restore2 = onCleanup(@() warning(origState2));
            d = nonzeros(jacobian2D(2, X.', Y.'));
            npos = sum(d > 0);
            nneg = sum(d < 0);
        end
    end

    methods(Test)

        function testShippedGridsAreNotFolded(testCase)
            % chevron and horseshoe are clean under TFI, so there is no excuse
            % for the elliptic generator to fold them.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            origDir = pwd;
            cleanupDir = onCleanup(@() cd(origDir));
            addpath(genpath('../../src/octave'))
            cd('../../src/octave')

            for g = {'chevron', 'horseshoe'}
                [X, Y] = ttm(g{1}, 39, 99, 500, false);
                [~, nneg] = testTTMGrids.jacobianSigns(X, Y);
                testCase.verifyEqual(nneg, 0, ...
                    sprintf('ttm folded the %s grid: %d negative Jacobian entries', ...
                            g{1}, nneg));
            end
        end

        function testEllipticSmoothingRepairsAFoldedTFI(testCase)
            % swan is folded under TFI itself (113 negative entries).  Repairing
            % that is exactly what an elliptic generator is for, and with a
            % sensible initial guess ttm does it.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            origDir = pwd;
            cleanupDir = onCleanup(@() cd(origDir));
            addpath(genpath('../../src/octave'))
            cd('../../src/octave')

            [Xt, Yt] = tfi('swan', 39, 99, false);
            [~, nnegTFI] = testTTMGrids.jacobianSigns(Xt, Yt);
            testCase.verifyGreaterThan(nnegTFI, 0, ...
                'swan is expected to be folded under TFI; test premise changed');

            [X, Y] = ttm('swan', 39, 99, 500, false);
            [~, nneg] = testTTMGrids.jacobianSigns(X, Y);
            testCase.verifyEqual(nneg, 0, ...
                sprintf('ttm left swan folded: %d negative entries', nneg));
        end

        function testFewIterationsDoNotFold(testCase)
            % The failure was not slow degradation from over-iteration -- the
            % stock version was folded within 5 sweeps.  Check the low end.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            origDir = pwd;
            cleanupDir = onCleanup(@() cd(origDir));
            addpath(genpath('../../src/octave'))
            cd('../../src/octave')

            for it = [5 25 100]
                [X, Y] = ttm('chevron', 39, 99, it, false);
                [~, nneg] = testTTMGrids.jacobianSigns(X, Y);
                testCase.verifyEqual(nneg, 0, ...
                    sprintf('ttm folded chevron after %d iterations (%d negative)', ...
                            it, nneg));
            end
        end

        function testBoundariesAreUnchanged(testCase)
            % The initial guess must only touch the interior.  Boundary nodes
            % come from the curve definitions and must survive untouched.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            origDir = pwd;
            cleanupDir = onCleanup(@() cd(origDir));
            addpath(genpath('../../src/octave'))
            cd('../../src/octave')

            m = 39;
            n = 99;
            [X, Y] = ttm('chevron', m, n, 50, false);
            [Xt, Yt] = tfi('chevron', m, n, false);

            testCase.verifyEqual(X(1, :),   Xt(1, :),   'AbsTol', 1e-12);
            testCase.verifyEqual(X(end, :), Xt(end, :), 'AbsTol', 1e-12);
            testCase.verifyEqual(Y(:, 1),   Yt(:, 1),   'AbsTol', 1e-12);
            testCase.verifyEqual(Y(:, end), Yt(:, end), 'AbsTol', 1e-12);
        end

    end
end
