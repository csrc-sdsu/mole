/*
 * Regression tests for MOLE_grids.h / MOLE_grids.cpp
 */
#include "mini_test.h"
#include "MOLE_grids.h"
#include <cmath>

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
