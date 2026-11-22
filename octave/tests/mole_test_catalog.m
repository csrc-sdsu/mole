function cases = mole_test_catalog()
% PURPOSE
% Discover every current portable MOLE test case under tests.
%
% SYNTAX
% cases = mole_test_catalog()
%
% DESCRIPTION
% Finds suites whose filenames start or end with test, case-insensitively.
% Each suite exposes [passed,total,functions] = suite(false) for discovery.
% Returns named zero-input case handles without executing test bodies.
% Raises an error for unsupported or empty suites instead of skipping them.
% old_version folders and CI reporting adapters are excluded by setup.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    paths = mole_test_setup();
    if isempty(paths.suiteFiles)
        error('MOLETests:NoTests', 'No current test suites were found.');
    end
    cases = struct();
    suiteNames = {};
    for i = 1:numel(paths.suiteFiles)
        file = paths.suiteFiles{i};
        [folder, name] = fileparts(file);
        if any(strcmpi(suiteNames, name))
            error('MOLETests:DuplicateSuite', 'Duplicate suite filename: %s', name);
        end
        suiteNames{end+1} = name;
        addpath(folder);
        if ~strcmp(which(name), file)
            error('MOLETests:Setup', 'Suite %s resolved to the wrong file.', name);
        end
        if nargin(name) < 1 || nargout(name) < 3
            error('MOLETests:UnsupportedSuite', ...
                  'Suite %s must expose [passed,total,functions] = %s(false).', file, name);
        end
        [~, total, functions] = feval(name, false);
        if ~iscell(functions) || isempty(functions) || total ~= numel(functions)
            error('MOLETests:CountMismatch', 'Invalid or empty case list in %s.', file);
        end
        for j = 1:numel(functions)
            if ~isa(functions{j}, 'function_handle')
                error('MOLETests:InvalidCase', 'Invalid case handle in %s.', file);
            end
            caseName = regexprep(func2str(functions{j}), '^.*[>/]', '');
            key = [name '_' caseName];
            if ~isvarname(key) || isfield(cases, key)
                error('MOLETests:InvalidCase', 'Invalid or duplicate case name: %s', key);
            end
            cases.(key) = functions{j};
        end
    end
end
