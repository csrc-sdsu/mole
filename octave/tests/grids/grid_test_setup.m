function paths = grid_test_setup()
% PURPOSE
% Add grid sources, error handling, and test helpers to the Octave path.
% SYNTAX
% paths = grid_test_setup()
% DESCRIPTION
% Resolves the tests, grids, and sys directories relative to this file and
% returns their paths in a structure. Raises MOLETests:Setup if either
% source directory is missing.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    paths.tests = fileparts(mfilename('fullpath'));
    octaveDir = fileparts(fileparts(paths.tests));
    testDir = fileparts(mfilename('fullpath'));
    paths.grids = fullfile(testDir, '..', '..', 'src', 'grids');
    paths.sys = fullfile(testDir, '..', '..', 'src', 'sys');
    if ~isfolder(paths.grids) || ~isfolder(paths.sys)
        error('MOLETests:Setup', 'Place these files in octave/tests/grids beside octave/src/grids and octave/src/sys.');
    end
    addpath(paths.tests);
    addpath(paths.sys);
    addpath(paths.grids);
end
