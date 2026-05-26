classdef testAPIConsolidation < matlab.unittest.TestCase
% PURPOSE
% Tests for Plan 3 — unified addScalarBC and interpol(grid, direction) APIs.
%
% DESCRIPTION
% Verifies that addScalarBC(A, b, k, grid, v) dispatches correctly for 1D,
% 2D, and 3D grids; that interpol(grid, 'CentersToFaces') etc. route to the
% correct transfer implementations; and that both APIs produce identical
% results to the dimensional variants.
%
% SYNTAX
% Run via: runtests('testAPIConsolidation')
%
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    methods(Test)

        function testAddScalarBC1DUnified(testCase)
            addpath('../../src/matlab_octave');
            k = 4; m = 50; dx = 0.2;
            dc = [1; 1]; nc = [0; 0];
            v  = [2; 7];
            grid = makeGrid('m', m, 'dx', dx, 'bc', struct('dc', dc, 'nc', nc));
            A0 = speye(m+2); b0 = ones(m+2, 1);
            [A1, b1] = addScalarBC1D(A0, b0, k, grid, v);
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);
            testCase.verifyLessThan(norm(A1-A2,'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1-b2),      1e-12);
        end

        function testAddScalarBC2DUnified(testCase)
            addpath('../../src/matlab_octave');
            k = 2; m = 10; n = 8; dx = 0.1; dy = 0.125;
            dc = ones(4,1); nc = zeros(4,1);
            v = {ones(n,1), ones(n,1), ones(m+2,1), ones(m+2,1)}';
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy, ...
                            'bc', struct('dc', dc, 'nc', nc));
            A0 = speye((m+2)*(n+2)); b0 = ones((m+2)*(n+2), 1);
            [A1, b1] = addScalarBC2D(A0, b0, k, grid, v);
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);
            testCase.verifyLessThan(norm(A1-A2,'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1-b2),       1e-12);
        end

        function testAddScalarBC3DUnified(testCase)
            addpath('../../src/matlab_octave');
            k = 2; m = 6; n = 6; o = 6;
            dx = 1/m; dy = 1/n; dz = 1/o;
            dc = ones(6,1); nc = zeros(6,1);
            v = {ones(n*o,1),      ones(n*o,1), ...
                 ones((m+2)*o,1),  ones((m+2)*o,1), ...
                 ones((m+2)*(n+2),1), ones((m+2)*(n+2),1)}';
            grid = makeGrid('m', m, 'n', n, 'o', o, ...
                            'dx', dx, 'dy', dy, 'dz', dz, ...
                            'bc', struct('dc', dc, 'nc', nc));
            sz = (m+2)*(n+2)*(o+2);
            A0 = speye(sz); b0 = ones(sz, 1);
            [A1, b1] = addScalarBC3D(A0, b0, k, grid, v);
            [A2, b2] = addScalarBC(A0, b0, k, grid, v);
            testCase.verifyLessThan(norm(A1-A2,'fro'), 1e-12);
            testCase.verifyLessThan(norm(b1-b2),       1e-12);
        end

        function testInterpolCentersToFaces1D(testCase)
            addpath('../../src/matlab_octave');
            m = 10; dx = 0.1;
            grid = makeGrid('m', m, 'dx', dx);
            I_new = interpol(grid, 'CentersToFaces');
            I_old = interpolCentersToFacesD1D(2, m);
            testCase.verifyLessThan(norm(I_new - I_old, 'fro'), 1e-12);
        end

        function testInterpolFacesToCenters1D(testCase)
            addpath('../../src/matlab_octave');
            m = 10; dx = 0.1;
            grid = makeGrid('m', m, 'dx', dx);
            I_new = interpol(grid, 'FacesToCenters');
            I_old = interpolFacesToCentersG1D(2, m);
            testCase.verifyLessThan(norm(I_new - I_old, 'fro'), 1e-12);
        end

        function testInterpolCentersToFaces2D(testCase)
            addpath('../../src/matlab_octave');
            m = 8; n = 6; dx = 0.125; dy = 1/6;
            grid = makeGrid('m', m, 'n', n, 'dx', dx, 'dy', dy);
            I_new = interpol(grid, 'CentersToFaces');
            I_old = interpolCentersToFacesD2D(2, m, n);
            testCase.verifyLessThan(norm(I_new - I_old, 'fro'), 1e-12);
        end

    end  % methods(Test)
end  % classdef
