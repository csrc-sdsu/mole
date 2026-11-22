function results = run_mole_ci()
% PURPOSE
% Run all current MATLAB tests and write JUnit and coverage XML.
%
% SYNTAX
% results = run_mole_ci()
%
% DESCRIPTION
% Writes test-results/results.xml and code-coverage/coverage.xml under the
% repository root. Runs every registered case before failing the command
% when a test fails or does not complete. Requires MATLAB R2021a or later.
% GNU Octave runs the same cases through the portable test runners instead.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    ciDir = fileparts(mfilename('fullpath'));
    octaveDir = fileparts(fileparts(ciDir));
    repoDir = fileparts(octaveDir);
    addpath(ciDir);
    addpath(fullfile(octaveDir, 'tests'));
    paths = mole_test_setup();
    cases = mole_test_catalog();
    suite = matlab.unittest.TestSuite.fromFile(fullfile(ciDir, 'current', 'MoleCITest.m'));
    if isempty(suite) || numel(suite) ~= numel(fieldnames(cases))
        error('MOLETests:CountMismatch', 'MATLAB did not register every current test case.');
    end

    resultDir = fullfile(repoDir, 'test-results');
    coverageDir = fullfile(repoDir, 'code-coverage');
    if ~isfolder(resultDir)
        mkdir(resultDir);
    end
    if ~isfolder(coverageDir)
        mkdir(coverageDir);
    end
    sourceFiles = paths.sourceFiles;

    runner = matlab.unittest.TestRunner.withTextOutput( ...
        'OutputDetail', 4, 'LoggingLevel', 4);
    runner.addPlugin(matlab.unittest.plugins.XMLPlugin.producingJUnitFormat( ...
        fullfile(resultDir, 'results.xml'), 'OutputDetail', 4));
    format = matlab.unittest.plugins.codecoverage.CoberturaFormat( ...
        fullfile(coverageDir, 'coverage.xml'));
    runner.addPlugin(matlab.unittest.plugins.CodeCoveragePlugin.forFile( ...
        sourceFiles, 'Producing', format));
    results = runner.run(suite);
    assertSuccess(results);
end
