function paths = mole_test_setup()
% PURPOSE
% Find current MOLE sources and tests while excluding old_version folders.
%
% SYNTAX
% paths = mole_test_setup()
%
% DESCRIPTION
% Recursively adds current source and test-helper folders to the path.
% Returns sourceFiles for coverage and suiteFiles for portable test discovery.
% The ci folder contains reporting adapters and is not a portable suite.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    % Resolve paths from this file, independent of the working directory.
    paths.tests = fileparts(mfilename('fullpath'));
    paths.src = fullfile(fileparts(paths.tests), 'src');
    % Stop early if the expected source tree is missing.
    if ~isfolder(paths.src)
        error('MOLETests:Setup', 'Missing source directory: %s', paths.src);
    end
    % Remove legacy paths from this checkout, leaving unrelated paths alone.
    entries = strsplit(path, pathsep);
    octaveRoot = [fileparts(paths.tests) filesep];
    for i = 1:numel(entries)
        % Match complete directory names with either path separator
        if strncmpi(entries{i}, octaveRoot, numel(octaveRoot)) && ...
                ~isempty(regexpi(entries{i}, '(^|[\\/])old_version([\\/]|$)', 'once'))
            rmpath(entries{i});
        end
    end
    % Collect .m files for coverage and discovery; exclude CI adapters
    [sourceDirs, paths.sourceFiles] = localWalk(paths.src, '');
    [testDirs, testFiles] = localWalk(paths.tests, fullfile(paths.tests, 'ci'));
    % Add current source and test-helper folders to the search path
    localAddFolders(sourceDirs, paths.src);
    localAddFolders(testDirs, paths.tests);
    % Suite filenames start or end with "test", ignoring case
    paths.suiteFiles = {};
    for i = 1:numel(testFiles)
        [~, name] = fileparts(testFiles{i});
        if ~isempty(regexpi(name, '(^test|test$)', 'once'))
            paths.suiteFiles{end+1} = testFiles{i};
        end
    end
    % Keep discovery and coverage file lists in a consistent order.
    paths.suiteFiles = sort(paths.suiteFiles);
    paths.sourceFiles = sort(paths.sourceFiles);
end

function [folders, files] = localWalk(root, excluded)
    % Return folders for path setup and .m files for coverage or discovery.
    % Store the root before descendants to preserve parent-first ordering.
    folders = {root};
    files = {};
    entries = dir(root);
    for i = 1:numel(entries)
        name = entries(i).name;
        % Skip hidden entries (including . and ..) and legacy content.
        if isempty(name) || name(1) == '.' || strcmpi(name, 'old_version')
            continue;
        end
        % Keep full paths so later steps do not depend on the working folder.
        fullName = fullfile(root, name);
        % Skip the excluded subtree entirely, including its descendants.
        if strcmp(fullName, excluded)
            continue;
        end
        if entries(i).isdir
            % Accumulate the subdirectory's folders and source files.
            [children, childFiles] = localWalk(fullName, excluded);
            folders = [folders, children];
            files = [files, childFiles];
        else
            [~, ~, extension] = fileparts(name);
            % Ignore data files and other repository assets.
            if strcmpi(extension, '.m')
                files{end+1} = fullName;
            end
        end
    end
end

function localAddFolders(folders, root)
    % addpath prepends; reverse traversal puts parents before descendants.
    for i = numel(folders):-1:1
        % Inspect only components inside this root, not its ancestor folders.
        relative = folders{i}(numel(root)+1:end);
        parts = regexp(relative, '[\\/]', 'split');
        % Package, class, and private folders resolve through their parents.
        % Exclude these folders and their descendants from direct path entries.
        special = false;
        for j = 1:numel(parts)
            if ~isempty(parts{j}) && (parts{j}(1) == '+' || parts{j}(1) == '@' || strcmp(parts{j}, 'private'))
                special = true;
                break;
            end
        end
        if ~special
            addpath(folders{i});
        end
    end
end



