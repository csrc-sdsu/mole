cmake_minimum_required(VERSION 3.14)

# ---------------------------------------------------------------
# Test sources - explicit list (same rationale as the library's
# own CMakeLists.txt: no GLOB, so a stray/unreviewed .cpp dropped in
# tests/ doesn't silently become part of what "make test" runs).
# ---------------------------------------------------------------
set(MOLE_TEST_SOURCES
    test_main.cpp
    test_flat2DArray.cpp
    test_flat3DArray.cpp
    test_MOLE_Errors.cpp
    test_MOLE_grids.cpp
)

foreach(_mole_test_src IN LISTS MOLE_TEST_SOURCES)
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_mole_test_src}")
        message(FATAL_ERROR
            "MOLE test source listed in tests/CMakeLists.txt is "
            "missing: ${_mole_test_src}")
    endif()
endforeach()

add_executable(mole_run_tests ${MOLE_TEST_SOURCES})

# mini_test.h lives in this same directory alongside the test .cpp
# files, so it just needs tests/ on the include path.
target_include_directories(mole_run_tests PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(mole_run_tests PRIVATE MOLE::mole)

target_compile_options(mole_run_tests PRIVATE -Wall -Wextra)

# Some tests (MOLEerr_dumpErrLog / write_ErrorLog) write small files
# into the current working directory and clean up after themselves.
# Give them a dedicated, disposable directory to write into rather
# than littering the build tree or (worse) the source tree.
set(MOLE_TEST_WORKDIR "${CMAKE_CURRENT_BINARY_DIR}/mole_test_run")
file(MAKE_DIRECTORY ${MOLE_TEST_WORKDIR})

add_test(
    NAME MOLE_RegressionTests
    COMMAND mole_run_tests
    WORKING_DIRECTORY ${MOLE_TEST_WORKDIR}
)

# mole_run_tests itself returns nonzero if any check failed (see
# RUN_ALL_TESTS() in mini_test.h), so ctest's default pass/fail
# detection (exit code) is all that's needed here - no custom
# PASS_REGULAR_EXPRESSION required.
