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

TEST_CASE("NOTE: isValidGrid re-runs validGrid() on an already-"
          "constructed grid, which re-appends to its error log") {
    // makeGrid() already calls validGrid() once inside the grid's
    // constructor. Calling isValidGrid() on the result runs
    // validGrid() a SECOND time. For a grid that fails validation,
    // this means its error stack accumulates two copies of every
    // validation error rather than one. This test documents that
    // behavior explicitly, using captured print_ErrorLog() output as
    // an observable proxy for "how many times was this error logged"
    // (the error stack itself is protected and has no public size
    // query). If this is ever changed to be idempotent, this test
    // should start failing loudly rather than silently.
    gridParams2D p;
    p.topology = 'q'; // invalid topology -> validGrid() will fail
    p.m = 3; p.n = 3; p.dx = 1.0; p.dy = 1.0;
    std::stack<MOLE_Errors> errs;
    gridVar g = makeGrid(p, errs); // 1st validGrid() call, inside ctor

    CHECK(!isValidGrid(g));         // 2nd validGrid() call; still invalid

    std::ostringstream captured;
    std::streambuf* old_cout = std::cout.rdbuf(captured.rdbuf());
    std::visit([](auto&& gridObj) { gridObj.print_ErrorLog(); }, g);
    std::cout.rdbuf(old_cout);

    const std::string out = captured.str();
    size_t count = 0, pos = 0;
    const std::string needle = "grid2D[construct]";
    while ((pos = out.find(needle, pos)) != std::string::npos) {
        ++count;
        pos += needle.size();
    }
    CHECK_MSG(count == 2,
        "expected the invalid-topology error to appear twice after "
        "two validGrid() calls (once from the constructor, once from "
        "isValidGrid()), got " << count << ". If this is now 1, "
        "validGrid() has been made idempotent -- update this test "
        "to CHECK(count == 1) and remove this NOTE.");
}

MOLE_TEST_MAIN()
