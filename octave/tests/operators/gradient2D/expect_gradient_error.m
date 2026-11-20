function caughtError = expect_gradient_error(action, errors, errorName)
% PURPOSE
% Require an invalid gradient input to raise a recorded MOLE error.
% SYNTAX
% caughtError = expect_gradient_error(action, errors, errorName)
% DESCRIPTION
% Invokes a function handle and checks the exact MOLE identifier and the
% supplied logger's count. errorName is the catalog key without MOLE:.
% ----------------------------------------------------------------------------
% SPDX-License-Identifier: GPL-3.0-or-later
% © 2008-2024 San Diego State University Research Foundation (SDSURF).
% See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
% ----------------------------------------------------------------------------
    before = errors.getNumErrors();
    caught = false;
    caughtError = struct();
    try
        action();
    catch err
        caught = true;
        caughtError = err;
    end
    expectedId = ['MOLE:' errorName];
    assert(caught, ['Expected ' expectedId ' to be raised.']);
    assert(strcmp(caughtError.identifier, expectedId), ...
           sprintf('Expected %s; received "%s": %s', ...
                   expectedId, caughtError.identifier, caughtError.message));
    assert(isequal(errors.getNumErrors(), before + 1), 'Expected exactly one newly recorded error.');
    assert(isequal(errors.haveErrors(), true), 'The logger must report a recorded error.');
end
