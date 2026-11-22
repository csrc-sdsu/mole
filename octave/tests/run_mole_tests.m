function report = run_mole_tests()
% PURPOSE
% Run every current portable MOLE test case in MATLAB or GNU Octave.
%
% SYNTAX
% run_mole_tests()
% report = run_mole_tests()
%
% DESCRIPTION
% Recursively discovers suites under tests while excluding old_version.
% Attempts every discovered case and prints its result. Calling without
% output raises an error after the run when any case fails. MATLAB users
% requiring JUnit and coverage XML can call the CI runner run_mole_ci.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
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
    if nargout == 0 && ~report.ok
        error('MOLETests:Failed', '%d of %d tests failed.', report.failed, report.total);
    end
end
