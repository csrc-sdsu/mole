classdef MoleCITest < matlab.unittest.TestCase
% PURPOSE
% Expose every current portable MOLE case to MATLAB CI reporting.
%
% DESCRIPTION
% Creates one parameterized MATLAB test for each discovered shared case.
% Exceptions propagate directly to the MATLAB runner so that each failure,
% duration, and diagnostic belongs to its individual JUnit result.
% The portable suites remain executable directly in MATLAB and GNU Octave.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    properties (TestParameter)
        moleCase
    end

    methods (TestParameterDefinition, Static)
        function moleCase = defineCases()
            ciDir = fileparts(mfilename('fullpath'));
            addpath(fileparts(fileparts(ciDir)));
            moleCase = mole_test_catalog();
        end
    end

    methods (TestClassSetup)
        function prepareSources(~)
            mole_test_setup();
        end
    end

    methods (Test)
        function runCase(~, moleCase)
            moleCase();
        end
    end
end
