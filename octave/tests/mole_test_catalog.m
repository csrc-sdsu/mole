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
    % Configure current paths and collect suites using the setup exclusions.
    paths = mole_test_setup();
    % Missing tests must not be mistaken for a successful test run
    if isempty(paths.suiteFiles)
        error('MOLETests:NoTests', 'No current test suites were found.');
    end
    % Map unique case names to handles that the runners can invoke later.
    cases = struct();
    suiteNames = {};
    for i = 1:numel(paths.suiteFiles)
        file = paths.suiteFiles{i};
        [folder, name] = fileparts(file);
        % Reject duplicate basenames even when suites occupy different folders
        if any(strcmpi(suiteNames, name))
            error('MOLETests:DuplicateSuite', 'Duplicate suite filename: %s', name);
        end
        suiteNames{end+1} = name;
        % Ensure name based calls resolve to this exact file avoiding shadowing
        addpath(folder);
        if ~strcmp(which(name), file)
            error('MOLETests:Setup', 'Suite %s resolved to the wrong file.', name);
        end
        % Require the input/output interface used by discovery.
        if nargin(name) < 1 || nargout(name) < 3
            error('MOLETests:UnsupportedSuite', ...
                  'Suite %s must expose [passed,total,functions] = %s(false).', file, name);
        end
        % Request handles and counts without executing the registered cases.
        [~, total, functions] = feval(name, false);
        % Reject empty case lists and inconsistent registration counts.
        if ~iscell(functions) || isempty(functions) || total ~= numel(functions)
            error('MOLETests:CountMismatch', 'Invalid or empty case list in %s.', file);
        end
        for j = 1:numel(functions)
            % Every registered entry must be a callable function handle.
            if ~isa(functions{j}, 'function_handle')
                error('MOLETests:InvalidCase', 'Invalid case handle in %s.', file);
            end
            % Remove scope prefixes from local function names
            caseName = regexprep(func2str(functions{j}), '^.*[>/]', '');
            % Prefix each case with its suite name to distinguish shared names.
            key = [name '_' caseName];
            % Catalog keys must be valid identifiers and unique across suites.
            if ~isvarname(key) || isfield(cases, key)
                error('MOLETests:InvalidCase', 'Invalid or duplicate case name: %s', key);
            end
            % Store the handle; execution belongs to the selected runner
            cases.(key) = functions{j};
        end
    end
end
