function results = run_gradient_ci()
% PURPOSE
% Preserve the previous CLI entry point while running all current tests.
% SYNTAX
% results = run_gradient_ci()
% DESCRIPTION
% Delegates to run_mole_ci, which generates JUnit and coverage XML and
% excludes old_version. The test scope is now the complete current suite.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    results = run_mole_ci();
end
