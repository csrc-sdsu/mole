function [passed, total] = run_gradient_test_cases(testFunctions)
% PURPOSE
% Execute independent gradient test functions and report every result.
%
% SYNTAX
% [passed, total] = run_gradient_test_cases(testFunctions)
%
% DESCRIPTION
% testFunctions is a cell array of function handles invoked without inputs.
% Each exception counts as a failed case. Later cases still run after a
% failure. Returns successful and total case counts to the calling suite.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    passed = 0;
    total = numel(testFunctions);
    for index = 1:total
        currentTest = testFunctions{index};
        testName = func2str(currentTest);
        try
            currentTest();
            passed = passed + 1;
            fprintf('%s: passed\n', testName);
        catch err
            fprintf('%s: failed [%s]\n%s\n', ...
                    testName, err.identifier, err.message);
        end
    end
    fprintf('Passed %d of %d tests.\n', passed, total);
end
