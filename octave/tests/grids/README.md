# MATLAB and GNU Octave grid tests

Place all files in this directory at `octave/tests/grids` in the MOLE checkout.
The grid implementations belong in `octave/src/grids`; `MOLE_errors.m` and
`errors.json` belong in `octave/src/sys`.

Run the same command from the repository root in MATLAB or GNU Octave:

```matlab
addpath('octave/tests/grids');
report = run_grid_tests();
```

Display individual test names and failure messages with:

```matlab
report = run_grid_tests(true);
```

The seven suites contain 53 cases. The report distinguishes passed tests,
failed cases, and cases blocked by dependency-loading or setup errors.
`report.results` retains each suite's captured output and any blocking reason.
`report.preflight` records dependency checks. `report.sources` records the
resolved implementation paths; it does not require a hashing or Java API.

Calling the runner without output arguments raises `MOLETests:Incomplete`
if any test fails or is blocked:

```matlab
run_grid_tests();
```

The command-line equivalents are:

```sh
octave --no-gui --quiet --eval "addpath('octave/tests/grids'); run_grid_tests();"
matlab -batch "addpath('octave/tests/grids'); run_grid_tests();"
```

Individual suites can also be called directly:

```matlab
[passed, total] = test_grid2D();
```

Each suite uses ordinary local test functions and the shared
`run_grid_test_cases.m` helper. There is no dependency on Octave BIST or
`matlab.unittest`. These are custom function runners; call them directly
rather than through an environment's native `runtests` command.

The assertions preserve the original exact equality checks. Expected MOLE
exceptions are checked by identifier, and valid inputs must leave the logger
empty and produce no console output. The suite covers uniform grids in one,
two, and three dimensions, supplied coordinates, inferred attributes,
constructor input forms, a curvilinear construction, and validation input
forms. It does not test boundary conditions.

The implementation files must also use syntax and APIs supported by the
environment in which the tests are run. A MATLAB parse error in a dependency
is reported as blocked; converting these tests does not convert the library
implementation. MATLAB execution must be checked separately from Octave.
