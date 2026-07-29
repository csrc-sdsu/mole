/*
 * Regression tests for MOLE_Errors.h / MOLE_Errors.cpp
 */
#include "mini_test.h"
#include "MOLE_Errors.h"
#include <fstream>
#include <sstream>
#include <cstdio>
#include <filesystem>

TEST(err_init_clears_stack) {
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SIZE, "loc", "p");
    CHECK_FALSE(errs.empty());
    MOLEerr_init(errs);
    CHECK_TRUE(errs.empty());
}

TEST(err_log_pushes_entry) {
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "myLoc", "myParam");
    CHECK_FALSE(errs.empty());
    CHECK_EQ(errs.top().errCode, MOLE_ERR_INVALID_GRID_DIM);
    CHECK_EQ(errs.top().errLocation, "myLoc");
    CHECK_EQ(errs.top().paramError, "myParam");
}

TEST(err_log_default_param_is_empty) {
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "myLoc");
    CHECK_EQ(errs.top().paramError, "");
}

TEST(err_contains_true_and_false) {
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SIZE, "loc1");
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "loc2");
    CHECK_TRUE(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_SIZE));
    CHECK_TRUE(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_SPACING));
    CHECK_FALSE(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_TOPOLOGY));
}

TEST(err_haserrors_true_and_false) {
    stack<MOLE_Errors> errs;
    CHECK_FALSE(MOLEerr_haserrors(errs));
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SIZE, "loc");
    CHECK_TRUE(MOLEerr_haserrors(errs));
}

TEST(err_remove_deletes_matching_preserves_others_and_order) {
    stack<MOLE_Errors> errs;
    // Push in order: A, B, C  (C ends up on top)
    MOLEerr_log(errs, 100, "A");
    MOLEerr_log(errs, 200, "B");
    MOLEerr_log(errs, 100, "C"); // same code as A, different location
    MOLEerr_log(errs, 300, "D");

    MOLEerr_remove(errs, 100); // should remove both "A" and "C" entries

    CHECK_FALSE(MOLEerr_contains(errs, 100));
    CHECK_TRUE(MOLEerr_contains(errs, 200));
    CHECK_TRUE(MOLEerr_contains(errs, 300));

    // Remaining relative order of B, D should be preserved: D on top,
    // B below it (since D was pushed after B and neither was removed).
    CHECK_EQ(errs.size(), 2u);
    CHECK_EQ(errs.top().errLocation, "D");
    errs.pop();
    CHECK_EQ(errs.top().errLocation, "B");
}

TEST(err_remove_on_empty_stack_is_noop) {
    stack<MOLE_Errors> errs;
    MOLEerr_remove(errs, 999); // should not throw
    CHECK_TRUE(errs.empty());
}

TEST(err_print_does_not_crash_on_empty_or_populated) {
    stack<MOLE_Errors> errs;
    MOLEerr_print(errs); // "No errors logged."
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SIZE, "loc", "p");
    MOLEerr_print(errs); // should print without throwing
    CHECK_TRUE(true); // reaching here means no crash/exception
}

TEST(err_print_preserves_stack_contents) {
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SIZE, "loc", "p");
    size_t before = errs.size();
    MOLEerr_print(errs);
    CHECK_EQ(errs.size(), before); // print must not mutate the stack
}

// KNOWN BUG: MOLEerr_dumpErrLog() writes the log message and the
// user-supplied parameter string to the WRONG fields for known error
// codes (message and param arguments were swapped relative to
// writeErrtoFile's signature: ofile, errNum, errCode, errLocation,
// errParams, errMsg). FIXED in this revision: writeErrtoFile is now
// called with the arguments in the correct order, matching the
// stdout path (writeErrtoStdOut). This test confirms the dumped file
// puts the human-readable MESSAGE before "occurred inside" and the
// raw param ("m=5") after "with arg value(s):".
TEST(err_dumpErrLog_field_order_is_correct) {
    stack<MOLE_Errors> errs;
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SIZE, "testLoc", "m=5");

    std::string logType = "MOLE_TEST_DUMP_";
    MOLEerr_dumpErrLog(errs, logType);

    // Find the file that was just created (name = logType + timestamp)
    std::string found_file;
    for (auto& entry : std::filesystem::directory_iterator(".")) {
        std::string fname = entry.path().filename().string();
        if (fname.rfind(logType, 0) == 0) { found_file = fname; break; }
    }
    CHECK_FALSE(found_file.empty());
    if (found_file.empty()) return;

    std::ifstream in(found_file);
    std::stringstream buffer;
    buffer << in.rdbuf();
    std::string contents = buffer.str();
    in.close();
    std::remove(found_file.c_str());

    // Correct layout should read (see writeErrtoStdOut/writeErrtoFile
    // signature: errNum, errCode, errLocation, errParams, errMsg):
    //   "...] - <MESSAGE>\noccurred inside:<loc>with arg value(s): <m=5>"
    auto occurred_pos = contents.find("occurred inside");
    auto message_pos  = contents.find("Grid size must be a natural number > 0");
    auto param_pos    = contents.find("m=5");

    CHECK_TRUE(occurred_pos != std::string::npos);
    CHECK_TRUE(message_pos  != std::string::npos);
    CHECK_TRUE(param_pos    != std::string::npos);
    if (occurred_pos == std::string::npos || message_pos == std::string::npos
        || param_pos == std::string::npos) return;

    CHECK_TRUE(message_pos < occurred_pos); // message comes first
    CHECK_TRUE(param_pos > occurred_pos);   // raw param comes after
}
