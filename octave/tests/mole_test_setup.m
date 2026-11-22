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
    paths.tests = fileparts(mfilename('fullpath'));
    paths.src = fullfile(fileparts(paths.tests), 'src');
    if ~isfolder(paths.src)
        error('MOLETests:Setup', 'Missing source directory: %s', paths.src);
    end
    entries = strsplit(path, pathsep);
    octaveRoot = [fileparts(paths.tests) filesep];
    for i = 1:numel(entries)
        if strncmpi(entries{i}, octaveRoot, numel(octaveRoot)) && ...
                ~isempty(regexpi(entries{i}, '(^|[\\/])old_version([\\/]|$)', 'once'))
            rmpath(entries{i});
        end
    end
    [sourceDirs, paths.sourceFiles] = localWalk(paths.src, '');
    [testDirs, testFiles] = localWalk(paths.tests, fullfile(paths.tests, 'ci'));
    localAddFolders(sourceDirs, paths.src);
    localAddFolders(testDirs, paths.tests);
    paths.suiteFiles = {};
    for i = 1:numel(testFiles)
        [~, name] = fileparts(testFiles{i});
        if ~isempty(regexpi(name, '(^test|test$)', 'once'))
            paths.suiteFiles{end+1} = testFiles{i};
        end
    end
    paths.suiteFiles = sort(paths.suiteFiles);
    paths.sourceFiles = sort(paths.sourceFiles);
end

function [folders, files] = localWalk(root, excluded)
    folders = {root};
    files = {};
    entries = dir(root);
    for i = 1:numel(entries)
        name = entries(i).name;
        if isempty(name) || name(1) == '.' || strcmpi(name, 'old_version')
            continue;
        end
        fullName = fullfile(root, name);
        if strcmp(fullName, excluded)
            continue;
        end
        if entries(i).isdir
            [children, childFiles] = localWalk(fullName, excluded);
            folders = [folders, children];
            files = [files, childFiles];
        else
            [~, ~, extension] = fileparts(name);
            if strcmpi(extension, '.m')
                files{end+1} = fullName;
            end
        end
    end
end

function localAddFolders(folders, root)
    for i = numel(folders):-1:1
        relative = folders{i}(numel(root)+1:end);
        parts = regexp(relative, '[\\/]', 'split');
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
