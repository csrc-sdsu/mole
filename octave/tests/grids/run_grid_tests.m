function report = run_grid_tests(verbose)
% PURPOSE
% Run the Octave grid and error reporting tests.
% SYNTAX
% run_grid_tests()
% report = run_grid_tests(false)
% report = run_grid_tests(true)   % also display each BIST case and failure
% DESCRIPTION
% Parse/callability blockers are counted separately from assertion failures.
% Calling without an output raises an error if anything fails or is blocked.
% SPDX-License-Identifier: GPL-3.0-or-later
    if nargin < 1
        verbose = false;
    end
    paths = grid_test_setup();
    report.preflight.MOLE_errors = check_logger();
    report.preflight.validateGrid = check_function('validateGrid');
    report.preflight.makeGrid = check_function('makeGrid');
    report.sources.validateGrid = fullfile(paths.grids, 'validateGrid.m');
    report.sources.makeGrid = fullfile(paths.grids, 'makeGrid.m');
    report.sources.MOLE_errors = report.preflight.MOLE_errors.path;
    report.sources.validateGrid_sha256 = hash('sha256', fileread(report.sources.validateGrid));
    report.sources.makeGrid_sha256 = hash('sha256', fileread(report.sources.makeGrid));

    labels = {'MOLE_errors', 'validateGrid', 'makeGrid'};
    for i = 1:numel(labels)
        status = report.preflight.(labels{i});
        if ~status.ok
            fprintf('BLOCKED %s: %s\n', labels{i}, status.reason);
        end
    end

    names = {'test_grid1D', 'test_grid2D', 'test_grid3D', ...
         'test_grid_inferred', 'test_makeGrid', 'testMakeGrid'};
    results = struct('name', {}, 'total', {}, 'passed', {}, 'failed', {}, ...
                     'blocked', {}, 'reason', {}, 'details', {});
    for i = 1:numel(names)
        file = fullfile(paths.tests, [names{i} '.m']);
        planned = numel(regexp(fileread(file), '(?m)^%!test\s*$', 'match'));
        result = struct('name', names{i}, 'total', planned, 'passed', 0, ...
                        'failed', 0, 'blocked', 0, 'reason', '', 'details', '');
        reasons = {};
        if ~report.preflight.MOLE_errors.ok
            reasons{end+1} = ['MOLE_errors: ' report.preflight.MOLE_errors.reason];
        end
        if ~strcmp(names{i}, 'test_error_reporting') && ~report.preflight.validateGrid.ok
            reasons{end+1} = ['validateGrid: ' report.preflight.validateGrid.reason];
        end
        if any(strcmp(names{i}, {'test_makeGrid', 'testMakeGrid'})) && ~report.preflight.makeGrid.ok
            reasons{end+1} = ['makeGrid: ' report.preflight.makeGrid.reason];
        end
        if ~isempty(reasons)
            result.blocked = planned;
            result.reason = strjoin(reasons, ' | ');
        else
            try
                result.details = evalc('[passed, total] = test(file, ''verbose'');');
                if total ~= planned
                    error('MOLETests:CountMismatch', 'Expected %d cases in %s; Octave discovered %d.', planned, names{i}, total);
                end
                result.passed = passed;
                result.failed = total - passed;
            catch err
                result.blocked = planned;
                result.reason = ['Test infrastructure: ' err.message];
            end
        end
        results(end+1) = result;
        fprintf('%s: %d passed, %d failed, %d blocked (of %d)\n', ...
                result.name, result.passed, result.failed, result.blocked, result.total);
        if verbose && ~isempty(result.details)
            fprintf('%s', result.details);
        end
        if verbose && ~isempty(result.reason)
            fprintf('%s\n', result.reason);
        end
    end
    report.results = results;
    report.total = sum([results.total]);
    report.passed = sum([results.passed]);
    report.failed = sum([results.failed]);
    report.blocked = sum([results.blocked]);
    report.ok = report.failed == 0 && report.blocked == 0;
    fprintf('TOTAL: %d tests; %d passed, %d failed, %d blocked.\n', ...
            report.total, report.passed, report.failed, report.blocked);
    if nargout == 0 && ~report.ok
        error('MOLETests:Incomplete', '%d assertions failed and %d tests were blocked. See the report above.', report.failed, report.blocked);
    end
end

function status = check_function(name)
    status = struct('ok', false, 'reason', '', 'path', '');
    try
        status.path = which(name);
        nargin(name);
        status.ok = true;
    catch err
        status.reason = err.message;
    end
end

function status = check_logger()
    status = struct('ok', false, 'reason', '', 'path', '');
    try
        status.path = which('MOLE_errors');
        probe = MOLE_errors();
        assert(probe.getNumErrors(), 0);
        output = evalc("probe.log_error('MOLE_ERR_INVALID_GRID_SPACING','test preflight',false,'dx = -1');");
        assert(~isempty(output));
        assert(probe.getNumErrors(), 1);
        assert(probe.haveErrors(), true);
        status.ok = true;
    catch err
        status.reason = err.message;
    end
end
