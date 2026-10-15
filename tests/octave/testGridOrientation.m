classdef testGridOrientation < matlab.unittest.TestCase
% Tests for the left-handed / tangled grid detection added to jacobian2D.
%
% The curvilinear operators read [n, m] = size(X): rows are eta, columns are
% xi.  A grid supplied the other way round is still self-consistent for grad
% and div -- J flips sign, the cofactors flip with it, gradients still come
% out exact -- so nothing fails and nothing used to complain.  These tests
% check that it complains now, and, just as importantly, that it stays quiet
% on correctly oriented grids.

    methods(Static)
        function [X, Y] = sineGrid(N, amp)
            [X, Y] = meshgrid(linspace(0,1,N), linspace(0,1,N));
            X = X + amp*sin(2*pi*Y);
            Y = Y + amp*sin(2*pi*X);
        end
    end

    methods(Test)

        function testRightHandedIsSilent(testCase)
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y] = testGridOrientation.sineGrid(21, 0.10);
            testCase.verifyWarningFree(@() jacobian2D(2, X, Y));
        end

        function testTransposedWarns(testCase)
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y] = testGridOrientation.sineGrid(21, 0.10);
            testCase.verifyWarning(@() jacobian2D(2, X.', Y.'), ...
                                   'jacobian2D:leftHandedGrid');
        end

        function testGridGenOutputWarns(testCase)
            % The reported case: gridGen returns xi-nodes as ROWS, which is the
            % opposite of what the operators read, so passing its output
            % straight in yields a globally left-handed grid.
            %
            % tfi does addpath(['grids/' grid_name]) RELATIVE TO THE CURRENT
            % DIRECTORY, so the working directory has to be src/octave, not
            % src/octave/grids. And the path is added non-recursively on
            % purpose: genpath would put every grid folder on the path at once,
            % and the curve functions (right.m, top.m, ...) share names across
            % grids, so another grid would silently answer for this one.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            origDir = pwd;
            cleanupDir = onCleanup(@() cd(origDir));
            srcDir = fullfile(pwd, '..', '..', 'src', 'octave');
            addpath(srcDir)
            cd(srcDir)

            % chevron, not swan: swan is itself tangled (mixed-sign Jacobian
            % either way round), which is the other warning. See
            % testTangledGridWarns.
            [X, Y] = gridGen('TFI', 'chevron', 39, 99, false);
            testCase.verifyNotEmpty(strfind(which('right'), 'chevron'), ...
                'the chevron curves are not the ones on the path');
            testCase.verifyWarning(@() jacobian2D(2, X, Y), ...
                                   'jacobian2D:leftHandedGrid');
            testCase.verifyWarningFree(@() jacobian2D(2, X.', Y.'));
        end

        function testMagnitudesAreIdentical(testCase)
            % Documents the symptom that makes this hard to notice: same grid,
            % same |J| to the last bit, opposite sign.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y] = testGridOrientation.sineGrid(21, 0.10);
            warning('off', 'jacobian2D:leftHandedGrid');
            restoreWarn = onCleanup(@() warning('on', 'jacobian2D:leftHandedGrid'));
            a = sort(abs(nonzeros(jacobian2D(2, X, Y))));
            b = sort(abs(nonzeros(jacobian2D(2, X.', Y.'))));
            testCase.verifyEqual(a, b, 'AbsTol', 1e-12);
        end

        function testTangledGridWarns(testCase)
            % A mesh that folds over itself has mixed-sign J.  Different
            % problem, different warning.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y] = meshgrid(linspace(0,1,15), linspace(0,1,15));
            X(6:10, 6:10) = X(6:10, 6:10) - 0.45;
            testCase.verifyWarning(@() jacobian2D(2, X, Y), ...
                                   'jacobian2D:tangledGrid');
        end

        function testWarningReachesOperatorUsers(testCase)
            % grad2DCurv and div2DCurv both route through jacobian2D, so users
            % who never call it directly still get told.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y] = testGridOrientation.sineGrid(21, 0.10);
            testCase.verifyWarning(@() grad2DCurv(2, X.', Y.'), ...
                                   'jacobian2D:leftHandedGrid');
            testCase.verifyWarning(@() div2DCurv(2, X.', Y.'), ...
                                   'jacobian2D:leftHandedGrid');
        end

        function testFiveArgPath(testCase)
            % jacobian2D has two entry paths: 3 arguments dispatches to
            % jacobian2DLegacy, 5 arguments computes inline.  Both are checked.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            N = 21;
            dc = [1;1;1;1];
            nc = [0;0;0;0];
            s = linspace(0,1,N);
            s = [0, s(1:end-1)+0.5/(N-1), 1];
            [X, Y] = meshgrid(s, s);
            X = X + 0.08*sin(2*pi*Y);
            Y = Y + 0.08*sin(2*pi*X);
            testCase.verifyWarningFree(@() jacobian2D(2, X, Y, dc, nc));
            testCase.verifyWarning(@() jacobian2D(2, X.', Y.', dc, nc), ...
                                   'jacobian2D:leftHandedGrid');
        end

    end
end
