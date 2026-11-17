function report = run_gradient_tests(verbose)
% PURPOSE
% Run the MATLAB and GNU Octave gradient test suites and summarize their results.
% SYNTAX
% run_gradient_tests()
% report = run_gradient_tests(true)
% DESCRIPTION
% Returns per-suite counts, captured test output, and resolved source paths.
% Passing true displays individual cases and failure diagnostics. Calling
% without an output raises an error when any test fails.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    if nargin < 1
        verbose = false;
    end
    paths = gradient_test_setup();
    dependencies = {'grad', 'gradPeriodic', 'gradNonPeriodic', ...
                    'MOLE_errors', 'validateGrid'};
    for i = 1:numel(dependencies)
        report.sources.(dependencies{i}) = which(dependencies{i});
    end
    names = {'test_grad', 'test_gradPeriodic', 'test_gradNonPeriodic'};
    results = struct('name', {}, 'passed', {}, 'total', {}, 'failed', {}, 'output', {});
    for i = 1:numel(names)
        filename = fullfile(paths.tests, [names{i} '.m']);
        if ~isfile(filename)
            error('MOLETests:Setup', 'Missing test file: %s', filename);
        end
        planned = numel(regexp(fileread(filename), '(?m)^function test[A-Za-z0-9_]+\(\)\s*$', 'match'));
        output = evalc('[passed, total] = feval(names{i});');
        if total ~= planned || total == 0
            error('MOLETests:CountMismatch', ...
                  'Expected %d cases in %s; the suite executed %d.', planned, names{i}, total);
        end
        result = struct('name', names{i}, 'passed', passed, 'total', total, ...
                        'failed', total-passed, 'output', output);
        results(end+1) = result;
        fprintf('%s: %d passed, %d failed (of %d)\n', ...
                result.name, result.passed, result.failed, result.total);
        if verbose
            fprintf('%s', output);
        end
    end
    report.results = results;
    report.passed = sum([results.passed]);
    report.total = sum([results.total]);
    report.failed = sum([results.failed]);
    report.ok = report.failed == 0;
    fprintf('TOTAL: %d tests; %d passed, %d failed.\n', ...
            report.total, report.passed, report.failed);
    if nargout == 0 && ~report.ok
        error('MOLETests:Failed', '%d gradient test cases failed.', report.failed);
    end
end
