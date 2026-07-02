## Plan: MATLAB v2.0 Source Restructure

Restructure `src/matlab_octave` into cohesive packages organized by responsibility rather than by historical file growth. The recommended approach is a staged migration: first define stable public API layers, then move implementation variants behind those APIs, and finally update path handling and examples. This keeps MATLAB users on familiar entry points while making the internal layout much easier to maintain.

**Steps**
1. Define the v2.0 package boundaries around responsibilities, not dimensions. The top-level groups should be: operators, interpolation, boundaries, geometry, weights, and utilities. This is the main architectural decision that every subsequent move depends on.
2. Establish a public API layer for the current user-facing entry points such as `grad`, `grad2D`, `div`, `lap`, `interpol*`, `gridGen`, and BC helpers. These wrappers should remain shallow and delegate into the new internal structure so user code and examples do not need an immediate rewrite. This step blocks all large moves because it preserves compatibility.
3. Move differential operator code into an operators subtree split by operator family first, then implementation variant second. Recommended shape:
   `operators/gradient`, `operators/divergence`, `operators/laplacian`, `operators/curl`, `operators/nodal`.
   Inside each family, separate `uniform`, `periodic`, `nonperiodic`, `nonuniform`, and `curvilinear` implementations. This consolidates files like `grad.m`, `gradNonPeriodic.m`, `gradPeriodic.m`, `grad2DNonUniform.m`, and `grad2DCurv.m` under one owning area.
4. Consolidate interpolation into a dedicated interpolation subtree. Group by data transfer direction rather than by filename suffix explosion. Recommended public groupings are: `centers_to_faces`, `faces_to_centers`, `centers_to_nodes`, `nodes_to_centers`, and `basic_interpolants`. Dimension-specific and periodic variants should become internal helpers under those groups rather than separate top-level files. This step can run in parallel with step 3 once the public API layer exists.
5. Consolidate boundary-condition code into a boundaries subtree with one owner per BC family: scalar Dirichlet insertion, Robin, mixed, and curvilinear Neumann. Fold split helper files like `addScalarBC1Dlhs` and `addScalarBC1Drhs` under the corresponding BC family so that each feature has one obvious home. This can run in parallel with step 4.
6. Split geometry concerns from operators. Create a geometry subtree for grid generation, metric/Jacobian evaluation, and template grids. Recommended structure:
   `geometry/grid_generation`, `geometry/metrics`, `geometry/templates`.
   Keep `gridGen`, `tfi`, and `ttm` together as one subsystem. Keep `jacobian2D` and `jacobian3D` under metrics. Move the current `grids/` directory under templates or data and stop relying on working-directory-relative `addpath`.
7. Replace implicit path-sensitive template loading with path-safe lookup based on the current file location. This is a key MATLAB-specific cleanup because `tfi` and `ttm` currently depend on `addpath(['grids/' grid_name])`, which is fragile after any move. This step depends on step 6.
8. Create an internal helpers area for small reusable building blocks that are currently duplicated across files: interior identity/selector construction, periodic-axis detection, dimension validation, BC validation, and index builders like `GI1`, `GI2`, `GI13`, `DI2`, `DI3`. Rename opaque helper files to descriptive names and document their purpose. This can run incrementally alongside steps 3 to 6.
9. Standardize naming conventions for v2.0. Pick one dimension style and one variant style and apply them consistently. Recommended rule: family first, dimension second, variant last. Example target style: `grad_1d_uniform`, `grad_2d_curvilinear`, `interpol_centers_to_faces_3d_periodic`. Public wrappers may keep legacy names, but internal names should follow one convention.
10. Update examples, tests, and documentation only after the wrapper layer and path-safe loading are in place. This is the final migration phase and should verify that v1-style calls still work while new internal structure is in effect.

**Relevant files**
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/grad.m` — current 1-D public gradient entry point and a model for wrapper-based API preservation.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/grad2D.m` — shows current dimension-specific dispatch pattern and BC-aware interface.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/div.m` — parallel public operator API that should mirror gradient packaging decisions.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/lap.m` — illustrates composition-based operators that should depend on reorganized grad/div layers rather than live independently.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/interpolCentersToFacesD2D.m` — representative of the interpolation naming explosion and duplicated periodic/nonperiodic branching.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/interpolFacesToCentersG3D.m` — representative of high-dimensional transfer operators that should move under one interpolation family.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/addScalarBC1D.m` — anchor for BC-family consolidation.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/gridGen.m` — current grid-generation dispatcher that should become the stable public entry point for geometry generation.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/tfi.m` — contains path-sensitive grid template loading that must be redesigned.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/ttm.m` — shares the same template-loading risk and belongs in the same geometry subsystem.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/jacobian2D.m` — anchor for the geometry metrics layer used by curvilinear operators.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/jacobian3D.m` — 3-D counterpart for the same metrics layer.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/GI1.m` — representative of opaque internal helpers that need descriptive renaming and clearer ownership.
- `/home/jbrzensk/github/MOLE/mole/src/matlab_octave/DI2.m` — representative of undocumented index-generation helpers that should move into an internal helper namespace.

**Verification**
1. Inventory every current public MATLAB entry point and confirm each one has exactly one new owner package and, if needed, one compatibility wrapper.
2. Validate that grid template lookup no longer depends on the current working directory by running representative grid-generation examples from outside `src/matlab_octave`.
3. Run representative operator construction checks across each major family: uniform, periodic, nonperiodic, nonuniform, and curvilinear in 1-D, 2-D, and 3-D where supported.
4. Run example scripts that exercise each major subsystem: at least one operator example, one BC example, and one curvilinear grid example.
5. Add a structure-level document under the MATLAB source tree describing the new package map, naming rules, and where new files belong.

**Decisions**
- Included scope: source-tree organization, public-vs-internal API boundaries, naming conventions, helper ownership, and MATLAB path strategy.
- Included scope: preserving legacy entry points via wrappers during the v2.0 transition.
- Excluded scope: rewriting numerical methods, changing operator formulas, or redesigning the C++ layout in the same pass.
- Excluded scope: forcing users onto package-qualified names immediately; that can be deferred until after compatibility wrappers are stable.
- Recommended migration strategy: staged refactor with wrappers first, then file moves, then caller updates.

**Further Considerations**
1. MATLAB package namespaces using `+folder` are technically attractive, but they impose call-site churn. Recommendation: use package-like internal subtrees first, then decide whether to expose real `+package` namespaces after wrappers and examples are stable.
2. The `grids/` content behaves more like data/templates than executable API. Recommendation: treat those files as geometry templates owned by the geometry subsystem rather than as peer library functions.
3. The interpolation family is the strongest candidate for early cleanup because it has the largest file-count-to-concept ratio and the clearest internal duplication.
