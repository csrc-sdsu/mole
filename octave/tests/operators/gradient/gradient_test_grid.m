function grid = gradient_test_grid(m, dx, isPeriodic)
% PURPOSE
% Construct a one-dimensional fixture for gradient unit tests.
% SYNTAX
% grid = gradient_test_grid(m, dx, isPeriodic)
% DESCRIPTION
% Supplies the valid, m, dx, and isPeriodic fields consumed by grad.
% Integration tests construct grids directly through validateGrid.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    grid = struct('m', m, 'dx', dx, 'valid', true, 'isPeriodic', isPeriodic);
end
