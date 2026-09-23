classdef testGI13Curv < matlab.unittest.TestCase
% Regression tests for GI13, the face-to-face interpolation used by
% grad3DCurvLegacy (which the four-argument grad3DCurv dispatches to).
%
% The defect these guard against was an index-map error: GI13 built
% kron(speye(n*o), I1), walking the source in n*o blocks when the source has
% (n+1)*o blocks, so the map drifted by one eta-plane per zeta-level.
%
% NOTE ON TEST CHOICE.  The broken operator had the RIGHT SHAPE and mapped a
% constant to a constant, so shape checks and row-sum checks both passed on it.
% Only an explicit index map (testIndexMap) or a convergence study
% (testGradConvergesOnCurvilinearGrid) detects it.  Please keep both.

    methods(Static)
        function [X, Y, Z, xc, yc, zc] = sineGrid(N, amp)
            % Nodes, and the cell centres with a ghost layer, for a smoothly
            % distorted grid.  Matches examples/matlab_octave conventions.
            [a, b, c] = meshgrid(linspace(0,1,N), linspace(0,1,N), linspace(0,1,N));
            X = a + amp*sin(2*pi*b);
            Y = b + amp*sin(2*pi*a);
            Z = c + 0.5*amp*sin(2*pi*a).*sin(2*pi*b);
            s = linspace(0,1,N);
            s = [0, s(1:end-1)+0.5/(N-1), 1];
            [p, q, t] = meshgrid(s, s, s);
            xc = p + amp*sin(2*pi*q);
            yc = q + amp*sin(2*pi*p);
            zc = t + 0.5*amp*sin(2*pi*p).*sin(2*pi*q);
        end
    end

    methods(Test)

        function testIndexMap(testCase)
            % Feed GI13 a field whose values encode their own (i,j,k) and
            % check every output reads from the correct zeta-plane.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))

            m = 4;
            n = 3;
            o = 3;
            [I, J, K] = ndgrid(1:m, 1:n+1, 1:o);
            v = I(:) + 100*J(:) + 10000*K(:);
            W = reshape(GI13(speye(m*(n+1)*o), m, n, o, 'Gn')*v, m+1, n, o);

            bad = 0;
            for k = 1:o
                for j = 1:n
                    for i = 1:m+1
                        val = W(i,j,k);
                        if val == 0
                            continue;
                        end
                        kk = floor(val/10000);
                        if kk ~= k
                            bad = bad + 1;
                        end
                    end
                end
            end
            testCase.verifyEqual(bad, 0, ...
                sprintf('%d of %d GI13 outputs read from the wrong zeta-plane', ...
                        bad, (m+1)*n*o));
        end

        function testShapesAndConstants(testCase)
            % All six shifts must have the right shape and map a constant
            % field to a constant field.  Weak, but cheap.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))

            m = 5;
            n = 4;
            o = 3;
            ty  = {'Gn','Gc','Ge','Gcy','Gee','Gnn'};
            src = [m*(n+1)*o, m*n*(o+1), (m+1)*n*o, m*n*(o+1), (m+1)*n*o, m*(n+1)*o];
            tgt = [(m+1)*n*o, (m+1)*n*o, m*(n+1)*o, m*(n+1)*o, m*n*(o+1), m*n*(o+1)];

            for i = 1:numel(ty)
                A = GI13(speye(src(i)), m, n, o, ty{i});
                testCase.verifyEqual(size(A), [tgt(i) src(i)], ...
                    sprintf('GI13 %s has the wrong shape', ty{i}));
                testCase.verifyLessThan(max(abs(A*ones(src(i),1) - 1)), 1e-12, ...
                    sprintf('GI13 %s does not preserve a constant', ty{i}));
            end
        end

        function testGradExactOnCartesianGrid(testCase)
            % On an undistorted grid the composition must be exact to roundoff.
            % Guards against a "fix" that trades curvilinear accuracy for
            % Cartesian accuracy.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))

            for N = [11 17 25]
                [X, Y, Z, xc, yc, zc] = testGI13Curv.sineGrid(N, 0.0);
                f = reshape(permute(xc.^2 + yc.^2 + zc.^2, [2 1 3]), [], 1);
                L = div3DCurv(2, X, Y, Z)*grad3DCurv(2, X, Y, Z);
                v = reshape(L*f, N+1, N+1, N+1);
                d = v(3:end-2, 3:end-2, 3:end-2);
                d = d(:) - 6;
                testCase.verifyLessThan(sqrt(mean(d.^2)), 1e-9, ...
                    sprintf('Cartesian L=D*G not exact at n=%d', N));
            end
        end

        function testGradExactOnLinearField(testCase)
            % The gradient of f = x + 2y + 3z is a constant.  The stock
            % operator gave rms 0.39 at distortion 0.10; anything near that
            % means the face shift is wrong again.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))

            N = 21;
            for amp = [0.05 0.10]
                [X, Y, Z, xc, yc, zc] = testGI13Curv.sineGrid(N, amp);
                f = reshape(permute(xc + 2*yc + 3*zc, [2 1 3]), [], 1);
                T = grad3DCurv(2, X, Y, Z)*f;
                gx = T(1:N*(N-1)*(N-1)) - 1;
                testCase.verifyLessThan(sqrt(mean(gx.^2)), 0.05, ...
                    sprintf('grad of a linear field is badly wrong at amp=%g', amp));
            end
        end

        function testGradConvergesOnCurvilinearGrid(testCase)
            % The headline check.  The stock operator gave order 0.03-0.09 --
            % no convergence at all.  Require better than first order, which
            % the stock operator misses by a wide margin and the corrected one
            % clears at ~2.1.
            origPath = path;
            cleanupObj = onCleanup(@() path(origPath));
            addpath(genpath('../../src/octave'))

            amp = 0.10;
            Ns = [13 21 33];
            errs = zeros(size(Ns));
            for i = 1:numel(Ns)
                N = Ns(i);
                [X, Y, Z, xc, yc, zc] = testGI13Curv.sineGrid(N, amp);
                f = reshape(permute(xc.^2 + yc.^2 + zc.^2, [2 1 3]), [], 1);
                T = grad3DCurv(2, X, Y, Z)*f;
                cx = linspace(0,1,N);
                cx = cx(1:end-1) + 0.5/(N-1);
                [aa, bb, ~] = meshgrid(linspace(0,1,N), cx, cx);
                xf = aa + amp*sin(2*pi*bb);
                gx = T(1:N*(N-1)*(N-1));
                errs(i) = sqrt(mean((gx - reshape(permute(2*xf,[2 1 3]),[],1)).^2));
            end
            p = log(errs(1)/errs(end)) / log((Ns(end)-1)/(Ns(1)-1));
            testCase.verifyGreaterThan(p, 1.5, ...
                sprintf('grad3DCurv observed order %.2f on a curvilinear grid', p));
        end

    end
end
