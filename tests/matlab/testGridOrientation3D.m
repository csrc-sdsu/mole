classdef testGridOrientation3D < matlab.unittest.TestCase
% Extends the 2D orientation guard to jacobian3D, and adds detection of
% vanishing Jacobians in both dimensions.
%
% In 3D, swapping two axes is an odd permutation, so handedness inverts and J
% goes uniformly negative -- the same failure as the 2D transpose, with one
% more way to trigger it (mirroring a single axis does it too).
%
% A vanishing Jacobian is a different problem: the mapping is degenerate at
% that cell and is not invertible there, and grad/div divide by J. It is not
% caught by the sign checks, because zero is neither positive nor negative.

    methods(Static)
        function [X, Y, Z] = sineGrid3(N, amp)
            [a, b, c] = meshgrid(linspace(0,1,N), linspace(0,1,N), ...
                                 linspace(0,1,N));
            X = a + amp*sin(2*pi*b);
            Y = b + amp*sin(2*pi*a);
            Z = c + 0.5*amp*sin(2*pi*a).*sin(2*pi*b);
        end
    end

    methods(Test)

        function testRightHanded3DIsSilent(testCase)
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y, Z] = testGridOrientation3D.sineGrid3(13, 0.08);
            testCase.verifyWarningFree(@() jacobian3D(2, X, Y, Z));
        end

        function testSwappedAxesWarn(testCase)
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y, Z] = testGridOrientation3D.sineGrid3(13, 0.08);
            p = @(A) permute(A, [2 1 3]);
            testCase.verifyWarning(@() jacobian3D(2, p(X), p(Y), p(Z)), ...
                                   'jacobian3D:leftHandedGrid');
        end

        function testMirroredAxisWarns(testCase)
            % Reversing one axis is also an odd permutation.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y, Z] = testGridOrientation3D.sineGrid3(13, 0.08);
            f = @(A) A(end:-1:1, :, :);
            testCase.verifyWarning(@() jacobian3D(2, f(X), f(Y), f(Z)), ...
                                   'jacobian3D:leftHandedGrid');
        end

        function testWarningReaches3DOperatorUsers(testCase)
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            [X, Y, Z] = testGridOrientation3D.sineGrid3(13, 0.08);
            p = @(A) permute(A, [2 1 3]);
            testCase.verifyWarning(@() grad3DCurv(2, p(X), p(Y), p(Z)), ...
                                   'jacobian3D:leftHandedGrid');
            testCase.verifyWarning(@() div3DCurv(2, p(X), p(Y), p(Z)), ...
                                   'jacobian3D:leftHandedGrid');
        end

        function testVanishingJacobianWarns(testCase)
            % Three identical columns make the central difference across the
            % middle one exactly zero, so those cells are degenerate. The sign
            % checks cannot see this: zero is neither positive nor negative.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            N = 21;
            [X, Y] = meshgrid(linspace(0,1,N), linspace(0,1,N));
            X = X + 0.10*sin(2*pi*Y);
            Y = Y + 0.10*sin(2*pi*X);
            X(:, 9:11) = repmat(X(:, 10), 1, 3);
            Y(:, 9:11) = repmat(Y(:, 10), 1, 3);
            testCase.verifyWarning(@() jacobian2D(2, X, Y), ...
                                   'jacobian2D:vanishingJacobian');
        end

        function testHealthyGridHasNoVanishingWarning(testCase)
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))
            N = 21;
            [X, Y] = meshgrid(linspace(0,1,N), linspace(0,1,N));
            X = X + 0.10*sin(2*pi*Y);
            Y = Y + 0.10*sin(2*pi*X);
            testCase.verifyWarningFree(@() jacobian2D(2, X, Y));
        end

    end
end
