// Tests for the MOLE_Errors error-stack subsystem
#include <gtest/gtest.h>
#include "MOLE_Errors.h"
#include <fstream>
#include <cstdio>
#include <filesystem>
#include <algorithm>
#include <vector>

// -----------------------------------------------------------------
// MOLEerr_init / MOLEerr_log / MOLEerr_haserrors
// -----------------------------------------------------------------

TEST(MOLEErrors, InitStartsEmpty) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    EXPECT_FALSE(MOLEerr_haserrors(errs));
    EXPECT_TRUE(errs.empty());
}

TEST(MOLEErrors, LogPushesOneError) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "unit-test", "5");
    EXPECT_TRUE(MOLEerr_haserrors(errs));
    ASSERT_FALSE(errs.empty());
    EXPECT_EQ(errs.top().errCode, MOLE_ERR_INVALID_GRID_DIM);
    EXPECT_EQ(errs.top().errLocation, "unit-test");
    EXPECT_EQ(errs.top().paramError, "5");
}

TEST(MOLEErrors, LogDefaultParamIsEmptyString) {
    // Regression test: MOLEerr_log's default argument (= "") is only
    // declared once now (header), not redefined in the .cpp -- this
    // test exercises that default actually still works end-to-end.
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    MOLEerr_log(errs, MOLE_ERR_GRID_UNCHECKED, "unit-test");
    ASSERT_FALSE(errs.empty());
    EXPECT_EQ(errs.top().paramError, "");
}

TEST(MOLEErrors, LogMultipleErrorsStackOrder) {
    // stack semantics: last pushed = top
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "loc1", "a");
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SIZE, "loc2", "b");
    EXPECT_EQ(errs.top().errCode, MOLE_ERR_INVALID_GRID_SIZE);
    errs.pop();
    EXPECT_EQ(errs.top().errCode, MOLE_ERR_INVALID_GRID_DIM);
}

// -----------------------------------------------------------------
// MOLEerr_contains
// -----------------------------------------------------------------

TEST(MOLEErrors, ContainsFindsCode) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "loc", "");
    EXPECT_TRUE(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_SPACING));
}

TEST(MOLEErrors, ContainsReturnsFalseWhenAbsent) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_SPACING, "loc", "");
    EXPECT_FALSE(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_SIZE));
}

TEST(MOLEErrors, ContainsOnEmptyStackIsFalse) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    EXPECT_FALSE(MOLEerr_contains(errs, MOLE_ERR_GRID_UNCHECKED));
}

// -----------------------------------------------------------------
// MOLEerr_remove
// -----------------------------------------------------------------

TEST(MOLEErrors, RemoveDeletesOnlyMatchingCode) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    MOLEerr_log(errs, MOLE_ERR_GRID_UNCHECKED, "loc", "");
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "loc", "");
    MOLEerr_remove(errs, MOLE_ERR_GRID_UNCHECKED);
    EXPECT_FALSE(MOLEerr_contains(errs, MOLE_ERR_GRID_UNCHECKED));
    EXPECT_TRUE(MOLEerr_contains(errs, MOLE_ERR_INVALID_GRID_DIM));
}

TEST(MOLEErrors, RemoveOnEmptyStackIsNoop) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    EXPECT_NO_THROW(MOLEerr_remove(errs, MOLE_ERR_GRID_UNCHECKED));
    EXPECT_TRUE(errs.empty());
}

// -----------------------------------------------------------------
// Error-code / message table integrity
// (Regression test for the MOLE_ERR_INVALID_GRID_SPACING duplicate
//  #define bug: every code used as a map key must be numerically
//  unique, or later entries silently clobber earlier ones.)
// -----------------------------------------------------------------

TEST(MOLEErrors, AllErrorCodesAreUnique) {
    std::vector<int> codes = {
        MOLE_ERR_GRID_UNCHECKED, MOLE_ERR_INVALID_GRID_ARGS,
        MOLE_ERR_GRID_CONSTRUCTION_FAILED, MAKE_GRID_INVALID_INPUT_ARGS,
        MAKE_GRID_MISSING_ARGS, MAKE_GRID_UNKNOWN_ATTRIBUTE,
        MAKE_GRID_DUPLICATE_ATTRIBUTES, MOLE_ERR_INVALID_GRID_DIM,
        MOLE_ERR_INVALID_GRID_TOPOLOGY, MOLE_ERR_INVALID_GRID_SPACING,
        MOLE_ERR_INVALID_GRID_SIZE, MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
        MOLE_ERR_GRID_CENTERS_SZ_MISMATCH, MOLE_ERR_GRID_FACES_SZ_MISMATCH,
        MOLE_ERR_INVALID_INPUT_TYPE, MOLE_ERR_ARRAY_HAS_NULL_POINTER,
        MOLE_ERR_INVALID_CELL_COUNT, MOLE_ERR_INVALID_ISPERIODIC_DIM,
        MOLE_ERR_ISPERIODIC_TYPE, MOLE_ERR_INVALID_CURVILINEAR_GRID,
        MOLE_ERR_INVALID_1D_CURVILINEAR, MOLE_ERR_INVALID_NONUNIFORM_GRID,
        MOLE_ERR_INVALID_ARRAY_INDEX, MOLE_ERR_INVALID_NODAL_COORDINATES,
        MOLE_ERR_INVALID_CENTER_COORDINATES,
        MOLE_ERR_INVALID_NORMAL_FACE_COORDINATES,
        MOLE_ERR_INVALID_ARRAY_SIZE, MOLE_ERR_ARRAY_SIZE_OVERFLOW,
        MOLE_ERR_ARRAY_INDEX_OUTBOUNDS
    };
    std::vector<int> sorted_codes = codes;
    std::sort(sorted_codes.begin(), sorted_codes.end());
    auto last = std::unique(sorted_codes.begin(), sorted_codes.end());
    EXPECT_EQ(last, sorted_codes.end())
        << "Two or more MOLE_ERR_* macros share the same numeric "
           "value -- one message/definition is silently shadowing "
           "another in MOLE_errors_messages.";
}

TEST(MOLEErrors, MessageTableHasEntryForEveryDefinedCode) {
    std::vector<int> codes = {
        MOLE_ERR_GRID_UNCHECKED, MOLE_ERR_INVALID_GRID_ARGS,
        MOLE_ERR_GRID_CONSTRUCTION_FAILED, MOLE_ERR_INVALID_GRID_DIM,
        MOLE_ERR_INVALID_GRID_TOPOLOGY, MOLE_ERR_INVALID_GRID_SPACING,
        MOLE_ERR_INVALID_GRID_SIZE, MOLE_ERR_GRID_NODAL_SZ_MISMATCH,
        MOLE_ERR_GRID_CENTERS_SZ_MISMATCH, MOLE_ERR_INVALID_CELL_COUNT,
        MOLE_ERR_INVALID_ISPERIODIC_DIM, MOLE_ERR_ISPERIODIC_TYPE,
        MOLE_ERR_INVALID_CURVILINEAR_GRID, MOLE_ERR_INVALID_1D_CURVILINEAR,
        MOLE_ERR_INVALID_NONUNIFORM_GRID, MOLE_ERR_INVALID_ARRAY_INDEX,
        MOLE_ERR_INVALID_NODAL_COORDINATES,
        MOLE_ERR_INVALID_CENTER_COORDINATES,
        MOLE_ERR_INVALID_NORMAL_FACE_COORDINATES,
        MOLE_ERR_INVALID_ARRAY_SIZE, MOLE_ERR_ARRAY_SIZE_OVERFLOW,
        MOLE_ERR_ARRAY_INDEX_OUTBOUNDS
    };
    for (int c : codes) {
        EXPECT_TRUE(MOLE_errors_messages.count(c) == 1)
            << "missing/duplicated message table entry for code " << c;
    }
}

TEST(MOLEErrors, GridSpacingMessageIsTheIntendedOne) {
    // Regression test for the specific duplicate #define bug: code
    // 102 (MOLE_ERR_INVALID_GRID_SPACING) must map to a real message,
    // not be silently overwritten to empty/wrong text.
    ASSERT_EQ(MOLE_errors_messages.count(MOLE_ERR_INVALID_GRID_SPACING), 1u);
    EXPECT_FALSE(MOLE_errors_messages[MOLE_ERR_INVALID_GRID_SPACING].empty());
}

// -----------------------------------------------------------------
// MOLEerr_dumpErrLog (file output)
// -----------------------------------------------------------------

TEST(MOLEErrors, DumpErrLogWritesAFile) {
    stack<MOLE_Errors> errs;
    MOLEerr_init(errs);
    MOLEerr_log(errs, MOLE_ERR_INVALID_GRID_DIM, "dumptest", "42");

    // MOLEerr_dumpErrLog names the file "<logType><timestamp>.log" (or
    // similar) -- we can't predict the exact name, so scan the cwd for
    // any newly created file starting with the prefix we pass in.
    std::string prefix = "UnitTestDump";
    MOLEerr_dumpErrLog(errs, prefix);

    bool found = false;
    for (const auto& entry :
         std::filesystem::directory_iterator(std::filesystem::current_path())) {
        std::string name = entry.path().filename().string();
        if (name.rfind(prefix, 0) == 0) {
            found = true;
            std::ifstream f(entry.path());
            ASSERT_TRUE(f.is_open());
            std::string content((std::istreambuf_iterator<char>(f)),
                                  std::istreambuf_iterator<char>());
            EXPECT_NE(content.find("42"), std::string::npos);
            f.close();
            std::remove(entry.path().string().c_str());
        }
    }
    EXPECT_TRUE(found) << "No log file with prefix '" << prefix
                        << "' was created by MOLEerr_dumpErrLog";
}
