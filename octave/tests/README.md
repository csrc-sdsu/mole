# GNU Octave tests (fully MATLAB compatible)

This directory contains the GNU Octave tests for MOLE error logging, grid
construction and validation, and operators. The portable runner executes the
same registered case functions used by CI. Directories named `old_version`
are excluded from the current test run.

[Run tests](#quick-start) · [Add tests](#add-or-maintain-tests) · [CI and reports](#how-ci-works)

## Requirements

- A repository checkout containing both `octave/tests` and `octave/src`.
- GNU Octave. The portable runner has been exercised with GNU Octave 9.4.
- The current source files and `octave/src/sys/errors.json` in their repository
  locations. The setup helpers configure source and test-helper paths.
- For shell commands, the `octave` executable must be on the system `PATH`.

Run the following commands from the **repository root**, the directory that
contains `octave/`. No C++ build is required by the current shared test suites.

## Test layout

- `errors/`: error catalog, logging, and exception behavior.
- `grids/`: grid construction, validation, and inferred attributes.
- `operators/gradient/`: one-dimensional gradient operators.
- `operators/gradient2D/`: two-dimensional gradient assembly and interface.
- `ci/`: CI reporting adapters and XML-reporting entry points.
- `mole_test_setup.m`, `mole_test_catalog.m`, and `run_mole_tests.m`: shared
  path setup, case discovery, and execution.

## Quick start

Run shell commands in a system terminal and enter test-runner calls in the
Octave command window. Save the new-suite template as an `.m` file, as
instructed below. Examples start from the repository root unless another
working directory is specified.

### Run all tests in Octave

```sh
octave --no-gui --quiet --eval "addpath('octave/tests'); run_mole_tests();"
```

### Run interactively in Octave

From the repository root in the Octave command window:

```octave
addpath('octave/tests');
run_mole_tests();
```

This prints individual case results and a final total to the console. XML
reports and coverage are provided by the separate CI reporting integration
[described below](#xml-reporting-integration).

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

```octave
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
These group reports are separate from the per-case `run_mole_tests` report.

## Run a smaller selection

Configure paths once from the repository root:

```octave
addpath('octave/tests');
mole_test_setup();
```

Choose one of the following commands for the scope you want to run:

```octave
test_errors();             % Error-logging tests.
run_grid_tests(true);       % Grid suites, with individual diagnostics.
run_gradient_tests(true);   % The three one-dimensional gradient suites.
test_grad2D();              % Two-dimensional gradient assembly and interface.
```

`run_gradient_tests` covers the 1D suites only; `run_mole_tests` includes both
the 1D and 2D suites automatically. Group runners are convenient subsets and
are not executed again by the all-tests runner. Their suite lists are explicit;
update the relevant group runner if a new suite should belong to that subset.
Individual suites return `[passed, total]` when requested; group runners return
report structures. When capturing suite counts, check them explicitly:

```octave
[passed, total] = test_grad2D();
assert(passed == total, 'Gradient suite failed.');
```

To rerun one case, use its name from the output:

```octave
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
- Put suites in ordinary test folders. `private`, `+package`, and `@class`
  directories are not added directly to the search path.
- Directories named `old_version` are skipped at any depth, ignoring case.
- Hidden entries are skipped. The top-level `ci/` directory is reserved for
  reporting infrastructure and is excluded from portable suite discovery.
- Empty suites, invalid handles, duplicate case names, and unsupported suite
  interfaces cause an error instead of being silently skipped.

Setup also removes existing project search-path entries under `old_version`
and does not add those directories again. 

**Helpers should have names that do not start or end with `test`, so they are not mistaken for suites.**

## How CI works

The [workflow configuration](../../.github/workflows) defines the jobs, test
commands, and uploaded artifacts. For Octave execution, install Octave on the
runner and invoke the same all-tests command used locally. A test step is:

```yaml
- name: Run Octave tests
  working-directory: octave/tests
  run: octave --no-gui --quiet --eval "run_mole_tests();"
```

The test step follows this sequence:

1. `mole_test_setup` adds current source and helper directories to the path,
   excluding `old_version` and the CI reporting adapters.
2. `mole_test_catalog` discovers the portable suites and obtains their named
   case handles without executing the case bodies.
3. `run_mole_tests` executes each case and records its status, duration, and
   failure details.
4. The runner prints individual results and a final total. If any case fails,
   its final exception gives the Octave process a nonzero exit status, failing
   the CI step.

Calling `test('run_mole_tests.m')` searches for built-in `%!test` blocks; call
`run_mole_tests()` directly to execute these shared suites. When checking more
than one execution environment, independent jobs allow each to report its own
result.

### XML reporting integration

The portable Octave runner provides console output and the result structure
described above. XML generation is configured separately through the CI
reporting adapters. These adapters require the reporting environment configured
by the workflow and cannot be run directly in Octave.

When the reporting integration is enabled, it produces these files under the
repository root:

- `test-results/results.xml`: JUnit results with individual case names, status,
  execution times, and failure details.
- `code-coverage/coverage.xml`: Cobertura source-line coverage.

The workflow uploads these files as artifacts and can generate a job summary.
The upload steps use `if: always()` to attempt uploads after a failed test step;
reports must have been created for those uploads to contain files. Existing
report files are overwritten by subsequent report-producing runs. Each XML
report describes the reporting integration's own test run; it does not include
the outcome of a separate Octave step.

Selecting `octave/tests/ci/current` for the reporting integration registers all
shared cases through its adapter. The adapter uses the shared catalog, so its
case selection follows the same discovery and exclusion rules as the Octave
runner.

The reporting action's `source-folder` setting controls its coverage scope.
It lists `octave/src/operators`, `octave/src/grids`, and `octave/src/sys` in the
supplied configuration. Update that setting when adding a new top-level source
area that also needs coverage. The standalone reporting entry point obtains
its coverage file list recursively from `mole_test_setup`, excluding
`old_version` directories.

### Reporting files

- [`ci/current/MoleCITest.m`](ci/current/MoleCITest.m) registers and executes the
  shared case functions through the reporting framework. It contains no copies
  of the numerical assertions and does not write reports itself.
- [`ci/run_mole_ci.m`](ci/run_mole_ci.m) is the reporting entry point. In its
  supported reporting environment, it checks registration counts, attaches the
  JUnit and coverage plugins, runs the suite, and calls `assertSuccess` after
  reporting. Use `run_mole_tests` for Octave execution.
- [`ci/run_gradient_ci.m`](ci/run_gradient_ci.m) preserves the previous reporting
  command name by forwarding to `run_mole_ci`. It now covers all current suites,
  despite its older name.

The reporting action configures its own reports; it does not call the
standalone `run_mole_ci` function. Both reporting paths use the same adapter and
shared case catalog.

## Add or maintain tests

### Add a case to an existing suite

1. Open the appropriate suite in `errors/`, `grids/`, or `operators/`.
2. Add a local, zero-input function using the form `function testNewBehavior()`.
3. Add `@testNewBehavior` to the suite's `testFunctions` list. A local function
   alone is not registered for execution.
4. Run the affected suite, then run `run_mole_tests()` from the configured
   Octave session.

The current grid and 1D gradient group runners count declarations of the form
`function testName()`. Use this naming and declaration style for cases, and
reserve it for registered cases. Give local helpers other names.

Keep each case independent: create fresh mutable objects, avoid relying on
execution order, and clean up any resources or state it changes. Use portable
syntax such as `%` comments, `end`, and explicit assignments. For exact
comparisons, use `assert(isequal(actual, expected), 'Diagnostic message.');`.
Select floating-point tolerances from the numerical behavior being checked.

For expected failures, check the exact exception identifier so an unrelated
exception cannot count as success. Reuse the domain helpers where applicable:
[`expect_mole_error`](grids/expect_mole_error.m) checks grid-error identifiers;
[`expect_gradient_error`](operators/gradient/expect_gradient_error.m) also
checks the supplied logger's recorded-error count and status.

Keep 1D stencil accuracy and convergence checks in the 1D suites. The 2D suite
should focus on assembly, axis mapping, mixed periodicity, and its own interface.
Add coverage for a distinct behavior rather than duplicating an existing test.

### Add a suite

For a new suite in an existing domain, copy a nearby suite such as
[`test_grad2D.m`](operators/gradient2D/test_grad2D.m), retaining its header,
setup, and failure reporting. Rename both the file and main function, then
replace its case list and case bodies with the new tests.

For a new test area, the template below provides the portable discovery and
execution interface without depending on a domain-specific runner. Save it as
`octave/tests/<area>/test_feature.m`, replacing `<area>` with the relevant
folder. Rename the file, main function, and cases to describe the feature.

**The placeholder case deliberately fails. Replace its `error(...)` call with
real test assertions before submitting the suite.** Expand the file header
using the neighboring suites' documentation and license format.

```octave
function [passed, total, testFunctions] = test_feature(runTests)
% PURPOSE
% Test feature behavior.
% SYNTAX
% test_feature()
% [~, total, testFunctions] = test_feature(false)
% SPDX-License-Identifier: GPL-3.0-or-later
    if nargin < 1
        runTests = true;
    elseif ~islogical(runTests) || ~isscalar(runTests)
        error('MOLETests:InvalidInput', 'runTests must be a logical scalar.');
    end

    testFunctions = {@testExpectedBehavior};
    total = numel(testFunctions);
    passed = 0;
    if ~runTests
        return;
    end

    mole_test_setup();
    for index = 1:total
        currentTest = testFunctions{index};
        try
            currentTest();
            passed = passed + 1;
            fprintf('%s: passed\n', func2str(currentTest));
        catch err
            fprintf('%s: failed [%s]\n%s\n', ...
                    func2str(currentTest), err.identifier, err.message);
        end
    end
    fprintf('Passed %d of %d tests.\n', passed, total);
    if nargout == 0 && passed ~= total
        error('MOLETests:Failed', '%d of %d tests failed.', total - passed, total);
    end
end

function testExpectedBehavior()
    error('MOLETests:UnimplementedCase', ...
          'Replace this placeholder with feature-specific assertions.');
end
```

The suite contract is:

- With no input, execute the registered cases.
- With logical `false`, return `passed = 0`, the case count, and the cell array
  of zero-input case handles without executing case bodies. This mode is used
  by both the portable catalog and CI reporting.
- Compute `total` from `numel(testFunctions)` so registration and counts agree.
- Attempt every case during suite execution. When called without outputs,
  raise an error after the run if any case failed.

Suite filenames must follow the discovery rules above. Each combined
`suiteName_caseName` must be a valid identifier. Setup needed by a case belongs
in the case or its helpers: the all-tests runner and CI adapter invoke case
handles directly, bypassing the suite's normal execution branch. Shared source
and helper paths are configured by `mole_test_setup` before those calls.

New suites are discovered recursively by the all-tests runner; no suite list
needs to be added to the catalog or CI adapter. To include a new suite in a
convenience group such as `run_grid_tests`, update that group's explicit list
and preserve its expected suite location.

### Verify registration and execution

After creating a suite, configure paths again so its folder is available.
Replace the example suite and case names below with your actual names:

```octave
addpath('octave/tests');
mole_test_setup();

[passed, total, caseFunctions] = test_feature(false);
assert(passed == 0 && total == numel(caseFunctions) && total > 0);

cases = mole_test_catalog();
assert(isfield(cases, 'test_feature_testExpectedBehavior'), ...
       'The new case was not registered.');

% Run these after implementing the placeholder case.
test_feature();
run_mole_tests();
```

Confirm that the new case appears in the all-tests output. Adding a case to a
suite's local functions or seeing it in the editor is not sufficient. An
Octave `%!test` block alone does not register a portable case; use the function
handle interface above.

## Troubleshooting

- **Executable not found:** make the installed Octave executable available on
  `PATH`, or invoke it by its full path.
- **`run_mole_tests` is undefined:** run from the repository root and execute
  `addpath('octave/tests')` before calling it.
- **`MOLETests:Setup`:** confirm that the current source directories, test
  helpers, and error catalog are present. Use `which('grad')`,
  `which('validateGrid')`, or `which('MOLE_errors')` to inspect resolved files.
- **`MOLETests:UnsupportedSuite`:** update the indicated suite to expose the
  three-output `suite(false)` discovery interface.
- **`MOLETests:DuplicateSuite` or `MOLETests:InvalidCase`:** use unique suite
  filenames and case identifiers; inspect the filename or identifier in the
  diagnostic.
- **Missing cases or `MOLETests:CountMismatch`:** inspect the suite's
  `testFunctions` list and confirm `total` matches its length. Check filename
  discovery rules and the new case's catalog key. Discovery errors stop the
  run before normal case execution.
- **XML files are missing:** Octave execution produces console output and a
  result structure. Check that the separate CI reporting integration is enabled
  and reached its reporting stage. Inspect its discovery/setup diagnostics and
  artifact-upload logs. A report left from an earlier run does not prove that
  the latest run completed.
- **Unexpected coverage scope:** compare the YAML `source-folder` setting with
  the intended current source folders; the standalone reporting runner uses
  the `sourceFiles` field returned by `mole_test_setup` as its source list.

<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
