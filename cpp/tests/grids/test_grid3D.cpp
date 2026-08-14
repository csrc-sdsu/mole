// Regression tests for grid3D.
//
// As with grid2D, sizes here are deliberately distinct (m != n != o)
// to catch axis-order regressions that a symmetric grid would hide.
#include "MOLE_grids.h"
#include "mole_test.h"

TEST_CASE("grid3D uniform: valid asymmetric grid validates") {
    gridParams3D p;
    p.topology = 'u';
    p.m = 3; p.n = 4; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    grid3D g(p);
    CHECK(g.isValidatedGrid());
}

TEST_CASE("grid3D uniform: layer shapes follow the (m,n,o) convention") {
    gridParams3D p;
    p.topology = 'u';
    p.m = 3; p.n = 4; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    grid3D g(p);
    REQUIRE(g.isValidatedGrid());

    CHECK(g.grid.nodes_X.data_.n_rows == p.m + 1);
    CHECK(g.grid.nodes_X.data_.n_cols == p.n + 1);
    CHECK(g.grid.nodes_X.data_.n_slices == p.o + 1);

    CHECK(g.grid.centers_X.data_.n_rows == p.m + 2);
    CHECK(g.grid.centers_X.data_.n_cols == p.n + 2);
    CHECK(g.grid.centers_X.data_.n_slices == p.o + 2);

    CHECK(g.grid.faces_u_X.data_.n_rows == p.m + 1);
    CHECK(g.grid.faces_u_X.data_.n_cols == p.n);
    CHECK(g.grid.faces_u_X.data_.n_slices == p.o);

    CHECK(g.grid.faces_v_X.data_.n_rows == p.m);
    CHECK(g.grid.faces_v_X.data_.n_cols == p.n + 1);
    CHECK(g.grid.faces_v_X.data_.n_slices == p.o);

    CHECK(g.grid.faces_w_X.data_.n_rows == p.m);
    CHECK(g.grid.faces_w_X.data_.n_cols == p.n);
    CHECK(g.grid.faces_w_X.data_.n_slices == p.o + 1);
}

TEST_CASE("grid3D uniform: user-supplied, correctly-valued nodes "
          "round-trip successfully") {
    size_t m = 3, n = 4, o = 2;
    double dx = 1.0, dy = 2.0, dz = 0.5;
    array3D nx(m + 1, n + 1, o + 1, 0.0);
    array3D ny(m + 1, n + 1, o + 1, 0.0);
    array3D nz(m + 1, n + 1, o + 1, 0.0);
    for (size_t i = 0; i <= m; ++i)
        for (size_t j = 0; j <= n; ++j)
            for (size_t k = 0; k <= o; ++k) {
                nx.data_(i, j, k) = i * dx;
                ny.data_(i, j, k) = j * dy;
                nz.data_(i, j, k) = k * dz;
            }

    gridParams3D p;
    p.topology = 'u';
    p.m = m; p.n = n; p.o = o;
    p.dx = dx; p.dy = dy; p.dz = dz;
    p.nodes_X = nx; p.nodes_Y = ny; p.nodes_Z = nz;
    grid3D g(p);
    CHECK(g.isValidatedGrid());
}

TEST_CASE("grid3D uniform: user-supplied nodes with wrong shape "
          "are rejected") {
    gridParams3D p;
    p.topology = 'u';
    p.m = 3; p.n = 4; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    p.nodes_X = array3D(p.n + 1, p.m + 1, p.o + 1, 0.0); // wrong shape
    grid3D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid3D: invalid spacing is rejected") {
    gridParams3D p;
    p.topology = 'u';
    p.m = 2; p.n = 2; p.o = 2;
    p.dx = 1.0; p.dy = -1.0; p.dz = 1.0;
    grid3D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid3D: curvilinear without user nodes is rejected") {
    gridParams3D p;
    p.topology = 'c';
    p.m = 2; p.n = 2; p.o = 2;
    grid3D g(p);
    CHECK(!g.isValidatedGrid());
}

TEST_CASE("grid3D: constructor with inbound errors merges them in") {
    std::stack<MOLE_Errors> inerrs;
    MOLEerr_log(inerrs, MOLE_ERR_INVALID_INPUT_TYPE, "caller", "note");

    gridParams3D p;
    p.topology = 'u';
    p.m = 2; p.n = 2; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    grid3D g(p, inerrs);
    CHECK(g.hasGridErrors());
}

MOLE_TEST_MAIN()
