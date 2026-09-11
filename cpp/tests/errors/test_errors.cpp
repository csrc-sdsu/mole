// Regression tests for MOLE_Errors.cpp (the free-function error
// stack API used by every MOLE class).
#include "MOLE_errors.h"
#include "mole_test.h"
#include <sstream>

TEST_CASE("MOLEerr_log pushes an entry, MOLEerr_haserrors sees it") {
    std::stack<MOLE_Errors> errs;
    CHECK(!MOLEerr_haserrors(errs));
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "test", "dx=-1");
    CHECK(MOLEerr_haserrors(errs));
    REQUIRE(!errs.empty());
    CHECK(errs.top().errCode == MOLE_ERR_INVALID_GRID_SPACING);
    CHECK(errs.top().errLocation == "test");
}

TEST_CASE("MOLEerr_contains finds a logged code and ignores others") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "a", "");
    MOLEerr_log(errs, MOLE_ERR_GRID_NODAL_SZ_MISMATCH, "b", "");
    CHECK(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_SPACING));
    CHECK(MOLEerr_contains(errs, MOLE_ERR_GRID_NODAL_SZ_MISMATCH));
    CHECK(!MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY));
}

TEST_CASE("MOLEerr_contains on an empty stack returns false") {
    std::stack<MOLE_Errors> errs;
    CHECK(!MOLEerr_contains(errs, MOLE_ERR_GRID_UNCHECKED));
}

TEST_CASE("MOLEerr_remove removes only the targeted code") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "a", "");
    MOLEerr_log(errs, MOLE_ERR_GRID_NODAL_SZ_MISMATCH, "b", "");
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "c", "");

    MOLEerr_remove(errs, MOLE_ERR_INVALID_GRID_SPACING);

    CHECK(!MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_SPACING));
    CHECK(MOLEerr_contains(errs, MOLE_ERR_GRID_NODAL_SZ_MISMATCH));
}

TEST_CASE("MOLEerr_print reports an unrecognized code exactly once") {
    std::stack<MOLE_Errors> errs;
    // 99999 is not a key in MOLE_errors_messages.
    MOLEerr_log(errs, 99999, "bogus_location", "param");

    std::ostringstream captured;
    std::streambuf* old_cout = std::cout.rdbuf(captured.rdbuf());
    MOLEerr_print(errs);
    std::cout.rdbuf(old_cout);

    const std::string out = captured.str();
    size_t count = 0, pos = 0;
    while ((pos = out.find("bogus_location", pos)) != std::string::npos) {
        ++count;
        pos += 1;
    }
    CHECK_MSG(count == 1,
        "expected 'bogus_location' to appear exactly once in "
        "MOLEerr_print output, got " << count
        << ". Full output:\n" << out);
}

TEST_CASE("MOLEerr_print reports a recognized code with its message") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "test_loc", "dx=0");

    std::ostringstream captured;
    std::streambuf* old_cout = std::cout.rdbuf(captured.rdbuf());
    MOLEerr_print(errs);
    std::cout.rdbuf(old_cout);

    const std::string out = captured.str();
    CHECK(out.find("test_loc") != std::string::npos);
    CHECK(out.find(
        MOLE_errors_messages[MOLE_ERR_INVALID_GRID_SPACING])
        != std::string::npos);
}

TEST_CASE("MOLEerr_init clears any existing entries") {
    std::stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "a", "");
    MOLEerr_log(errs, MOLE_ERR_GRID_NODAL_SZ_MISMATCH, "b", "");
    REQUIRE(MOLEerr_haserrors(errs));
    MOLEerr_init(errs);
    CHECK(!MOLEerr_haserrors(errs));
}

MOLE_TEST_MAIN()
