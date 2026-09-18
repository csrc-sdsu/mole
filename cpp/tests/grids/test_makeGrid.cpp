// Regression tests for makeGrid(), gridNull, and isValidGrid().
#include "MOLE_grids.h"
#include "mole_test.h"
#include <sstream>

TEST_CASE("makeGrid dispatches gridParams1D to a valid grid1D") {
    gridParams1D p;
    p.topology = 'u'; p.m = 4; p.dx = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    REQUIRE(std::holds_alternative<grid1D>(g));
    CHECK(std::get<grid1D>(g).isValidatedGrid());
}

TEST_CASE("makeGrid dispatches gridParams2D to a valid grid2D") {
    gridParams2D p;
    p.topology = 'u'; p.m = 3; p.n = 4; p.dx = 1.0; p.dy = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    REQUIRE(std::holds_alternative<grid2D>(g));
    CHECK(std::get<grid2D>(g).isValidatedGrid());
}

TEST_CASE("makeGrid dispatches gridParams3D to a valid grid3D") {
    gridParams3D p;
    p.topology = 'u'; p.m = 2; p.n = 3; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    REQUIRE(std::holds_alternative<grid3D>(g));
    CHECK(std::get<grid3D>(g).isValidatedGrid());
}

TEST_CASE("makeGrid dispatches paramsNull to gridNull, which is "
          "always invalid") {
    paramsNull np;
    np.num_errs = 1;
    std::stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_GRID_CONSTRUCTION_FAILED, "prior", "");
    gridVar g = makeGrid(np, errs);
    REQUIRE(std::holds_alternative<gridNull>(g));
    CHECK(!std::get<gridNull>(g).validGrid());
}

TEST_CASE("makeGrid propagates a pre-existing error stack into the "
          "resulting grid") {
    gridParams1D p;
    p.topology = 'u'; p.m = 4; p.dx = 1.0;
    std::stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_INPUT_TYPE, "upstream", "");
    gridVar g = makeGrid(p, errs);
    REQUIRE(std::holds_alternative<grid1D>(g));
    CHECK(std::get<grid1D>(g).hasGridErrors());
}

TEST_CASE("isValidGrid dispatches to the underlying grid's validGrid()") {
    gridParams2D p;
    p.topology = 'u'; p.m = 3; p.n = 3; p.dx = 1.0; p.dy = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    CHECK(isValidGrid(g));
}

TEST_CASE("isValidGrid on an invalid gridVar (invalid topology) "
          "returns false") {
    gridParams2D p;
    p.topology = 'q'; p.m = 3; p.n = 3; p.dx = 1.0; p.dy = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    CHECK(!isValidGrid(g));
}

MOLE_TEST_MAIN()
