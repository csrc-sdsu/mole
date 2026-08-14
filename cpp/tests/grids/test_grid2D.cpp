// Regression tests for grid2D.
//
// The asymmetric-size tests (m != n) here specifically guard against
// the axis-order/transposition bug found earlier in this codebase's
// history, where Utils::mesh2Dgrid's (len(y), len(x)) convention
// didn't match grid2D's (m, n) convention -- a bug invisible under
// square (m == n) grids. Do not "simplify" these to square grids.
#include "MOLE_grids.h"
#include "mole_test.h"

TEST_CASE("grid2D uniform: valid asymmetric grid validates") {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 5;
    p.dx = 1.0; p.dy = 1.0;
    grid2D g(p);
    CHECK(g.isValidatedGrid());
}

TEST_CASE("grid2D uniform: layer shapes follow the (m,n) convention, "
          "not a transposed one (regression guard)") {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 5;   // deliberately asymmetric
    p.dx = 1.0; p.dy = 1.0;
    grid2D g(p);
    REQUIRE(g.isValidatedGrid());

    CHECK(g.grid.nodes_X.data_.n_rows == p.m + 1);
    CHECK(g.grid.nodes_X.data_.n_cols == p.n + 1);
    CHECK(g.grid.nodes_Y.data_.n_rows == p.m + 1);
    CHECK(g.grid.nodes_Y.data_.n_cols == p.n + 1);

    CHECK(g.grid.centers_X.data_.n_rows == p.m + 2);
    CHECK(g.grid.centers_X.data_.n_cols == p.n + 2);

    CHECK(g.grid.faces_u_X.data_.n_rows == p.m + 1);
    CHECK(g.grid.faces_u_X.data_.n_cols == p.n);

    CHECK(g.grid.faces_v_X.data_.n_rows == p.m);
    CHECK(g.grid.faces_v_X.data_.n_cols == p.n + 1);
}

TEST_CASE("grid2D uniform: nodal coordinate values are correct "
          "(not just shapes)") {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 4;
    p.dx = 1.5; p.dy = 0.5;
    grid2D g(p);
    REQUIRE(g.isValidatedGrid());

    for (size_t i = 0; i <= p.m; ++i) {
        for (size_t j = 0; j <= p.n; ++j) {
            CHECK(g.grid.nodes_X.data_(i, j) == static_cast<double>(i) * p.dx);
            CHECK(g.grid.nodes_Y.data_(i, j) == static_cast<double>(j) * p.dy);
        }
    }
}

TEST_CASE("grid2D uniform: user-supplied, correctly-shaped AND "
          "correctly-valued nodes round-trip successfully") {
    size_t m = 3, n = 5;
    double dx = 1.0, dy = 1.0;
    array2D nx(m + 1, n + 1, 0.0), ny(m + 1, n + 1, 0.0);
    for (size_t i = 0; i <= m; ++i)
        for (size_t j = 0; j <= n; ++j) {
            nx.data_(i, j) = i * dx;
            ny.data_(i, j) = j * dy;
        }

    gridParams2D p;
    p.topology = 'u';
    p.m = m; p.n = n; p.dx = dx; p.dy = dy;
    p.nodes_X = nx; p.nodes_Y = ny;
    grid2D g(p);
    CHECK(g.isValidatedGrid());
}

TEST_CASE("grid2D uniform: user-supplied nodes with wrong shape "
          "are rejected (not silently transposed)") {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 5;
    p.dx = 1.0; p.dy = 1.0;
    // Deliberately transposed shape: (n+1) x (m+1) instead of (m+1) x (n+1)
    p.nodes_X = array2D(p.n + 1, p.m + 1, 0.0);
    p.nodes_Y = array2D(p.n + 1, p.m + 1, 0.0);
    grid2D g(p);
    CHECK(!g.isValidatedGrid());
    CHECK(g.hasGridErrors());
}

TEST_CASE("grid2D uniform: user-supplied nodes with correct shape but "
          "wrong values are rejected") {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 5;
    p.dx = 1.0; p.dy = 1.0;
    p.nodes_X = array2D(p.m + 1, p.n + 1, 0.0); // all zeros: wrong values
    p.nodes_Y = array2D(p.m + 1, p.n + 1, 0.0);
    grid2D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid2D: invalid topology character is rejected") {
    gridParams2D p;
    p.topology = 'x';
    p.m = 3; p.n = 3;
    p.dx = 1.0; p.dy = 1.0;
    grid2D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid2D: invalid (zero) spacing is rejected") {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 3;
    p.dx = 0.0; p.dy = 1.0;
    grid2D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid2D: curvilinear without user nodes is rejected") {
    gridParams2D p;
    p.topology = 'c';
    p.m = 3; p.n = 3;
    grid2D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid2D: periodic BC flags round-trip through the grid") {
    gridParams2D p;
    p.topology = 'u';
    p.m = 3; p.n = 3;
    p.dx = 1.0; p.dy = 1.0;
    p.bc_isPeriodic[0] = true;
    p.bc_isPeriodic[1] = false;
    grid2D g(p);
    REQUIRE(g.isValidatedGrid());
    CHECK(g.grid.bc_isPeriodic[0] == true);
    CHECK(g.grid.bc_isPeriodic[1] == false);
}

MOLE_TEST_MAIN()
