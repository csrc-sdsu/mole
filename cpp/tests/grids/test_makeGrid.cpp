// Regression tests for makeGrid(), and gridNull.
//
// makeGrid exists for gridBuilder. It takes a paramVars variant and
// returns the matching gridVar, which is what lets gridBuilder choose
// the grid's dimensionality at runtime from the attributes it is
// given. makeGrid is not meant to be called on its own in user code;
// these tests call it directly only to validate that it builds the
// right grid for each parameter type.
//
// The error stack is an input parameter of makeGrid, so every test
// has to pass one. It is empty in every case except the propagation
// test, which seeds it to check that incoming errors reach the grid.
#include "MOLE_grids.h"
#include "mole_test.h"
#include <sstream>

TEST_CASE("makeGrid test: Create a valid MOLE 1D grid using gridParams1D") {
    gridParams1D p;
    p.topology = 'u'; p.m = 4; p.dx = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    REQUIRE(std::holds_alternative<grid1D>(g));
    CHECK(!std::get<grid1D>(g).hasGridErrors());
}

TEST_CASE("makeGrid test: Create a valid MOLE 2D grid using gridParams2D") {
    gridParams2D p;
    p.topology = 'u'; p.m = 3; p.n = 4; p.dx = 1.0; p.dy = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    REQUIRE(std::holds_alternative<grid2D>(g));
    CHECK(!std::get<grid2D>(g).hasGridErrors());
}

TEST_CASE("makeGrid test: Create a valid MOLE 3D grid using gridParams3D") {
    gridParams3D p;
    p.topology = 'u'; p.m = 2; p.n = 3; p.o = 2;
    p.dx = 1.0; p.dy = 1.0; p.dz = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    REQUIRE(std::holds_alternative<grid3D>(g));
    CHECK(!std::get<grid3D>(g).hasGridErrors());
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

TEST_CASE("makeGrid test: using a 2D grid and passes a valid empty error stack") {
    gridParams2D p;
    p.topology = 'u'; p.m = 3; p.n = 3; p.dx = 1.0; p.dy = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    CHECK(!std::get<grid2D>(g).hasGridErrors());
}

TEST_CASE("makeGrid test: using a invalid 2D grid and passes a empty error stack") {
    gridParams2D p;
    p.topology = 'q'; p.m = 3; p.n = 3; p.dx = 1.0; p.dy = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs);
    CHECK(std::get<grid2D>(g).hasGridErrors());
}

MOLE_TEST_MAIN()
