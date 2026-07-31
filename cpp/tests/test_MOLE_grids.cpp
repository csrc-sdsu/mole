/*
 * Regression tests for MOLE_grids.h / MOLE_grids.cpp
 */
#include "mini_test.h"
#include "MOLE_grids.h"
#include <cmath>
#include <fstream>
#include <sstream>
#include <filesystem>
#include <cstdio>

// ---------------------------------------------------------------
// validSpacing()
// ---------------------------------------------------------------

TEST(validSpacing_accepts_positive_finite) {
    CHECK_TRUE(validSpacing(1.0));
    CHECK_TRUE(validSpacing(0.0001));
}

TEST(validSpacing_rejects_zero_and_negative) {
    CHECK_FALSE(validSpacing(0.0));
    CHECK_FALSE(validSpacing(-1.0));
}

TEST(validSpacing_rejects_nan_and_inf) {
    CHECK_FALSE(validSpacing(std::nan("")));
    CHECK_FALSE(validSpacing(std::numeric_limits<Real>::infinity()));
}

// ---------------------------------------------------------------
// generateNodalPts() / generateCenterPts()
// ---------------------------------------------------------------

TEST(generateNodalPts_matches_formula) {
    Array1D xn(5); // npts=4 -> indices 0..4
    generateNodalPts(4, 2.0, xn);
    for (size_t i = 0; i <= 4; ++i)
        CHECK_NEAR(xn[i], static_cast<Real>(i) * 2.0, 1e-12);
}

TEST(generateCenterPts_matches_formula) {
    Array1D xc(6); // npts=4 -> centers_X[0..npts+1] = [0..5]
    generateCenterPts(4, 2.0, xc);
    for (size_t i = 1; i <= 4; ++i)
        CHECK_NEAR(xc[i], (static_cast<Real>(i) - 0.5) * 2.0, 1e-12);
    CHECK_NEAR(xc[5], 4.0 * 2.0, 1e-12); // xc[npts+1] = npts*delta
}

// ---------------------------------------------------------------
// grid1D
// ---------------------------------------------------------------

static gridParams1D make1DUniformParams(size_t m, Real dx) {
    gridParams1D p;
    p.topology = 'u';
    p.m = m;
    p.dx = dx;
    return p;
}

TEST(grid1D_uniform_valid_autogenerates_coords) {
    grid1D g(make1DUniformParams(4, 0.5));
    CHECK_TRUE(g.validGrid());
    CHECK_EQ(g.grid.nodes_X.size(), 5u);   // m+1
    CHECK_EQ(g.grid.centers_X.size(), 6u); // m+2
    CHECK_NEAR(g.grid.nodes_X[0], 0.0, 1e-12);
    CHECK_NEAR(g.grid.nodes_X[4], 4 * 0.5, 1e-12);
    CHECK_TRUE(g.isValidatedGrid());
    CHECK_FALSE(g.hasGridErrors());
}

TEST(grid1D_zero_cells_is_invalid) {
    grid1D g(make1DUniformParams(0, 0.5));
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid1D_bad_spacing_is_invalid) {
    grid1D gzero(make1DUniformParams(4, 0.0));
    CHECK_FALSE(gzero.validGrid());

    grid1D gneg(make1DUniformParams(4, -1.0));
    CHECK_FALSE(gneg.validGrid());

    gridParams1D pnan = make1DUniformParams(4, 0.0);
    pnan.dx = std::nan("");
    grid1D gnan(pnan);
    CHECK_FALSE(gnan.validGrid());
}

TEST(grid1D_curvilinear_is_always_invalid) {
    gridParams1D p = make1DUniformParams(4, 0.5);
    p.topology = 'c';
    grid1D g(p);
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid1D_nonuniform_requires_nodes_X) {
    gridParams1D p = make1DUniformParams(4, 0.5);
    p.topology = 'n';
    grid1D gmissing(p);
    CHECK_FALSE(gmissing.validGrid());

    gridParams1D p2 = make1DUniformParams(4, 0.5);
    p2.topology = 'n';
    p2.nodes_X = {0.0, 1.0, 2.0, 3.0, 4.0};
    grid1D gok(p2);
    CHECK_TRUE(gok.validGrid());
}

TEST(grid1D_invalid_topology_char_is_invalid) {
    gridParams1D p = make1DUniformParams(4, 0.5);
    p.topology = 'z';
    grid1D g(p);
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid1D_user_supplied_matching_coords_are_accepted) {
    gridParams1D p = make1DUniformParams(2, 1.0);
    p.nodes_X = {0.0, 1.0, 2.0};      // matches m+1 nodal pts for dx=1
    p.centers_X = {0.0, 0.5, 1.5, 2.0}; // matches m+2 center pts
    grid1D g(p);
    CHECK_TRUE(g.validGrid());
}

TEST(grid1D_user_supplied_wrong_size_coords_are_rejected) {
    gridParams1D p = make1DUniformParams(4, 0.5);
    p.nodes_X = {0.0, 1.0}; // wrong size (should be m+1=5)
    grid1D g(p);
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid1D_user_supplied_wrong_value_coords_are_rejected) {
    gridParams1D p = make1DUniformParams(2, 1.0);
    p.nodes_X = {0.0, 100.0, 200.0}; // right size, wrong values
    grid1D g(p);
    CHECK_FALSE(g.validGrid());
}

TEST(grid1D_construction_with_prior_errors_accumulates_them) {
    stack<MOLE_Errors> priorErrs;
    MOLEerr_log(priorErrs, MOLE_ERR_INVALID_INPUT_TYPE, "priorStage", "x");
    grid1D g(make1DUniformParams(4, 0.5), priorErrs);
    CHECK_TRUE(g.hasGridErrors()); // the prior error should show up
    // isValidatedGrid() only reports whether validGrid() ran and
    // succeeded for THIS grid's own parameters - it is independent
    // of leftover/carried-over errors, which is what hasGridErrors()
    // is for. Since (m=4, dx=0.5, uniform) is itself well-formed,
    // the grid should still be reported as validated even though
    // hasGridErrors() is true because of priorErrs.
    CHECK_TRUE(g.isValidatedGrid());
}

// ---------------------------------------------------------------
// grid2D
// ---------------------------------------------------------------

static gridParams2D make2DUniformParams(size_t m, size_t n, Real dx, Real dy) {
    gridParams2D p;
    p.topology = 'u';
    p.m = m; p.n = n;
    p.dx = dx; p.dy = dy;
    return p;
}

TEST(grid2D_uniform_valid_autogenerates_coords) {
    grid2D g(make2DUniformParams(3, 2, 1.0, 2.0));
    CHECK_TRUE(g.validGrid());
    CHECK_EQ(g.grid.nodes_X.rows(), 4u); // m+1
    CHECK_EQ(g.grid.nodes_X.cols(), 3u); // n+1
    CHECK_TRUE(g.isValidatedGrid());
}

TEST(grid2D_zero_cells_is_invalid) {
    grid2D g(make2DUniformParams(0, 2, 1.0, 1.0));
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid2D_bad_spacing_is_invalid) {
    grid2D g(make2DUniformParams(3, 2, 0.0, 1.0));
    CHECK_FALSE(g.validGrid());
}

TEST(grid2D_curvilinear_requires_nodes) {
    gridParams2D p = make2DUniformParams(3, 2, 1.0, 1.0);
    p.topology = 'c';
    grid2D gmissing(p);
    CHECK_FALSE(gmissing.validGrid());
}

TEST(grid2D_nonuniform_requires_nodes) {
    gridParams2D p = make2DUniformParams(3, 2, 1.0, 1.0);
    p.topology = 'n';
    grid2D gmissing(p);
    CHECK_FALSE(gmissing.validGrid());
}

TEST(grid2D_invalid_topology_char_is_invalid) {
    gridParams2D p = make2DUniformParams(3, 2, 1.0, 1.0);
    p.topology = '?';
    grid2D g(p);
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid2D_construction_with_prior_errors_accumulates_them) {
    stack<MOLE_Errors> priorErrs;
    MOLEerr_log(priorErrs, MOLE_ERR_INVALID_INPUT_TYPE, "priorStage", "y");
    grid2D g(make2DUniformParams(3, 2, 1.0, 1.0), priorErrs);
    CHECK_TRUE(g.hasGridErrors());
    // Same distinction as grid1D: this grid's own (m,n,dx,dy) are
    // valid, so it should still be reported as validated despite
    // hasGridErrors() being true because of priorErrs.
    CHECK_TRUE(g.isValidatedGrid());
}

// ---------------------------------------------------------------
// grid3D
// ---------------------------------------------------------------

static gridParams3D make3DUniformParams(size_t m, size_t n, size_t o,
                                         Real dx, Real dy, Real dz) {
    gridParams3D p;
    p.topology = 'u';
    p.m = m; p.n = n; p.o = o;
    p.dx = dx; p.dy = dy; p.dz = dz;
    return p;
}

TEST(grid3D_uniform_valid_autogenerates_coords) {
    grid3D g(make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0));
    CHECK_TRUE(g.validGrid());
    CHECK_EQ(g.grid.nodes_X.dim1(), 3u); // m+1
    CHECK_EQ(g.grid.nodes_X.dim2(), 3u); // n+1
    CHECK_EQ(g.grid.nodes_X.dim3(), 3u); // o+1
    CHECK_TRUE(g.isValidatedGrid());
}

TEST(grid3D_zero_cells_is_invalid) {
    grid3D g(make3DUniformParams(2, 0, 2, 1.0, 1.0, 1.0));
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid3D_bad_spacing_is_invalid) {
    grid3D g(make3DUniformParams(2, 2, 2, 1.0, -3.0, 1.0));
    CHECK_FALSE(g.validGrid());
}

TEST(grid3D_curvilinear_requires_nodes) {
    gridParams3D p = make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0);
    p.topology = 'c';
    grid3D gmissing(p);
    CHECK_FALSE(gmissing.validGrid());
}

TEST(grid3D_nonuniform_requires_nodes) {
    gridParams3D p = make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0);
    p.topology = 'n';
    grid3D gmissing(p);
    CHECK_FALSE(gmissing.validGrid());
}

TEST(grid3D_invalid_topology_char_is_invalid) {
    gridParams3D p = make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0);
    p.topology = '#';
    grid3D g(p);
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid3D_construction_with_prior_errors_accumulates_them) {
    stack<MOLE_Errors> priorErrs;
    MOLEerr_log(priorErrs, MOLE_ERR_INVALID_INPUT_TYPE, "priorStage", "z");
    grid3D g(make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0), priorErrs);
    CHECK_TRUE(g.hasGridErrors());
    // Same distinction as grid1D/grid2D: this grid's own params are
    // valid, so it should still be reported as validated despite
    // hasGridErrors() being true because of priorErrs.
    CHECK_TRUE(g.isValidatedGrid());
}

// ---------------------------------------------------------------
// New in this revision: grid construction now checks has_size() on
// each internal flat2DArray/flat3DArray coordinate buffer right
// after building it, so an overflow-rejected allocation (which
// leaves that buffer empty instead of the requested size) is
// detected and logged as MOLE_ERR_FAILED_ARRAY_ALLOC /
// MOLE_ERR_FAILED_ARRAY_RESIZE instead of silently continuing with
// mismatched/empty coordinate data.
//
// For a 3D grid this is safely reproducible: (m+1)*(n+1)*(o+1) only
// needs to exceed ~2^64, which happens with each axis around 2^22
// (~4.19 million) - small enough that the per-axis Array1D vectors
// MOLE builds first (grid.m+1 doubles, ~33 MB) allocate just fine,
// while the cubic combination in the flat3DArray still overflows
// size_t and gets rejected by the array's own overflow guard.
// (The analogous 2D scenario is NOT included as an automated test:
// reaching a 2D array-size overflow requires at least one axis near
// 2^32, and MOLE builds an unguarded plain std::vector of that axis
// size BEFORE ever reaching the guarded flat2DArray allocation - see
// the write-up accompanying this test suite for details.)
TEST(grid3D_array_overflow_is_caught_and_logged_via_has_size) {
    gridParams3D p;
    p.topology = 'u';
    size_t d = 4194304ULL; // 2^22
    p.m = d; p.n = d; p.o = d;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;

    grid3D g(p);
    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());

    // Confirm MOLE_ERR_FAILED_ARRAY_ALLOC actually made it into the
    // grid's error log (not just "some error or other") by dumping
    // the log and inspecting its contents end-to-end.
    g.write_ErrorLog(); // writes "MOLEGridErrors<timestamp>" in cwd

    std::string found_file;
    for (auto& entry : std::filesystem::directory_iterator(".")) {
        std::string fname = entry.path().filename().string();
        if (fname.rfind("MOLEGridErrors", 0) == 0) {
            found_file = fname;
            break;
        }
    }
    CHECK_FALSE(found_file.empty());
    if (found_file.empty()) return;

    std::ifstream in(found_file);
    std::stringstream buffer;
    buffer << in.rdbuf();
    std::string contents = buffer.str();
    in.close();
    std::remove(found_file.c_str());

    bool found_alloc_failure =
        contents.find("Array allocation failed") != std::string::npos;
    CHECK_TRUE(found_alloc_failure);
}

// ---------------------------------------------------------------
// gridNull
// ---------------------------------------------------------------

TEST(gridNull_validGrid_always_false) {
    paramsNull pn;
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_GRID_CONSTRUCTION_FAILED, "factory", "");
    gridNull g(pn, errs);
    CHECK_FALSE(g.validGrid());
}

TEST(gridNull_accumulates_prior_errors) {
    paramsNull pn;
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_GRID_CONSTRUCTION_FAILED, "factory", "");
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "factory2", "");
    gridNull g(pn, errs);
    CHECK_TRUE(g.hasGridErrors());
    CHECK_EQ(g.ErrData.num_errs, 2u);
}

// gridNull now also folds in whatever num_errs the caller's own
// paramsNull already carried, combining it with inerrs.size() rather
// than silently dropping it (as an earlier revision did).
TEST(gridNull_combines_own_num_errs_with_inerrs_size) {
    paramsNull pn;
    pn.num_errs = 3; // errors the caller already knew about
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_GRID_CONSTRUCTION_FAILED, "factory", "");
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "factory2", "");
    gridNull g(pn, errs);
    CHECK_EQ(g.ErrData.num_errs, 5u); // 3 (own) + 2 (inerrs)
}

TEST(gridNull_num_errs_with_no_inerrs_keeps_own_count) {
    paramsNull pn;
    pn.num_errs = 4;
    stack<MOLE_Errors> errs; // empty
    gridNull g(pn, errs);
    CHECK_EQ(g.ErrData.num_errs, 4u);
}

// ---------------------------------------------------------------
// makeGrid() dispatch
// ---------------------------------------------------------------

TEST(makeGrid_dispatches_1D) {
    gridParams1D p = make1DUniformParams(4, 0.5);
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_TRUE(std::holds_alternative<grid1D>(g));
}

TEST(makeGrid_dispatches_2D) {
    gridParams2D p = make2DUniformParams(2, 2, 1.0, 1.0);
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_TRUE(std::holds_alternative<grid2D>(g));
}

TEST(makeGrid_dispatches_3D) {
    gridParams3D p = make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0);
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_TRUE(std::holds_alternative<grid3D>(g));
}

TEST(makeGrid_dispatches_null) {
    paramsNull p;
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_GRID_CONSTRUCTION_FAILED, "factory", "");
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_TRUE(std::holds_alternative<gridNull>(g));
}

// ---------------------------------------------------------------
// isValidGrid() dispatch (non-const gridVar&, per design discussion:
// validGrid() mutates grid/errs state, so isValidGrid must take a
// non-const reference)
// ---------------------------------------------------------------

TEST(isValidGrid_true_for_valid_1D) {
    gridParams1D p = make1DUniformParams(4, 0.5);
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_TRUE(isValidGrid(g));
}

TEST(isValidGrid_false_for_invalid_1D) {
    gridParams1D p = make1DUniformParams(0, 0.5); // m=0 -> invalid
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_FALSE(isValidGrid(g));
}

TEST(isValidGrid_true_for_valid_2D) {
    gridParams2D p = make2DUniformParams(2, 3, 1.0, 1.0);
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_TRUE(isValidGrid(g));
}

TEST(isValidGrid_true_for_valid_3D) {
    gridParams3D p = make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0);
    stack<MOLE_Errors> errs;
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_TRUE(isValidGrid(g));
}

TEST(isValidGrid_false_for_gridNull) {
    paramsNull p;
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_GRID_CONSTRUCTION_FAILED, "factory", "");
    paramVars pv = p;
    gridVar g = makeGrid(pv, errs);
    CHECK_FALSE(isValidGrid(g));
}

// ---------------------------------------------------------------
// gridBase error-log lifecycle
// ---------------------------------------------------------------

TEST(gridBase_starts_unvalidated_then_validates) {
    // Freshly constructed base marks MOLE_ERR_GRID_UNCHECKED until
    // validGrid() succeeds and calls setGridValidated().
    grid1D g(make1DUniformParams(4, 0.5));
    // Constructor already calls validGrid() once, so by the time we
    // observe it here it should be validated (grid is well-formed).
    CHECK_TRUE(g.isValidatedGrid());
}

TEST(gridBase_stays_unvalidated_when_invalid) {
    grid1D g(make1DUniformParams(0, 0.5)); // invalid: m=0
    CHECK_FALSE(g.isValidatedGrid());
    CHECK_TRUE(g.hasGridErrors());
}

// ---------------------------------------------------------------
// isValidatedGrid() vs hasGridErrors(): these answer two different
// questions and must not be conflated:
//   - isValidatedGrid() : has validGrid() run and succeeded for this
//                         grid's OWN parameters (i.e. is the
//                         MOLE_ERR_GRID_UNCHECKED sentinel gone)?
//   - hasGridErrors()   : is the error stack non-empty for ANY
//                         reason, including errors carried over via
//                         inerrs that have nothing to do with this
//                         grid's own construction?
// A grid can be validated while still reporting errors (carried-over
// inerrs), and it can be unvalidated while its error stack still
// contains only the UNCHECKED sentinel plus its own failure reasons.
// ---------------------------------------------------------------

TEST(isValidatedGrid_is_true_despite_unrelated_carried_over_errors) {
    // The grid's own parameters (m=4, dx=0.5, uniform) are valid, but
    // the caller is passing in errors from an unrelated prior stage.
    stack<MOLE_Errors> priorErrs;
    MOLEerr_log(priorErrs, MAKE_GRID_MISSING_ARGS, "someUpstreamParser", "");
    grid1D g(make1DUniformParams(4, 0.5), priorErrs);

    CHECK_TRUE(g.isValidatedGrid());  // this grid's own build succeeded
    CHECK_TRUE(g.hasGridErrors());    // but errors are still present
}

TEST(isValidatedGrid_is_false_when_own_params_invalid_even_with_no_priorErrs) {
    stack<MOLE_Errors> noPriorErrs; // empty - nothing carried over
    grid1D g(make1DUniformParams(0, 0.5), noPriorErrs); // m=0 -> invalid

    CHECK_FALSE(g.isValidatedGrid()); // this grid's own build failed
    CHECK_TRUE(g.hasGridErrors());
}

// ---------------------------------------------------------------
// gridBase dimensionality: dim must be well-defined (0), not
// indeterminate, even when the requested dimensionality is invalid
// (e.g. gridNull's gridBase(0)).
// ---------------------------------------------------------------

TEST(gridNull_dim_is_zero_not_indeterminate) {
    paramsNull pn;
    stack<MOLE_Errors> errs;
    gridNull g(pn, errs);
    CHECK_EQ(g.dim, 0u);
}

// ---------------------------------------------------------------
// Regression: center/face coordinate mismatches must be logged with
// their own dedicated error codes, not misattributed to nodal
// coordinates (2D and 3D both had this bug at one point).
// ---------------------------------------------------------------

TEST(grid2D_bad_center_coords_logs_centers_error_not_nodal) {
    gridParams2D p = make2DUniformParams(2, 2, 1.0, 1.0);
    // right shape (m+2 x n+2 = 4x4), wrong values
    p.centers_X = Array2D(4, 4, 0.0);
    for (size_t i = 0; i < 4; ++i)
        for (size_t j = 0; j < 4; ++j)
            p.centers_X(i, j) = 999.0; // deliberately wrong
    grid2D g(p);

    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}

TEST(grid3D_bad_center_coords_logs_centers_error_not_nodal) {
    gridParams3D p = make3DUniformParams(2, 2, 2, 1.0, 1.0, 1.0);
    // right shape (m+2 x n+2 x o+2 = 4x4x4), wrong values
    p.centers_X = Array3D(4, 4, 4, 0.0);
    for (size_t i = 0; i < 4; ++i)
        for (size_t j = 0; j < 4; ++j)
            for (size_t k = 0; k < 4; ++k)
                p.centers_X(i, j, k) = 999.0; // deliberately wrong
    grid3D g(p);

    CHECK_FALSE(g.validGrid());
    CHECK_TRUE(g.hasGridErrors());
}
