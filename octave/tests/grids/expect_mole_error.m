function caughtError = expect_mole_error(action, errorName)
% PURPOSE
% Require an exception with the specified MOLE identifier.
% SYNTAX
% caughtError = expect_mole_error(action, errorName)
% DESCRIPTION
% action is a function handle invoked without arguments. errorName is the
% catalog key without the MOLE: prefix. Returns the caught error structure.
% Fails an assertion if no exception is raised or its identifier differs.
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
