function paths = gradient_test_setup()
% PURPOSE
% Add gradient sources and test helpers to the MATLAB or Octave path.
% SYNTAX
% paths = gradient_test_setup()
% DESCRIPTION
% Resolves octave/src relative to octave/tests/gradients and adds its
% subdirectories. Returns the test and source directories.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    paths.tests = fileparts(mfilename('fullpath'));
    octaveDir = fileparts(fileparts(paths.tests));
    paths.src = fullfile(octaveDir, 'src');
    if ~isfolder(paths.src)
        error('MOLETests:Setup', 'Place these tests in octave/tests/gradients beside octave/src.');
    end
    addpath(genpath(paths.src));
    addpath(paths.tests);
    required = {'grad', 'gradPeriodic', 'gradNonPeriodic', ...
                'MOLE_errors', 'validateGrid'};
    for i = 1:numel(required)
        if isempty(which(required{i}))
            error('MOLETests:Setup', 'Required function or class %s is not on the MATLAB or Octave path.', required{i});
        end
    end
end
