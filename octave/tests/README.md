# GNU Octave tests (fully MATLAB compatible)

This directory contains the shared tests for MOLE error logging, grid
construction and validation, and operators. The portable runner and the MATLAB
CI adapter execute the same case functions. Directories named `old_version`
are excluded from the current test run.

## Requirements

- A repository checkout containing both `octave/tests` and `octave/src`.
- GNU Octave, or MATLAB. The MATLAB XML-reporting adapter requires R2021a or
  later. The portable runner has been exercised with GNU Octave 9.4.
- The current source files and `octave/src/sys/errors.json` in their repository
  locations. The setup helpers configure source and test-helper paths.
- For shell commands, the selected executable (`octave` or `matlab`) must be on
  the system `PATH`.

Run the following commands from the **repository root**, the directory that
contains `octave/`. No C++ build is required by the current shared test suites.

## Test layout

- `errors/`: error catalog, logging, and exception behavior.
- `grids/`: grid construction, validation, and inferred attributes.
- `operators/gradient/`: one-dimensional gradient operators.
- `operators/gradient2D/`: two-dimensional gradient assembly and interface.
- `ci/`: MATLAB adapters and XML-reporting entry points.
- `mole_test_setup.m`, `mole_test_catalog.m`, and `run_mole_tests.m`: shared
  path setup, case discovery, and execution.

## Quick start

### Run all tests in Octave

```sh
octave --no-gui --quiet --eval "addpath('octave/tests'); run_mole_tests();"
```

### Run all tests in MATLAB and generate XML reports

```sh
matlab -batch "addpath('octave/tests/ci'); run_mole_ci();"
```

This runs the tests serially and writes reports under the repository root:

- `test-results/results.xml`: JUnit results with individual case names, status,
  execution times, and failure details.
- `code-coverage/coverage.xml`: Cobertura source-line coverage.

Existing files at those report paths are overwritten by a subsequent run.
Ordinary test failures are reported individually; remaining cases can continue.
After the run and report generation, failed or incomplete MATLAB results cause
the batch command to exit with a nonzero status.

### Run interactively in either application

From the repository root in the MATLAB or Octave command window:

```matlab
addpath('octave/tests');
run_mole_tests();
```

This prints results to the console. The portable runner does not create JUnit
or coverage XML; use `run_mole_ci` in MATLAB when those reports are needed.
Octave does not load the MATLAB-specific adapter under `ci/`.

## Results and exit status

The portable runner prints a result for each case and a final total. A case
name combines the suite filename and local function name, for example:

```text
test_grad2D_testAxisAssembly: passed
```

A case function counts as one test, even when it contains several assertions
or loops over multiple inputs. Test totals therefore reflect registered case
functions, not the number of assertions or numerical parameter combinations.

Calling `run_mole_tests()` **without an output argument** attempts all discovered
cases and raises `MOLETests:Failed` afterwards if any case failed. Use this form
for shell scripts and CI so a failed run produces a nonzero exit status.

To inspect results programmatically:

```matlab
report = run_mole_tests();
failedCases = report.results(~[report.results.passed]);
assert(report.ok, 'MOLE tests failed.');
```

The report contains:

- `total`, `passed`, `failed`, and `ok`: overall counts and status.
- `results`: one structure per case, containing `name`, `passed`, `duration`
  in seconds, `identifier`, and `message`.

Capturing the report suppresses the final failure exception; retain
the explicit status check when using that form in automation. Discovery and
setup errors still raise immediately because execution cannot start reliably.
The grid group runner also reports `blocked` cases when a dependency cannot be
loaded or the test infrastructure prevents execution; those cases did not pass.

## Run a smaller selection

Configure paths once from the repository root:

```matlab
addpath('octave/tests');
mole_test_setup();
```

Then use the appropriate suite or group runner:

```matlab
test_errors();             % Error-logging tests.
run_grid_tests(true);       % Grid suites, with individual diagnostics.
run_gradient_tests(true);   % The three one-dimensional gradient suites.
test_grad2D();              % Two-dimensional gradient assembly and interface.
```

`run_gradient_tests` covers the 1D suites only; `run_mole_tests` includes both
the 1D and 2D suites automatically. Group runners are convenient subsets and
are not executed again by the all-tests runner. Their suite lists are explicit;
update the relevant group runner if a new suite should belong to that subset.

To rerun one case, use its name from the output:

```matlab
cases = mole_test_catalog();
caseFunction = cases.test_grad2D_testAxisAssembly;
caseFunction();
```

List the currently registered names with `fieldnames(cases)`. Calling the case
handle directly raises its exception immediately if it fails.

## Discovery and exclusions

[`mole_test_setup.m`](mole_test_setup.m) recursively scans the current test and
source trees. [`mole_test_catalog.m`](mole_test_catalog.m) obtains the case
handles from every discovered portable suite.

The discovery rules are:

- A suite is an `.m` file whose basename starts or ends with `test`, ignoring
  case. Examples include `test_grid1D.m` and `testMakeGrid.m`.
- The main function must have the same name as its file and provide the
  discovery interface described below.
- Suite filenames must be unique across the current tree, ignoring case.
- Directories named `old_version` are skipped at any depth, ignoring case.
- Hidden entries are skipped. The top-level `ci/` directory is reserved for
  reporting infrastructure and is excluded from portable suite discovery.
- Empty suites, invalid handles, duplicate case names, and unsupported suite
  interfaces cause an error instead of being silently skipped.

Setup also removes existing project search-path entries under `old_version`
and does not add those directories again. Helpers should have names that do
not start or end with `test`, so they are not mistaken for suites.

## How MATLAB CI works

The workflow is
[`run-matlab-tests.yml`](../../.github/workflows/run-matlab-tests.yml). Its
configured push and pull-request events start the MATLAB test job.

1. The job checks out the repository and installs the selected MATLAB release.
2. `matlab-actions/run-tests@v3` selects `octave/tests/ci/current`.
3. [`MoleCITest`](ci/current/MoleCITest.m) calls the shared catalog, which discovers
   suites throughout `octave/tests`, excluding `old_version`.
4. MATLAB creates one parameterized test per shared case. A case exception is
   recorded against that individual test rather than hidden in a suite total.
5. The action generates JUnit and Cobertura XML and a GitHub job summary.
6. The upload steps publish `matlab-test-results` and `matlab-code-coverage`.
   Their `if: always()` setting attempts uploads even when the test step fails;
   reports must have been created for those uploads to contain files.

Although the YAML selects only the adapter directory, the adapter registers
all current shared cases. Pointing the MATLAB action directly at the portable
suite directories does not replace this integration.

The workflow's `source-folder` setting controls its coverage scope. It currently
lists `octave/src/operators`, `octave/src/grids`, and `octave/src/sys`, excluding
the legacy top-level source directory. Update that setting when adding a new
top-level source area that also needs coverage. The standalone `run_mole_ci`
command gets its coverage file list recursively from `mole_test_setup`, excluding
`old_version` directories.

The MATLAB workflow runs MATLAB, not Octave. Octave CI requires a separate job
that installs Octave and invokes the portable quick-start command above.

### Reporting files

- [`ci/current/MoleCITest.m`](ci/current/MoleCITest.m) registers and executes the
  shared case functions through MATLAB's testing framework. It contains no
  copies of the numerical assertions and does not write reports itself.
- [`ci/run_mole_ci.m`](ci/run_mole_ci.m) is the standalone MATLAB reporting entry
  point. It checks registration counts, attaches the JUnit and coverage plugins,
  runs the suite, and calls `assertSuccess` after reporting.
- [`ci/run_gradient_ci.m`](ci/run_gradient_ci.m) preserves the previous command
  name by forwarding to `run_mole_ci`. It now runs all current suites, despite
  its older name. Prefer `run_mole_ci` in new scripts.

The GitHub action configures reporting itself; it does not call the standalone
`run_mole_ci` function. Both execution paths use the same MATLAB adapter and
shared case catalog.

## Add or maintain tests

### Add a case to an existing suite

1. Add a local, zero-input function for the new behavior.
2. Add its function handle to the suite's `testFunctions` list.
3. Run the affected suite, then run the all-tests command in both runtimes.

The case is automatically included in the shared catalog and MATLAB CI. A
local function that is not registered in `testFunctions` is not executed.

Keep each case independent: create fresh mutable objects, avoid relying on
execution order, and clean up any resources or state it changes. Use assertions
supported by both MATLAB and Octave. Check exception identifiers when the API
promises a particular MOLE error; an unrelated exception must not count as an
expected failure. Select floating-point tolerances from the numerical behavior
being checked rather than relaxing them to make a failure disappear.

Keep 1D stencil accuracy and convergence checks in the 1D suites. The 2D suite
should focus on assembly, axis mapping, mixed periodicity, and its own interface.
Add coverage for a distinct behavior rather than duplicating an existing test.

### Add a suite

Use an existing suite such as
[`test_grad2D.m`](operators/gradient2D/test_grad2D.m) as a working template.
Place the new file in the appropriate current test directory and preserve this
interface:

```matlab
function [passed, total, testFunctions] = test_feature(runTests)
```

The required behavior is:

- With no input, default `runTests` to logical `true` and execute the suite.
- Return the successful count as `passed`, the registered count as `total`, and
  the cell array of zero-input handles as `testFunctions`.
- With logical `false`, return the handles and total without executing case
  bodies. Discovery uses this mode to build individual MATLAB tests.
- When called without outputs, raise an error after a failed suite run so the
  direct CLI call cannot appear successful.

Define each case locally in its suite and give it a descriptive name. The
combined `suiteName_caseName` must be a valid MATLAB/Octave structure field name.
Case setup needed for execution should occur in the cases or their shared
helpers, not solely in the main suite function: the all-tests runner and MATLAB
adapter invoke case handles directly.

New suite files following this contract are discovered recursively; no suite
list needs to be added to the CI adapter. For additional details, see the
[MATLAB action documentation](https://github.com/matlab-actions/run-tests) and
[MATLAB parameterized-test documentation](https://www.mathworks.com/help/matlab/matlab_prog/define-parameters-at-suite-creation-time.html).

## Troubleshooting

- **Executable not found:** make the installed MATLAB or Octave executable
  available on `PATH`, or invoke it by its full path.
- **`run_mole_tests` is undefined:** run from the repository root and execute
  `addpath('octave/tests')` before calling it. Add `octave/tests/ci` for
  `run_mole_ci` instead.
- **`MOLETests:Setup`:** confirm that the current source directories, test
  helpers, and error catalog are present. Use `which('grad')`,
  `which('validateGrid')`, or `which('MOLE_errors')` to inspect resolved files.
- **`MOLETests:UnsupportedSuite`:** update the indicated suite to expose the
  three-output `suite(false)` discovery interface.
- **`MOLETests:DuplicateSuite` or `MOLETests:InvalidCase`:** use unique suite
  filenames and case identifiers; inspect the filename or identifier in the
  diagnostic.
- **Missing cases or `MOLETests:CountMismatch`:** inspect the suite's
  `testFunctions` list and confirm `total` matches its length. Discovery errors
  stop the run before normal case execution.
- **XML files are missing:** the portable runner does not create them. Use the
  MATLAB reporting command or the MATLAB workflow, and inspect discovery/setup
  failures if MATLAB did not reach the reporting stage. A report left from an
  earlier run does not prove that the latest run completed.
- **Unexpected coverage scope:** compare the YAML `source-folder` setting with
  the intended current source folders; the local MATLAB runner uses
  the `sourceFiles` field returned by `mole_test_setup` as its source list.

<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
