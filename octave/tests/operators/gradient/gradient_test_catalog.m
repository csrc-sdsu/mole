function cases = gradient_test_catalog()
% PURPOSE
% Return the named gradient test cases without executing them.
%
% SYNTAX
% cases = gradient_test_catalog()
%
% DESCRIPTION
% Returns a scalar structure of zero-input function handles. Each field
% combines its suite name and case name. The same case functions are used
% by the portable runners and the MATLAB CI adapter.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    testDir = fileparts(mfilename('fullpath'));
    addpath(testDir);
    addpath(fullfile(fileparts(testDir), 'gradient2D'));
    suiteNames = {'test_grad', 'test_gradPeriodic', ...
                  'test_gradNonPeriodic', 'test_grad2D'};
    cases = struct();
    for i = 1:numel(suiteNames)
        [~, total, functions] = feval(suiteNames{i}, false);
        if total == 0 || total ~= numel(functions)
            error('MOLETests:CountMismatch', ...
                  'Suite %s did not provide a nonempty case list.', suiteNames{i});
        end
        for j = 1:numel(functions)
            if ~isa(functions{j}, 'function_handle')
                error('MOLETests:InvalidCase', 'Every case must be a function handle.');
            end
            caseName = regexprep(func2str(functions{j}), '^.*[>/]', '');
            name = [suiteNames{i} '_' caseName];
            if ~isvarname(name) || isfield(cases, name)
                error('MOLETests:InvalidCase', 'Invalid or duplicate case name: %s', name);
            end
            cases.(name) = functions{j};
        end
    end
end
