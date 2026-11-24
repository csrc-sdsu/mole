classdef MoleCITest < matlab.unittest.TestCase
% PURPOSE
% Expose every current portable MOLE case to MATLAB CI reporting.
%
% DESCRIPTION
% Adapts the shared MOLE case functions to MATLAB's unit testing framework.
% Each discovered case becomes an individual parameterized MATLAB test,
% allowing separate names, execution times, and failure diagnostics in reports.
%
% This class registers and executes cases. Report writing is configured by
% run_mole_ci or the GitHub Actions MATLAB test action, not by this class.
% The class is MATLAB-specific; the shared case functions are also executed
% by the portable GNU Octave runner without loading this class.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------

    % MATLAB uses this property to parameterize runCase. defineCases supplies
    % the available values, and each value is a zero-input case function handle.
    properties (TestParameter)
        moleCase
    end

    % Define the parameter values when MATLAB creates the test suite.
    % Discovers cases does not execute their test bodies.
    methods (TestParameterDefinition, Static)
        function moleCase = defineCases()
            % Return a structure mapping unique case names to function handles.
            % MATLAB uses its fields as parameter names and its values as the
            % inputs to runCase. Discovery excludes old_version

            % The output name matches the TestParameter property it initializes.
            % Moving up twice finds octave/tests, where the shared discovery and setup helpers live.
            ciDir = fileparts(mfilename('fullpath'));
            addpath(fileparts(fileparts(ciDir)));
            moleCase = mole_test_catalog();
        end
    end

    % Prepare the execution environment before this class's cases run.
    % The unused first argument (~) is the TestCase instance supplied by MATLAB.
    methods (TestClassSetup)
        function prepareSources(~)
            % Add current library sources and test helpers to the search path
            mole_test_setup();
        end
    end

    % MATLAB invokes this method separately for each discovered parameter.
    % This reuses original cases instead of copying their test logic.
    methods (Test)
        function runCase(~, moleCase)
            % Execute the selected case. Do not catch its exception here:
            % MATLAB must record a failure against this individual case.
            moleCase();
        end
    end
end