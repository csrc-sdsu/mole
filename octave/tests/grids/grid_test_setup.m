function paths = grid_test_setup()
% Add grid implementations, error handling, and test helpers to the path.
% SPDX-License-Identifier: GPL-3.0-or-later
    paths.tests = fileparts(mfilename('fullpath'));
    octaveDir = fileparts(fileparts(paths.tests));
    paths.grids = fullfile(octaveDir, 'src', 'grids');
    paths.sys = fullfile(octaveDir, 'src', 'sys');
    if ~isfolder(paths.grids) || ~isfolder(paths.sys)
        error('MOLETests:Setup', 'Place these files in octave/tests/grids beside octave/src/grids and octave/src/sys.');
    end
    addpath(paths.tests);
    addpath(paths.sys);
    addpath(paths.grids);
end
