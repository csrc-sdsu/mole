function caughtError = expect_mole_error(action, errorName)
% Require an exception with the specified MOLE identifier.
% SPDX-License-Identifier: GPL-3.0-or-later
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
           sprintf('Expected %s, received "%s": %s', expectedId, caughtError.identifier, caughtError.message));
end
