function report = run_mole_tests(junitFile)
% PURPOSE
% Run current MOLE test cases in GNU Octave and optionally write JUnit XML.
%
% SYNTAX
% run_mole_tests()
% run_mole_tests('test-results/octave-results.xml')
% report = run_mole_tests()
% report = run_mole_tests(junitFile)
%
% DESCRIPTION
% Recursively discovers suites under tests while excluding old_version.
% Attempts every discovered case and prints its result. Calling without
% output raises an error after the run when any case fails.
% junitFile is an optional character vector; empty disables XML output.
% Relative paths use the current working directory. Missing parent folders
% are created. The report is written before raising the final test-failure
% exception. Discovery/setup failures occur before a report can be produced.
% Capturing the output requires the caller to check report.ok explicitly.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    if nargin < 1
        junitFile = '';
    elseif ~ischar(junitFile) || (~isempty(junitFile) && ~isrow(junitFile))
        error('MOLETests:InvalidInput', 'junitFile must be a character vector.');
    end
    cases = mole_test_catalog();
    names = fieldnames(cases);
    report.results = struct('name', {}, 'passed', {}, 'duration', {}, ...
                            'identifier', {}, 'message', {});
    report.passed = 0;
    report.total = numel(names);
    for i = 1:numel(names)
        currentTest = cases.(names{i});
        result = struct('name', names{i}, 'passed', false, 'duration', 0, ...
                        'identifier', '', 'message', '');
        started = tic;
        try
            currentTest();
            result.passed = true;
            report.passed = report.passed+1;
            fprintf('%s: passed\n', names{i});
        catch err
            result.identifier = err.identifier;
            result.message = err.message;
            fprintf('%s: failed [%s]\n%s\n', names{i}, err.identifier, err.message);
        end
        result.duration = toc(started);
        report.results(end+1) = result;
    end
    report.failed = report.total-report.passed;
    report.ok = report.failed == 0;
    fprintf('TOTAL: %d tests; %d passed, %d failed.\n', ...
            report.total, report.passed, report.failed);
    if ~isempty(junitFile)
        write_mole_junit(report, junitFile);
    end
    if nargout == 0 && ~report.ok
        error('MOLETests:Failed', '%d of %d tests failed.', report.failed, report.total);
    end
end
