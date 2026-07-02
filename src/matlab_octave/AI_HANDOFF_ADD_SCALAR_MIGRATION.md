# MATLAB/Octave AddScalar BC Migration Handoff

Date: 2026-05-21
Scope: MATLAB/Octave only (no C++ and no Julia changes)

## 1. Objective and Current Direction

This workstream migrated and hardened boundary-condition handling around the addScalarBC APIs, grid-first validation, and compatibility wrappers.

User constraints that were followed:
- Work only in MATLAB/Octave code.
- Prefer addScalarBC boundary APIs as the active path.
- Keep deprecated robin/mixed wrappers only as compatibility shims.
- Improve grid and boundary validation behavior, including shape checks and clear error IDs.

## 2. Completed Changes

### 2.1 Grid Validation and Normalization
- Hardened validateGrid boundary normalization logic in api/validateGrid_impl.m:
  - Rejects partial boundary specs where only one of bc.dc or bc.nc is provided.
  - Rejects mismatched empty/non-empty bc.dc and bc.nc pairings.
  - Supports scalar shorthand expansion for bc.dc and bc.nc to per-face vectors in 1D, 2D, and 3D.
  - Derives periodicity from normalized dc/nc consistently.

- Consolidated private normalizers to canonical validation path:
  - private/normalizeGrid1D.m now delegates to validateGrid with dim forced to 1.
  - private/normalizeGrid2D.m now delegates to validateGrid with dim forced to 2.
  - private/normalizeGrid3D.m now delegates to validateGrid with dim forced to 3.

### 2.2 addScalarBC Boundary Value Validation
- Improved boundary-value size diagnostics in scalar implementations:
  - boundaries/scalar/addScalarBC2D_impl.m uses explicit size checks with clear error ID:
    - addScalarBC2D:InvalidBoundaryValueSize
  - boundaries/scalar/addScalarBC3D_impl.m uses explicit size checks with clear error ID:
    - addScalarBC3D:InvalidBoundaryValueSize
  - boundaries/scalar/addScalarBC1D_impl.m now also uses explicit size checks with clear error ID:
    - addScalarBC1D:InvalidBoundaryValueSize

### 2.3 Signature Migration for Grid-First Calls
Preferred 5-input grid signature is now:
- addScalarBC1D(A, b, k, grid, v)
- addScalarBC2D(A, b, k, grid, v)
- addScalarBC3D(A, b, k, grid, v)

Updated wrappers:
- addScalarBC1D.m
- addScalarBC2D.m
- addScalarBC3D.m

Behavior in wrappers:
- New order above is preferred and documented in SYNTAX.
- Legacy order remains temporarily accepted for compatibility:
  - addScalarBC* (A, b, grid, k, v)
- Invalid 5-input usage now throws explicit error IDs:
  - addScalarBC1D:InvalidGridSignature
  - addScalarBC2D:InvalidGridSignature
  - addScalarBC3D:InvalidGridSignature

### 2.4 Compatibility Architecture and Layout Cleanup
- Scalar implementations moved under boundaries/scalar with top-level compatibility entry points.
- Scalar helper functions addScalarBC*lhs and addScalarBC*rhs delegate to boundaries/scalar implementations.
- Deprecated robin and mixed wrappers remain as compatibility shims and emit consistent deprecation warnings via shared helper.
- Robin and mixed internals were moved under boundaries/robin and boundaries/mixed and deduplicated with shared local helpers.

### 2.5 Call-Site and Documentation Updates
- Updated remaining MATLAB grid-first call sites to preferred argument order for addScalarBC1D/2D/3D.
- Updated documentation references, including STRUCTURE_V2.md, to reflect preferred order and normalization architecture.
- Added/updated example coverage including grid-first example for periodic-x / Dirichlet-y flow.

## 3. Test Coverage Added or Expanded

Primary test file:
- tests/matlab_octave/testBCConsistency.m

Coverage includes:
- Explicit vs grid signatures for addScalarBC1D/2D/3D.
- Compatibility wrappers equivalence for robinBC* and mixedBC*.
- Scalar shorthand in grid.bc.dc and grid.bc.nc for 1D/2D/3D.
- Negative boundary-value shape tests with explicit error IDs for 1D/2D/3D.
- Legacy grid-signature compatibility tests:
  - New preferred form vs old legacy form must match numerically for 1D/2D/3D.
- Invalid 5-input signature tests:
  - Verifies InvalidGridSignature error IDs and guidance text for addScalarBC1D/2D/3D.

Additional migration/runtime test:
- tests/matlab_octave/testGridFirstV2Migration.m

## 4. Validation Status

Regression subset repeatedly executed and currently passing:
- testBCConsistency
- testGridFirstV2Migration
- testPoissonAccuracy

Latest observed status:
- 18 passed, 0 failed, 0 incomplete.

Note on expected output noise:
- Deprecation warnings for robinBC* and mixedBC* are expected and intentional.

## 5. Important Implementation Notes

- For stencil-based operators with k=4, test dimensions must satisfy size constraints in active axes. Avoid undersized dimensions that trigger unrelated assertions (example encountered: 3D depth o too small).
- Boundary coefficient vectors dc and nc are per-face metadata; boundary values v contain per-face sampled values and have periodicity-dependent size requirements.

## 6. Proposed Upcoming Changes (Prioritized)

### Priority 1: Decide Legacy Signature Policy
- Current state keeps legacy order for compatibility.
- Decide whether to:
  - keep legacy order long-term, or
  - remove legacy order in a controlled breaking-change release.

If removal is chosen:
- Remove legacy branch in addScalarBC1D.m, addScalarBC2D.m, addScalarBC3D.m.
- Update compatibility tests accordingly.
- Add release note and migration note in docs.

### Priority 2: Broaden Regression Surface
- Run broader MATLAB test suites beyond the current subset.
- Add targeted tests for mixed periodic/non-periodic axis combinations and boundary-value shape edge cases.

### Priority 3: Documentation Finalization
- Add a short migration section in user-facing docs listing:
  - preferred grid-call signature order,
  - explicit error IDs for invalid signatures and boundary value size checks,
  - deprecation status of robin/mixed wrappers.

### Priority 4: Compatibility Wrapper Sunset Plan
- Keep wrappers for now but define timeline and criteria for deprecating/removing robin/mixed entry points.

## 7. Quick Resume Checklist for Next Agent

1. Confirm no non-MATLAB scope work is introduced.
2. Re-run baseline regression command:
   matlab -nojvm -batch "addpath('../../src/matlab_octave'); addpath('.'); assertSuccess(runtests({'testBCConsistency','testGridFirstV2Migration','testPoissonAccuracy'}))"
3. Choose and execute Priority 1 decision path (keep or remove legacy signature support).
4. If changing signature compatibility, extend tests first, then update wrappers, then rerun full regression.
5. Update STRUCTURE_V2.md and any user docs after code behavior is finalized.
