/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2008-2024 San Diego State University Research Foundation
 * (SDSURF).
 * See LICENSE file or https://www.gnu.org/licenses/gpl-3.0.html for details.
 */

// Regression tests for the MOLE debug modes.
//
// The modes are declared in MOLE_errors.h and applied by
// gridBase::applyDebugMode, which the grid constructors and
// gridBuilder call. Two properties are under test:
//
//   1. a mode changes only what is written to standard output; the
//      grid's error log is identical afterwards in every mode
//   2. a grid that passed validation ignores the mode entirely,
//      even when it carries errors merged from upstream
//
// DEBUG_AND_ABORT_MD is only exercised on grids that validated,
// since a real abort would end the test binary. If property 2
// regresses, these cases abort and ctest reports the failure.
#include "MOLE_grids.h"
#include "grid_builder.h"
#include "mole_test.h"

#include <iostream>
#include <sstream>
#include <string>
#include <variant>

// capture redirects standard output for the duration of fn and
// returns whatever was written. The grid error reporting goes to
// cout; mole_test.h writes failures to cerr, so assertion output is
// not swallowed.
template <typename F>
static std::string capture(F fn) {
    std::ostringstream buf;
    std::streambuf* old = std::cout.rdbuf(buf.rdbuf());
    fn();
    std::cout.rdbuf(old);
    return buf.str();
}

// badParams1D returns a gridParams1D that cannot validate: 'z' is
// not a MOLE topology.
static gridParams1D badParams1D() {
    gridParams1D p;
    p.topology = 'z';
    p.m = 5;
    p.dx = 1.0;
    return p;
}

// goodParams1D returns a gridParams1D that validates.
static gridParams1D goodParams1D() {
    gridParams1D p;
    p.topology = 'u';
    p.m = 5;
    p.dx = 0.5;
    return p;
}

// ---------------------------------------------------------------
// What each mode writes
// ---------------------------------------------------------------

TEST_CASE("DEBUG_DEFAULT_MD writes nothing for an invalid grid") {
    std::string out = capture([]{
        grid1D g(badParams1D(), DEBUG_DEFAULT_MD);
        CHECK(!g.isValidatedGrid());
    });
    CHECK_MSG(out.empty(),
        "expected no output in the default mode, got: " << out);
}

TEST_CASE("DEBUG_REPORTS_STDOUT_MD writes the log for an invalid "
          "grid and returns control") {
    bool reached_next_line = false;
    std::string out = capture([&]{
        grid1D g(badParams1D(), DEBUG_REPORTS_STDOUT_MD);
        reached_next_line = true;
        CHECK(!g.isValidatedGrid());
    });
    CHECK(reached_next_line);
    CHECK(out.find("MOLE Error code") != std::string::npos);
}

TEST_CASE("an unrecognized debug mode falls back to reporting") {
    std::string out = capture([]{
        grid1D g(badParams1D(), 99);
        CHECK(!g.isValidatedGrid());
    });
    CHECK(out.find("Unrecognized MOLE debug mode")
          != std::string::npos);
    CHECK(out.find("MOLE Error code") != std::string::npos);
}

// ---------------------------------------------------------------
// A mode must not consume the error log
//
// Reporting has to be non-destructive. The validation flag lives in
// the same stack as the errors (MOLE_ERR_GRID_UNCHECKED), so a mode
// that drained the stack would leave an invalid grid claiming to be
// validated. It would also break the promise that a user can still
// print or write the log after the library has reported it.
// ---------------------------------------------------------------

TEST_CASE("reporting leaves the same error log behind as the "
          "default mode") {
    grid1D quiet(badParams1D(), DEBUG_DEFAULT_MD);

    std::string reported = capture([]{
        grid1D loud(badParams1D(), DEBUG_REPORTS_STDOUT_MD);
        (void)loud;
    });

    grid1D loud(badParams1D(), DEBUG_DEFAULT_MD);

    std::string quiet_log = capture([&]{ quiet.print_ErrorLog(); });
    std::string loud_log  = capture([&]{ loud.print_ErrorLog(); });

    CHECK_MSG(quiet_log == loud_log,
        "the two modes produced different error logs");
    CHECK_MSG(reported == loud_log,
        "what the mode reported differs from what the grid kept");
}

TEST_CASE("a grid can still be asked for its log after the mode "
          "already reported it") {
    std::string first;
    grid1D g(badParams1D(), DEBUG_DEFAULT_MD);
    first = capture([&]{ g.print_ErrorLog(); });
    std::string second = capture([&]{ g.print_ErrorLog(); });
    CHECK(!first.empty());
    CHECK_MSG(first == second,
        "print_ErrorLog is not repeatable");
    CHECK(!g.isValidatedGrid());
}

// ---------------------------------------------------------------
// A validated grid ignores the mode
//
// These are the regression tests for using isValidatedGrid() rather
// than hasGridErrors() as the trigger. A freshly built grid always
// has MOLE_ERR_GRID_UNCHECKED on its stack until validation clears
// it, and mergeErrors folds upstream errors into the same stack, so
// hasGridErrors() is true for grids that are perfectly usable.
// Under DEBUG_AND_ABORT_MD the wrong trigger ends the process.
// ---------------------------------------------------------------

TEST_CASE("a valid grid ignores DEBUG_AND_ABORT_MD") {
    std::string out = capture([]{
        grid1D g(goodParams1D(), DEBUG_AND_ABORT_MD);
        CHECK(g.isValidatedGrid());
    });
    CHECK_MSG(out.empty(),
        "a validated grid should produce no output, got: " << out);
}

TEST_CASE("a valid grid carrying upstream errors is reported, "
          "because the trigger is hasGridErrors()") {
    // mergeErrors folds an incoming stack into the grid's own, so a
    // grid that passed its own validation can still hold errors it
    // did not cause. hasGridErrors() counts those, so this grid is
    // reported. DEBUG_AND_ABORT_MD would abort it. Not reachable
    // through gridBuilder, which routes a non-empty stack to
    // gridNull before any grid is built.
    std::stack<MOLE_Errors> inerrs;
    MOLEerr_init(inerrs);
    MOLEerr_log(inerrs, MOLE_ERR_INVALID_INPUT_TYPE, "upstream", "");

    std::string out = capture([&]{
        grid1D g(goodParams1D(), inerrs, DEBUG_REPORTS_STDOUT_MD);
        CHECK(g.isValidatedGrid());
        CHECK(g.hasGridErrors());
    });
    CHECK(out.find("upstream") != std::string::npos);
}

TEST_CASE("the inerrs constructor applies the mode to an invalid "
          "grid") {
    std::stack<MOLE_Errors> inerrs;
    MOLEerr_init(inerrs);
    MOLEerr_log(inerrs, MOLE_ERR_INVALID_INPUT_TYPE, "upstream", "");

    std::string out = capture([&]{
        grid1D g(badParams1D(), inerrs, DEBUG_REPORTS_STDOUT_MD);
        CHECK(!g.isValidatedGrid());
    });
    CHECK(out.find("MOLE Error code") != std::string::npos);
    // the upstream error travelled into the report
    CHECK(out.find("upstream") != std::string::npos);
}

// ---------------------------------------------------------------
// 2D and 3D take the same path
// ---------------------------------------------------------------

TEST_CASE("grid2D honours the debug modes") {
    gridParams2D bad;
    bad.topology = 'z';
    bad.m = 3; bad.n = 3; bad.dx = 1.0; bad.dy = 1.0;

    CHECK(capture([&]{ grid2D g(bad, DEBUG_DEFAULT_MD); }).empty());
    CHECK(!capture([&]{
        grid2D g(bad, DEBUG_REPORTS_STDOUT_MD);
    }).empty());

    gridParams2D good;
    good.topology = 'u';
    good.m = 3; good.n = 3; good.dx = 1.0; good.dy = 1.0;
    CHECK(capture([&]{
        grid2D g(good, DEBUG_AND_ABORT_MD);
        CHECK(g.isValidatedGrid());
    }).empty());
}

TEST_CASE("grid3D honours the debug modes") {
    gridParams3D bad;
    bad.topology = 'z';
    bad.m = 2; bad.n = 3; bad.o = 2;
    bad.dx = 1.0; bad.dy = 1.0; bad.dz = 1.0;

    CHECK(capture([&]{ grid3D g(bad, DEBUG_DEFAULT_MD); }).empty());
    CHECK(!capture([&]{
        grid3D g(bad, DEBUG_REPORTS_STDOUT_MD);
    }).empty());

    gridParams3D good;
    good.topology = 'u';
    good.m = 2; good.n = 3; good.o = 2;
    good.dx = 1.0; good.dy = 1.0; good.dz = 1.0;
    CHECK(capture([&]{
        grid3D g(good, DEBUG_AND_ABORT_MD);
        CHECK(g.isValidatedGrid());
    }).empty());
}

// ---------------------------------------------------------------
// The gridBuilder debug attribute
// ---------------------------------------------------------------

TEST_CASE("gridBuilder without a debug attribute stays quiet on a "
          "failed build") {
    std::string out = capture([]{
        gridVar g = gridBuilder("dim", 1, "m", 5, "dx", 0.2,
                                "topology", 'z');
        CHECK(std::holds_alternative<gridNull>(g));
    });
    CHECK(out.empty());
}

TEST_CASE("gridBuilder reports a failed build when debug is "
          "DEBUG_REPORTS_STDOUT_MD") {
    std::string out = capture([]{
        gridVar g = gridBuilder("debug", DEBUG_REPORTS_STDOUT_MD,
                                "dim", 1, "m", 5, "dx", 0.2,
                                "topology", 'z');
        CHECK(std::holds_alternative<gridNull>(g));
    });
    CHECK(out.find("MOLE Error code") != std::string::npos);
}

TEST_CASE("gridBuilder stays quiet when the grid builds, whatever "
          "the debug mode") {
    std::string out = capture([]{
        gridVar g = gridBuilder("debug", DEBUG_AND_ABORT_MD,
                                "dim", 1, "m", 5, "dx", 0.2,
                                "topology", 'u');
        REQUIRE(std::holds_alternative<grid1D>(g));
        CHECK(std::get<grid1D>(g).isValidatedGrid());
    });
    CHECK_MSG(out.empty(),
        "a grid that built should produce no output, got: " << out);
}

TEST_CASE("gridBuilder keeps the full log in every mode") {
    gridVar quiet = gridBuilder("dim", 1, "m", 5, "dx", 0.2,
                                "topology", 'z');

    std::string reported = capture([]{
        gridVar loud = gridBuilder("debug", DEBUG_REPORTS_STDOUT_MD,
                                   "dim", 1, "m", 5, "dx", 0.2,
                                   "topology", 'z');
        (void)loud;
    });

    std::string quiet_log = capture([&]{
        std::visit([](auto&& g){ g.print_ErrorLog(); }, quiet);
    });

    CHECK(!quiet_log.empty());
    CHECK_MSG(reported == quiet_log,
        "gridBuilder reported something other than the log it "
        "handed back");
}

TEST_CASE("NOTE: a debug pair placed after an unknown attribute is "
          "never read") {
    // Parsing stops at the first name that is not a grid attribute,
    // because the type of the value following it is unknown. The
    // debug pair below is never reached, so the build falls back to
    // DEBUG_DEFAULT_MD and reports nothing. This is the reason the
    // debug pair has to come first.
    std::string out = capture([]{
        gridVar g = gridBuilder("dim", 1, "m", 5, "spacing", 0.2,
                                "debug", DEBUG_REPORTS_STDOUT_MD,
                                "topology", 'u');
        CHECK(std::holds_alternative<gridNull>(g));
    });
    CHECK_MSG(out.empty(),
        "a trailing debug pair was read; the parser changed");
}

TEST_CASE("the debug constructor keeps the user's parameters") {
    gridParams1D p = goodParams1D();
    grid1D g(p, DEBUG_DEFAULT_MD);

    CHECK(g.grid.m == 5);
    CHECK(g.grid.topology == 'u');
    CHECK(g.grid.dx == 0.5);
    // validGrid() generates these; empty means it never ran
    CHECK(g.grid.nodes_X.data_.n_elem == 6);
    CHECK(g.grid.centers_X.data_.n_elem == 7);
    CHECK(g.isValidatedGrid());
}

TEST_CASE("the debug constructor keeps the incoming error stack") {
    std::stack<MOLE_Errors> inerrs;
    MOLEerr_init(inerrs);
    MOLEerr_log(inerrs, MOLE_ERR_INVALID_INPUT_TYPE, "upstream", "");

    gridParams1D p = goodParams1D();

    grid1D plain(p, inerrs);
    grid1D dbg(p, inerrs, DEBUG_DEFAULT_MD);

    CHECK(dbg.grid.m == 5);
    CHECK(dbg.grid.nodes_X.data_.n_elem == 6);
    CHECK(dbg.hasGridErrors());

    std::string a = capture([&]{ plain.print_ErrorLog(); });
    std::string b = capture([&]{ dbg.print_ErrorLog(); });
    CHECK_MSG(a == b,
        "the debug constructor produced a different object than "
        "the constructor it delegates to");
}

MOLE_TEST_MAIN()
