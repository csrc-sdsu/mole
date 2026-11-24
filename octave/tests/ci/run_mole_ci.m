function results = run_mole_ci()
% PURPOSE
% Run all current MATLAB tests and write JUnit and coverage XML.
%
% SYNTAX
% results = run_mole_ci()
%
% DESCRIPTION
% Runs the shared MOLE test cases through MATLAB's unit testing framework.
% Returns a matlab.unittest.TestResult array with one result per case.
%
% Writes these reports under the repository root:
%   test-results/results.xml   : Individual test results in JUnit format.
%   code-coverage/coverage.xml : Source-line coverage in Cobertura format.
%
% Failed or incomplete results raise an error after the run and reporting,
% allowing a MATLAB batch command to return a nonzero exit status to CI.
% Requires MATLAB R2021a or later. GNU Octave executes the same test cases
% through run_mole_tests instead of this MATLAB-specific reporting function.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    % Locate the repository from this file's position in octave/tests/ci.
    ciDir = fileparts(mfilename('fullpath'));
    octaveDir = fileparts(fileparts(ciDir));
    repoDir = fileparts(octaveDir);

    % Make the CI helpers and shared test-discovery helpers callable.
    addpath(ciDir);
    addpath(fullfile(octaveDir, 'tests'));

    % Configure current source/helper paths and obtain the source files to
    % measure coverage.
    paths = mole_test_setup();

    % Discover the named shared cases without executing their test bodies.
    cases = mole_test_catalog();

    % The adapter exposes each shared case as a separate MATLAB test, so
    % JUnit records individual cases rather than one combined suite result.
    suite = matlab.unittest.TestSuite.fromFile(fullfile(ciDir, 'current', 'MoleCITest.m'));

    % Require MATLAB to register the same number of cases as discovery found.
    % An empty or mismatched suite is a setup error, not a successful run.
    if isempty(suite) || numel(suite) ~= numel(fieldnames(cases))
        error('MOLETests:CountMismatch', 'MATLAB did not register every current test case.');
    end

    % Create report directories if needed. These paths match the artifact
    % paths configured in the GitHub Actions workflow.
    resultDir = fullfile(repoDir, 'test-results');
    coverageDir = fullfile(repoDir, 'code-coverage');
    if ~isfolder(resultDir)
        mkdir(resultDir);
    end
    if ~isfolder(coverageDir)
        mkdir(coverageDir);
    end

    % Measure the library source files selected by setup Test helpers are not included.
    sourceFiles = paths.sourceFiles;

    % Level 4 means verbose output for test progress and diagnostics logged
    % through MATLAB's testing framework.
    runner = matlab.unittest.TestRunner.withTextOutput( ...
        'OutputDetail', 4, 'LoggingLevel', 4);

    % Attach the JUnit writer for per-case status, duration, and failure
    % details. Reports are produced when the runner executes the suite.
    runner.addPlugin(matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
        fullfile(resultDir, 'results.xml'), 'OutputDetail', 4));

    % Select the coverage report format and destination. This creates the
    % format configuration. Does not execute tests or measure coverage.
    format = matlab.unittest.plugins.codecoverage.CoberturaFormat( ...
        fullfile(coverageDir, 'coverage.xml'));

    % Attach coverage collection for the selected library files and use the
    % Cobertura configuration above to write the measured results.
    runner.addPlugin(matlab.unittest.plugins.CodeCoveragePlugin.forFile( ...
        sourceFiles, 'Producing', format));

    % Execute the suite. Ordinary test failures are recorded by the framework
    % so other cases can continue, and the plugins generate their reports.
    results = runner.run(suite);

    % Returning failed TestResult objects alone would not fail a batch command.
    % Raise an error for failed/incomplete results after reporting is finished.
    assertSuccess(results);
end