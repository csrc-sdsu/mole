/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

// Regression tests for grid_builder.
//
// runChecks is exercised directly through gridRaw so every parse-time
// validation branch is observable. The gridBuilder macro is exercised
// for dimension dispatch through the real makeGrid.
#include "grid_builder.h"
#include "mole_test.h"

#include <variant>
#include <vector>

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

// countErrs reports how many entries in the stack carry a given
// error symbol, so a test can assert on the errors it is about
// rather than on the total size of the stack.
static size_t countErrs(const stack<MOLE_Errors>& errs, int code) {
    stack<MOLE_Errors> tmp = errs;
    size_t n = 0;
    while (!tmp.empty()) {
        if (tmp.top().errCode == code) ++n;
        tmp.pop();
    }
    return n;
}

// ---------------------------------------------------------------
// runChecks: dimension validity
// ---------------------------------------------------------------

TEST_CASE("runChecks: a missing dim returns zero and stops early") {
    stack<MOLE_Errors> errs;
    gridRaw g;                          // dim defaults to -1
    CHECK(runChecks(errs, g) == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_DIM));
    // A missing dim short-circuits before the cell-count checks.
    CHECK(!MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST_CASE("runChecks: an out-of-range dim returns zero") {
    for (int dim : {0, 4}) {
        stack<MOLE_Errors> errs;
        gridRaw g = makeRaw(dim, 'u', 5);
        CHECK_MSG(runChecks(errs, g) == 0, "dim = " << dim);
        CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_DIM));
        CHECK(!MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
    }
}

// ---------------------------------------------------------------
// runChecks: cell-count consistency
// ---------------------------------------------------------------

TEST_CASE("runChecks: a 1D grid without m is rejected") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'u');          // m omitted
    CHECK(runChecks(errs, g) == 1);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST_CASE("runChecks: a 2D grid without n is rejected") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(2, 'u', 5);       // n omitted
    CHECK(runChecks(errs, g) == 2);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST_CASE("runChecks: a 3D grid without o is rejected") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(3, 'u', 5, 5);    // o omitted
    CHECK(runChecks(errs, g) == 3);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST_CASE("runChecks: n supplied for a 1D grid is rejected") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'u', 5, 3);
    CHECK(runChecks(errs, g) == 1);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

TEST_CASE("runChecks: o supplied for a 2D grid is rejected") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(2, 'u', 5, 5, 3);
    CHECK(runChecks(errs, g) == 2);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_CELL_COUNT));
}

// ---------------------------------------------------------------
// runChecks: topology
// ---------------------------------------------------------------

TEST_CASE("runChecks: a missing topology is rejected") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, '\0', 5);
    runChecks(errs, g);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY));
}

TEST_CASE("runChecks: an unknown topology character is rejected") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'x', 5);
    runChecks(errs, g);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY));
}

// ---------------------------------------------------------------
// runChecks: valid grids clear every check (also covers the three
// valid topology chars 'u', 'c', 'n')
// ---------------------------------------------------------------

TEST_CASE("runChecks: a valid uniform 1D grid logs nothing") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(1, 'u', 5);
    CHECK(runChecks(errs, g) == 1);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("runChecks: a valid curvilinear 2D grid logs nothing") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(2, 'c', 5, 5);
    CHECK(runChecks(errs, g) == 2);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("runChecks: a valid nonuniform 3D grid logs nothing") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(3, 'n', 5, 5, 5);
    CHECK(runChecks(errs, g) == 3);
    CHECK(!MOLEerr_haserrors(errs));
}

// ---------------------------------------------------------------
// runChecks: errors accumulate without short-circuit
// ---------------------------------------------------------------

TEST_CASE("runChecks: every problem is reported, not just the first") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(3, 'z');   // all counts missing, bad topo
    CHECK(runChecks(errs, g) == 3);
    // One cell-count error per missing count, and one for the
    // unrecognised topology character.
    CHECK_MSG(countErrs(errs, MOLE_ERR_INVALID_CELL_COUNT) == 3,
        "got " << countErrs(errs, MOLE_ERR_INVALID_CELL_COUNT)
        << " cell-count errors, expected 3");
    CHECK(countErrs(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY) == 1);
}

// ---------------------------------------------------------------
// runChecks: isPeriodic size against dimension
//
// isPeriodic arrives as a pointer to the caller's vector, so its
// size travels with it and can be compared with dim regardless of
// the order the attributes were supplied in.
// ---------------------------------------------------------------

TEST_CASE("runChecks: an omitted isPeriodic is accepted") {
    stack<MOLE_Errors> errs;
    gridRaw g = makeRaw(3, 'u', 5, 5, 5);   // isPeriodicSrc null
    CHECK(runChecks(errs, g) == 3);
    CHECK(!MOLEerr_contains(errs, MOLE_ERR_INVALID_ISPERIODIC_DIM));
}

TEST_CASE("runChecks: one isPeriodic flag suits a 1D grid") {
    stack<MOLE_Errors> errs;
    std::vector<bool> periodic = {true};
    gridRaw g = makeRaw(1, 'u', 5);
    g.isPeriodicSrc = &periodic;
    CHECK(runChecks(errs, g) == 1);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("runChecks: two isPeriodic flags suit a 2D grid") {
    stack<MOLE_Errors> errs;
    std::vector<bool> periodic = {true, false};
    gridRaw g = makeRaw(2, 'u', 5, 5);
    g.isPeriodicSrc = &periodic;
    CHECK(runChecks(errs, g) == 2);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("runChecks: three isPeriodic flags suit a 3D grid") {
    stack<MOLE_Errors> errs;
    std::vector<bool> periodic = {true, false, true};
    gridRaw g = makeRaw(3, 'u', 5, 5, 5);
    g.isPeriodicSrc = &periodic;
    CHECK(runChecks(errs, g) == 3);
    CHECK(!MOLEerr_haserrors(errs));
}

TEST_CASE("runChecks: too few isPeriodic flags are rejected") {
    stack<MOLE_Errors> errs;
    std::vector<bool> periodic = {true};    // 3D grid needs three
    gridRaw g = makeRaw(3, 'u', 5, 5, 5);
    g.isPeriodicSrc = &periodic;
    runChecks(errs, g);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_ISPERIODIC_DIM));
}

TEST_CASE("runChecks: too many isPeriodic flags are rejected") {
    stack<MOLE_Errors> errs;
    std::vector<bool> periodic = {true, false};  // 1D needs one
    gridRaw g = makeRaw(1, 'u', 5);
    g.isPeriodicSrc = &periodic;
    runChecks(errs, g);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_ISPERIODIC_DIM));
}

TEST_CASE("runChecks: an empty isPeriodic vector is rejected") {
    stack<MOLE_Errors> errs;
    std::vector<bool> periodic;
    gridRaw g = makeRaw(2, 'u', 5, 5);
    g.isPeriodicSrc = &periodic;
    runChecks(errs, g);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_ISPERIODIC_DIM));
}

// A bad dimension stops the checks before isPeriodic is reached, so
// no size error is reported against a dimension that is itself
// invalid.
TEST_CASE("runChecks: a bad dim skips the isPeriodic size check") {
    stack<MOLE_Errors> errs;
    std::vector<bool> periodic = {true, false, true};
    gridRaw g = makeRaw(7, 'u', 5);
    g.isPeriodicSrc = &periodic;
    CHECK(runChecks(errs, g) == 0);
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_DIM));
    CHECK(!MOLEerr_contains(errs, MOLE_ERR_INVALID_ISPERIODIC_DIM));
}

// ---------------------------------------------------------------
// gridBuilder macro: dimension dispatch through makeGrid
// ---------------------------------------------------------------

TEST_CASE("gridBuilder: dim 1 yields a grid1D") {
    gridVar g = gridBuilder("dim", 1, "m", 5, "dx", 0.2,
                            "topology", 'u');
    CHECK(std::holds_alternative<grid1D>(g));
}

TEST_CASE("gridBuilder: dim 2 yields a grid2D") {
    gridVar g = gridBuilder("dim", 2, "m", 5, "n", 5, "dx", 0.2,
                            "dy", 0.2, "topology", 'u');
    CHECK(std::holds_alternative<grid2D>(g));
}

TEST_CASE("gridBuilder: dim 3 yields a grid3D") {
    gridVar g = gridBuilder("dim", 3, "m", 5, "n", 5, "o", 5,
                            "dx", 0.2, "dy", 0.2, "dz", 0.2,
                            "topology", 'u');
    CHECK(std::holds_alternative<grid3D>(g));
}

// ---------------------------------------------------------------
// gridBuilder macro: failure paths return gridNull
// ---------------------------------------------------------------

TEST_CASE("gridBuilder: an unknown attribute yields a gridNull") {
    gridVar g = gridBuilder("dim", 1, "m", 5, "dx", 0.2,
                            "topology", 'u', "bogus", 7);
    CHECK(std::holds_alternative<gridNull>(g));
}

TEST_CASE("gridBuilder: a missing dim yields a gridNull") {
    gridVar g = gridBuilder("m", 5, "dx", 0.2, "topology", 'u');
    CHECK(std::holds_alternative<gridNull>(g));
}

// ---------------------------------------------------------------
// gridBuilder macro: isPeriodic through the full parse path
// ---------------------------------------------------------------

TEST_CASE("gridBuilder: a matching isPeriodic vector builds a grid") {
    std::vector<bool> periodic = {true, false};
    gridVar g = gridBuilder("dim", 2, "m", 5, "n", 5, "dx", 0.2,
                            "dy", 0.2, "topology", 'u',
                            "isPeriodic", &periodic);
    REQUIRE(std::holds_alternative<grid2D>(g));
    grid2D& g2 = std::get<grid2D>(g);
    CHECK(g2.grid.bc_isPeriodic[0] == true);
    CHECK(g2.grid.bc_isPeriodic[1] == false);
}

TEST_CASE("gridBuilder: a mismatched isPeriodic vector is rejected") {
    std::vector<bool> periodic = {true};
    gridVar g = gridBuilder("dim", 2, "m", 5, "n", 5, "dx", 0.2,
                            "dy", 0.2, "topology", 'u',
                            "isPeriodic", &periodic);
    CHECK(std::holds_alternative<gridNull>(g));
}

// The size check reads the vector rather than the argument order,
// so isPeriodic supplied before dim validates the same way.
TEST_CASE("gridBuilder: isPeriodic may precede dim") {
    std::vector<bool> periodic = {true};
    gridVar g = gridBuilder("isPeriodic", &periodic, "dim", 2,
                            "m", 5, "n", 5, "dx", 0.2, "dy", 0.2,
                            "topology", 'u');
    CHECK(std::holds_alternative<gridNull>(g));
}

MOLE_TEST_MAIN()
