# Octave grid tests

The grid implementations belong in `octave/src/grids`; error handling and its
dependencies belong in `octave/src/sys`.

Run from the repository root:

```octave
addpath('octave/tests/grids');
report = run_grid_tests();
```

For individual test bodies and failure output:

```octave
report = run_grid_tests(true);
```

The report distinguishes passed tests, assertion failures, and tests blocked by
source-loading or setup errors. Calling the runner without an output argument
raises an error if any test fails or is blocked:

```sh
octave --no-gui --quiet --eval "addpath('octave/tests/grids'); run_grid_tests();"
```

Individual test files can also be run:

```octave
[passed, total] = test_grid2D();
```
