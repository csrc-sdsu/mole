/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

/*
 * Regression tests for grid_builder.h / grid_builder.cpp
 *
 * runChecks is exercised directly through gridRaw so every parse-time
 * validation branch is observable. The gridBuilder macro is exercised
 * for dimension dispatch through the real makeGrid.
 */
#include "mini_test.h"
#include "grid_builder.h"

#include <variant>

// errCount counts entries in a copy of the error stack.
static int errCount(stack<MOLE_Errors> s) {
  //  int n = 0;
  //  while (!s.empty()) { ++n; s.pop(); }
  //  return n;
  return s.size();
}

// makeRaw builds a gridRaw carrying only the counts a test sets;
// every unset field keeps its header default.
static gridRaw makeRaw(int dim, char topology, int m = -1,
                       int n = -1, int o = -1) {
    gridRaw g;
    g.dim = dim;
    g.topology = topology;
    g.m = m;
    g.n = n;
    g.o = o;
    return g;
}

// ---------------------------------------------------------------
// runChecks: dimension validity
// ---------------------------------------------------------------

TEST(runChecks_missing_dim_returns_zero) {
    stack<MOLE_Errors> errs;
    gridRaw g;                          // dim defaults to -1
    CHECK_EQ(runChecks(errs, g), 0);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_DIM));
    // A missing dim short-circuits before the cell-count checks.
    CHECK_FALSE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST(runChecks_out_of_range_dim_returns_zero) {
    for (int dim : {0, 4}) {
        stack<MOLE_Errors> errs;
        gridRaw g = makeRaw(dim, 'u', 5);
        CHECK_EQ(runChecks(errs, g), 0);
        CHECK_TRUE(
            MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_DIM));
        CHECK_FALSE(
            MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
    }
}

// ---------------------------------------------------------------
// runChecks: cell-count consistency
// ---------------------------------------------------------------

TEST(runChecks_missing_count_for_1D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'u');          // m omitted
    CHECK_EQ(runChecks(errs, g), 1);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST(runChecks_missing_count_for_2D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(2, 'u', 5);       // n omitted
    CHECK_EQ(runChecks(errs, g), 2);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST(runChecks_missing_count_for_3D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(3, 'u', 5, 5);    // o omitted
    CHECK_EQ(runChecks(errs, g), 3);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST(runChecks_extra_count_rejected_for_1D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'u', 5, 3);    // n set on a 1D grid
    CHECK_EQ(runChecks(errs, g), 1);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST(runChecks_extra_count_rejected_for_2D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(2, 'u', 5, 5, 3); // o set on a 2D grid
    CHECK_EQ(runChecks(errs, g), 2);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

// ---------------------------------------------------------------
// runChecks: topology
// ---------------------------------------------------------------

TEST(runChecks_missing_topology) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, '\0', 5);
    runChecks(errs, g);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY));
}

TEST(runChecks_unknown_topology) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'x', 5);
    runChecks(errs, g);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY));
}

// ---------------------------------------------------------------
// runChecks: valid grids clear every check (also covers the three
// valid topology chars 'u', 'c', 'n')
// ---------------------------------------------------------------

TEST(runChecks_valid_uniform_1D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'u', 5);
    CHECK_EQ(runChecks(errs, g), 1);
    CHECK_FALSE(MOLEerr_haserrors(errs));
}

TEST(runChecks_valid_curvilinear_2D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(2, 'c', 5, 5);
    CHECK_EQ(runChecks(errs, g), 2);
    CHECK_FALSE(MOLEerr_haserrors(errs));
}

TEST(runChecks_valid_nonuniform_3D) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(3, 'n', 5, 5, 5);
    CHECK_EQ(runChecks(errs, g), 3);
    CHECK_FALSE(MOLEerr_haserrors(errs));
}

// ---------------------------------------------------------------
// runChecks: errors accumulate without short-circuit
// ---------------------------------------------------------------

TEST(runChecks_accumulates_multiple_errors) {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(3, 'z');   // all counts missing, bad topo
    CHECK_EQ(runChecks(errs, g), 3);
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
    CHECK_TRUE(
        MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY));
    CHECK_EQ(errs.size(), 4); // missing m,n,o (3) + bad topo (1)
}

// ---------------------------------------------------------------
// gridBuilder macro: dimension dispatch through makeGrid
// ---------------------------------------------------------------

TEST(gridBuilder_dispatches_1D) {
    gridVar g = gridBuilder("dim", 1, "m", 5, "dx", 0.2,
                            "topology", 'u');
    CHECK_TRUE(std::holds_alternative<grid1D>(g));
}

TEST(gridBuilder_dispatches_2D) {
    gridVar g = gridBuilder("dim", 2, "m", 5, "n", 5, "dx", 0.2,
                            "dy", 0.2, "topology", 'u');
    CHECK_TRUE(std::holds_alternative<grid2D>(g));
}

TEST(gridBuilder_dispatches_3D) {
    gridVar g = gridBuilder("dim", 3, "m", 5, "n", 5, "o", 5,
                            "dx", 0.2, "dy", 0.2, "dz", 0.2,
                            "topology", 'u');
    CHECK_TRUE(std::holds_alternative<grid3D>(g));
}

// ---------------------------------------------------------------
// gridBuilder macro: failure paths return gridNull
// ---------------------------------------------------------------

TEST(gridBuilder_unknown_attribute_returns_gridNull) {
    gridVar g = gridBuilder("dim", 1, "m", 5, "dx", 0.2,
                            "topology", 'u', "bogus", 7);
    CHECK_TRUE(std::holds_alternative<gridNull>(g));
}

TEST(gridBuilder_missing_dim_returns_gridNull) {
    gridVar g = gridBuilder("m", 5, "dx", 0.2, "topology", 'u');
    CHECK_TRUE(std::holds_alternative<gridNull>(g));
}
