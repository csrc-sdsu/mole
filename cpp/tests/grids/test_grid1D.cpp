// Regression tests for grid1D.
#include "MOLE_grids.h"
#include "mole_test.h"

TEST_CASE("grid1D uniform: valid parameters build a valid grid") {
    gridParams1D p;
    p.topology = 'u';
    p.m = 5;
    p.dx = 0.5;
    grid1D g(p);
    CHECK(g.isValidatedGrid());
    CHECK(g.grid.nodes_X.data_.n_elem == p.m + 1);
    CHECK(g.grid.centers_X.data_.n_elem == p.m + 2);
}

TEST_CASE("grid1D uniform: nodal coordinates have correct values") {
    gridParams1D p;
    p.topology = 'u';
    p.m = 4;
    p.dx = 2.0;
    grid1D g(p);
    REQUIRE(g.isValidatedGrid());
    for (size_t i = 0; i <= p.m; ++i) {
        CHECK_MSG(g.grid.nodes_X.data_(i) == static_cast<double>(i) * p.dx,
            "nodes_X(" << i << ") = " << g.grid.nodes_X.data_(i)
            << ", expected " << (i * p.dx));
    }
}

TEST_CASE("grid1D: invalid (non-positive) spacing is rejected") {
    gridParams1D p;
    p.topology = 'u';
    p.m = 5;
    p.dx = -1.0;
    grid1D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid1D: invalid topology character is rejected") {
    gridParams1D p;
    p.topology = 'z';
    p.m = 5;
    p.dx = 1.0;
    grid1D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid1D: curvilinear topology is fundamentally invalid in 1D") {
    gridParams1D p;
    p.topology = 'c';
    p.m = 5;
    grid1D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid1D: nonuniform topology without user nodes is rejected") {
    gridParams1D p;
    p.topology = 'n';
    p.m = 5;
    grid1D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid1D: Faces_X() aliases nodes_X (same object, not a copy)") {
    gridParams1D p;
    p.topology = 'u';
    p.m = 3;
    p.dx = 1.0;
    grid1D g(p);
    REQUIRE(g.isValidatedGrid());
    CHECK(&g.grid.Faces_X() == &g.grid.nodes_X);
    CHECK(g.grid.Faces_X() == g.grid.nodes_X);
}

TEST_CASE("grid1D: Faces_X() tracks nodes_X correctly across struct "
          "copies (does not stay bound to the original)") {
    gridParams1D p;
    p.topology = 'u';
    p.m = 3;
    p.dx = 1.0;
    grid1D g(p);
    REQUIRE(g.isValidatedGrid());

    gridParams1D copy = g.grid;  // struct copy
    copy.nodes_X = array1D(3, 99.0);

    // The copy's Faces_X() must reflect the COPY's own nodes_X, not
    // the original grid's. This is the exact hazard a true C++
    // reference member would introduce (see prior discussion) --
    // Faces_X() is implemented as a function precisely to avoid it.
    CHECK(copy.Faces_X().data_(0) == 99.0);
    CHECK(g.grid.nodes_X.data_(0) != 99.0);
}

TEST_CASE("grid1D: user-supplied, correctly-valued nodes_X validates") {
    size_t m = 4;
    double dx = 0.5;
    array1D nx(m + 1, 0.0);
    for (size_t i = 0; i <= m; ++i) nx.data_(i) = i * dx;

    gridParams1D p;
    p.topology = 'u';
    p.m = m;
    p.dx = dx;
    p.nodes_X = nx;
    grid1D g(p);
    CHECK(g.isValidatedGrid());
}

TEST_CASE("grid1D: user-supplied nodes_X with wrong size is rejected") {
    gridParams1D p;
    p.topology = 'u';
    p.m = 4;
    p.dx = 0.5;
    p.nodes_X = array1D(3, 0.0);  // wrong size: should be m+1 = 5
    grid1D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid1D: constructor with inbound errors merges them in") {
    std::stack<MOLE_Errors> inerrs;
    MOLEerr_log(inerrs, MOLE_ERR_INVALID_INPUT_TYPE, "caller", "note");

    gridParams1D p;
    p.topology = 'u';
    p.m = 4;
    p.dx = 1.0;
    grid1D g(p, inerrs);

    g.print_ErrorLog(); // not asserted on; just confirm it doesn't crash
    CHECK(g.hasGridErrors());
}

MOLE_TEST_MAIN()
